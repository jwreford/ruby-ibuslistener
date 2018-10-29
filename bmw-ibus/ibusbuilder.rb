
require_relative 'carStats'
require_relative 'ibus-devices/ike'
require_relative 'ibus-devices/rad'
require_relative 'ibus-devices/glo'
require_relative 'ibus-devices/nav'
require_relative 'ibus-devices/bm'
require_relative 'ibus-devices/cdc'
require_relative 'ibus-devices/cdd'
require_relative 'ibus-devices/dia'
require_relative 'ibus-devices/dsp'
require_relative 'ibus-devices/gt'
require_relative 'ibus-devices/lcm'
require_relative 'ibus-devices/obc'
require_relative 'ibus-devices/tel'
require_relative 'ibus-devices/vid'
require_relative 'ibus-devices/gtf'



class IBusBuilder
  def initialize(sourceDeviceName, destinationDeviceName, messageDetailsIn)
    # sourceDeviceName = The 2-4 letter abbreviated name from the table of the Source Device
    # destinationDeviceName = The 2-4 letter abbreviated name from the table of the Destiation Device
    # function = a hash containing all the requirements of a the function in quesiton.
    #     EG (for the Cluster Message Builder): ["Gong Type", "Priority" "Message ASCII", "LengthSpecified"]
    @sourceDeviceName = sourceDeviceName
    @destinationDeviceName = destinationDeviceName
    @messageDetails = messageDetailsIn
    @sourceDeviceHex = IBusDevices.key(sourceDeviceName)
    @destinationDeviceHex = IBusDevices.key(destinationDeviceName)
  end

  # Convert Convert ASCII to HEX
  def toHex(ascii)
    hexString = ascii.each_byte.map { |b| b.to_s(16) }.join(' ')
    hexArray = hexString.scan(/.{1,2}/)
    return hexArray
  end


  def buildMessage
    puts "Mssage Details 2: #{@messageDetails}"
    messageFunctionName = @messageDetails.fetch("functionName")
    messageFunctionDetails = @messageDetails.fetch("functionDetails") # This is probably going to need to be an array with the appropriate parameters inside
    messageContent = @messageDetails.fetch("content")
    puts "====== Building Message ======"
    puts "Source Device: #{@sourceDeviceName} (#{@sourceDeviceHex})"
    puts "Dest.. Device: #{@destinationDeviceName} (#{@destinationDeviceHex})"
    puts "Function Name: #{messageFunctionName}"
    puts "Function Name: #{messageFunctionDetails}"
    puts "Function Name: #{messageContent}"
    iBusMessageBuildObject = @sourceDeviceName.new(messageFunctionName, messageFunctionDetails, messageContent)
    #iBusMessageBuildObject.writeTitle
  end

  # Decode the data part of the message.
  def decodeData
    begin
    @processedData = @data.clone
    bytesCheck = []
    byteCounter = 0
    if @destinationName == "IKE"
      @methodMessage = IKE.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in IKE object ready for Decoding a message
      return "#{@methodMessage.decodeMessage}"
    end
    return "Device has no method, sozzle. #{@data}"
    @methodMessage = nil
    rescue Exception => ex
        puts "  --> [x] Ran into a problem doing something. Sorry about that. #{ex.class}: #{ex.message}."
        puts "#{ex.backtrace}"
    end
  end

  def lengthInAscii
    return self.toAscii2(@length)
  end
end

# # iBus Checksum Bit Starting Hex value
# ChecksumBitStart = ["00"]
#
# # iBus Device HEX values and their module names
# IBusDevices = {
#   ["00"] => "BOD",
#   ["08"] => "SUN",
#   ["18"] => "CDC",
#   ["28"] => "RCC",
#   ["30"] => "CCM",
#   ["3B"] => "GT",
#   ["3F"] => "DIA",
#   ["40"] => "LOC",
#   ["43"] => "GTF",
#   ["44"] => "IMM",
#   ["46"] => "CID",
#   ["50"] => "MFL",
#   ["51"] => "MMY",
#   ["5B"] => "IHKA",
#   ["60"] => "PDC",
#   ["68"] => "RAD",
#   ["6A"] => "DSP",
#   ["72"] => "SM",
#   ["73"] => "SIR",
#   ["76"] => "CDD",
#   ["7F"] => "NAV",
#   ["80"] => "IKE",
#   ["9B"] => "MMS",
#   ["9C"] => "MMT",
#   ["A0"] => "RMID",
#   ["A4"] => "AIR",
#   ["A8"] => "UNK5",
#   ["B0"] => "SPCH",
#   ["BB"] => "NAVJ",
#   ["BF"] => "GLO",
#   ["C0"] => "MID",
#   ["C8"] => "TEL",
#   ["CA"] => "ASST",
#   ["D0"] => "LCM",
#   ["E0"] => "IRIS",
#   ["E7"] => "OBC", # Also known as ANZV
#   ["E8"] => "RLS",
#   ["ED"] => "VID",
#   ["F0"] => "BM",
#   ["F5"] => "CSU",
#   ["FF"] => "BRD",
#   ["100"] => "Unset",
#   ["101"] => "Unknown"
# }

# This method will calculate the message's length and return the value in Hex.
def calculateMessageLength(data)
  lengthDecimal = (data.delete(' ').length / 2 + 2)
  lengthHex = toHex(lengthDecimal)
  return lengthHex
end

# Ths method will calculate the message's checksum. Pass in the source, destination,
def calculateMessageChecksum(source, length, destination, data)
  checksumBit = ChecksumBitStart[0]
  checksumVariable = [source, length, destination, data].reject(&:empty?).join
  bitsArray = checksumVariable.scan(/.{2}/)
  puts "#{bitsArray.length}"
  for currentBit in bitsArray.each do
    puts "Bit Value: #{currentBit}"
    checksumBit = (checksumBit.to_i(16) ^ currentBit.to_i(16)).to_s(16)
    puts "New Checksum Bit: #{checksumBit}"
  end
  return checksumBit
end

# This method will take the source, destination and data, and generate the length and checksum bytes using the other methods.
def buildMessage(source,destination,data)
  length = calculateMessageLength(data)
  # Strips the spaces out of the string.
  checksum = calculateMessageChecksum(source, destination, length, data).split.join
  # Returns the hex as in the correct order, ready to be sent on the bus.
  return "#{source} #{lendth} #{destination} #{data} #{checksum}"
end
