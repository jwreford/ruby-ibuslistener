
require_relative 'carStats'
require_relative 'ike'
require_relative 'rad'
require_relative 'glo'
require_relative 'nav'
require_relative 'bm'
require_relative 'cdc'
require_relative 'cdd'
require_relative 'dia'
require_relative 'dsp'
require_relative 'gt'
require_relative 'lcm'
require_relative 'obc'
require_relative 'tel'
require_relative 'vid'


## Note: iBus Message Structure:
# Source, Length, Destination, Data, Checksum


# The Class for an iBus Message. This contains all the methods for decoding a message.
class IBusMessage
  # What happens when a new iBusMessage object is created
  def initialize(rawMessage)
    #puts "In Initialise"
    # Instance variables
    @source = rawMessage.shift
    @length = rawMessage.shift
    @destination = rawMessage.shift
    @checksum = rawMessage.pop
    @data = rawMessage
    @processedData = []
    ## Find the source device's Module Name
    @sourceName = self.findDevice(@source)
    @sourceNameFriendly = self.findDeviceFriendly(@source)
    ## Find the destination device's Module Name
    @destinationName = self.findDevice(@destination)
    @destinationNameFriendly = self.findDeviceFriendly(@destination)
    #puts "Here's what I have for the IBusMessage: #{@source} #{@destination} #{@checksum} #{@data}"
  end

  # Print the message, but the data will be in hex.
  def printMessage
    puts "#{@sourceName} -> #{@destinationName}, Length: #{@length}, Data: #{@data}, Checksum: #{@checksum}."
  end

  def printRawMessage
    puts "Source: #{@source} -> Destination: #{@destination}, Length: #{@length}, Data: #{@data}, Checksum: #{@checksum}."
  end

  def printMessageFriendly
    "#{@destinationNameFriendly} -> #{@sourceNameFriendly}, Length: #{@length}, Data: #{@data}, Checksum: #{@checksum}."
  end

  # Print the message fully decoded.
  def printDecodedMessage
    puts "#{@sourceName} -> #{@destinationName}: #{self.decodeData}"
  end

  # Convert Hex to ASCII
  def toAscii2(hex)
    if hex.length > 2
      hex = hex.join("")
    end
    hex = [hex]
    return hex.pack('H*')
  end

  # Decode Current Speed and RPM
  def speedAndRPM(hex)
    speed = hex[0]
    speed = speed.to_i(16) * 2  # Speed is Hex value converted to Decimal multiplied by 2
    rpm = hex[1]
    # If the DME isn't supplying the RPM (either via the tacho wire or the CAN Bus) the IKE will send FF (which converts to 25500 RPM.)
    if rpm == "FF"
      rpm = " Sensor Not Connected"
    else
      rpm = rpm.to_i(16) * 100    # RPM is hex value converted to decimal multiplied by 100
    end
    cleanOutput = "Speed: #{speed} KM/H, RPM: #{rpm}"
    return cleanOutput
  end

  # Decode CD Changer Status Reply
  def cdChangerStatus(hex)
    cleanOutput = "Current Status: #{hex[0]}, Requested Status: #{hex[1]}, Current CD: #{hex[2]}, Current Track: #{hex[3]}, CDs Loaded: #{hex[4]}"
    return cleanOutput
  end

  # Decode Cluster Temperature Status Update
  def temperatureStatusUpdate(hex)
    exteriorTemperature = hex[0]  # Range is from -128 Degrees Celcius to +127 Degrees Celcius
    # As coolant temperature range is greater than 255 steps (-128 to +255 Degrees Celcius), two bytes are required.
    coolantTemperature1 = hex[1]  # Range is from -128 to +127 Degrees Celcius
    coolantTemperature2 = hex[2]  # Anything above +127 Degrees Celcuis will be added on with this byte
    if exteriorTemperature == "00"
      exteriorTemperature = "Sensor Not Connected"
    else
      exteriorTemperature = exteriorTemperature.to_i(16) - 128
      exteriorTemperature << "°"
    end
    if coolantTemperature1 == "00" && coolantTemperature2 == "00"
      coolantTemperatureTotal = "Sensor Not Connected"
    else
      coolantTemperatureTotal = "To Be Calculated"
      #coolantTemperatureTotal = coolantTemperature1.to_i(16) + coolantTemperature2.to_i(16) - 128
    end
    cleanOutput = "Exterior Temperature: #{exteriorTemperature}, Coolant Temperature: #{coolantTemperatureTotal}"
    return cleanOutput
  end

  def videoControllerField(hex)
    case hex[0]
    when "01"
      # HeadingField1
    when "02"
      # HeadingField2
    when "03"
      # HeadingField3
    when "04"
      # HeadingField4
    when "05"
      # HeadingField5
    when "06"
      # HeadingField6
    when "07"
      # HeadingField7
    when "40"
      # LowerField1
    when "41"
      # LowerField2
    when "42"
      # LowerField3
    when "43"
      # LowerField4
    when "44"
      # LowerField5
    when "45"
      # LowerField6
    when "46"
      # LowerField7
    when "47"
      # LowerField8
    when "48"
      # LowerField9
    when "49"
      # LowerField10
    else
      # Title
    end
    puts "In Video Controller Field"
  end


  def rlsMessageDecoder(bytes)
    lightConditionbyte = bytes[0]
    lightIntensitybyte = bytes[1]
    lightCondition = ""
    lightIntensity = ""

    case lightConditionbyte
    when "01"
      lightCondition = "Twilight"
    when "02"
      lightCondition = "Darkness"
    when "04"
      lightCondition = "Raining"
    when "08"
      lightCondition = "Tunnel"
    when "10"
      lightCondition = "Garage"
    end

    case lightIntensitybyte
    when "11"
      lightIntensity = "1"
    when "21"
      lightIntensity = "2"
    when "31"
      lightIntensity = "3"
    when "41"
      lightIntensity = "4"
    when "50"
      lightIntensity = "5"
    when "60"
      lightIntensity = "6"
    end

    lightSensorDataHash = {
      ["lightCondition"] => "LightCondition",
      ["LightIntensity"] => "LightIntensity"
    }

    return lightSensorDataHash
  end




  def decodeVideoControllerMessage(bytes)
    functionByte = ""
    destinationByte = ""
    messageByte = ""
    function = ""
    destination = ""
    message = ""

    bytes.pop(2) # Drop the checksum and the other mystery bit from the end
    ## Write to lower headers (Incomplete)
    if bytes[0] == "21" && bytes[1] == "61" && bytes[2] == "00"
      functionByte = bytes.shift(3)
      destinationByte = bytes.shift
      messageByte = bytes
      destination = VideoControllerFields.fetch([destinationByte])
      message = toAscii2(messageByte)
      function = "Write to Lower Header"
      cleanOutput = "#{function} (#{destination}). Text: #{message})"
    elsif bytes[0] == "A5" && bytes[1] == "61" && bytes[2] == "01"
      functionByte = bytes.shift(3)
      function = "Partial Write Complete"
    elsif bytes[0] == "A1" && bytes[1] == "60" && bytes[2] == "01"
      functionByte = bytes.shift(3)
      function = "Unknown Text Field"
    elsif bytes[0] == "02" && bytes[1] == "30"
        cleanOutput = "Video Module Status Request"
    else
      cleanOutput = "Unknown Video Controller Message"
    end
    puts cleanOutput
    return cleanOutput
  end


  # Return the status of the doors
  def doorAndWindowStatus(bytes)

    if bytes.contains("HH")
      #TODO: Finish this method
    end
  end


  # Decode the data part of the message.
  def decodeData
    #begin
    #puts "In Decode Data"
    @processedData = @data.clone
    bytesCheck = []
    byteCounter = 0
    # Check and see whether this device has any methods in the hash, and if not, skip to the end.
    if @destinationName == "IKE"
      @methodMessage = IKE.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in IKE object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "RAD"
      @methodMessage = RAD.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "GLO"
      @methodMessage = GLO.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "TEL"
      @methodMessage = TEL.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "NAV"
      @methodMessage = NAV.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "CDD"
      @methodMessage = CDD.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "GT"
      @methodMessage = GT.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "CDC"
      @methodMessage = CDC.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "VID"
      @methodMessage = VID.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "BM"
      @methodMessage = BM.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "DSP"
      @methodMessage = DSP.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "OBC"
      @methodMessage = OBC.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "DIA"
      @methodMessage = DIA.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif @destinationName == "LCM"
      @methodMessage = LCM.new
      @methodMessage.setDecode(@sourceName,@data,@length) # Set variables in RAD object ready for Decoding a message
      @methodMessage.decodeMessage
      #puts "Decoded Message: #{@methodMessage.decodeMessage}"
      return "#{@methodMessage.decodeMessage}"
    elsif DeviceFunctionsIN.key?(@destinationName) == true && @destinationName != "GT"
      # Iterate through the message, starting with on byte. If we don't find a valid method, add the next byte to the end and try again
      @processedData.each { |currentByte|
        bytesCheck.push(currentByte)
        byteCounter = byteCounter + 1
        if DeviceFunctionsIN.fetch(@destinationName).key?(bytesCheck) == true
          #puts "--> Known Message Type: #{bytesCheck}!"
          # Check if message type is inside the FunctionDetailsDecode hash
          begin
             FunctionDetailsDecode.fetch(DeviceFunctionsIN.fetch(@destinationName).fetch(bytesCheck))
               methodType = "function"
               #puts "  --> [✓] Message Found in Functions Hash. It says: #{FunctionDetailsDecode.fetch(DeviceFunctionsIN.fetch(@destinationName).fetch(bytesCheck))}"
          rescue Exception => ex
              methodType = "none"
              #puts "  --> [x] Problem looking for this message in the Functions Hash. #{ex.class}: #{ex.message}"
          end
          if methodType == "none"
            begin
              StaticMessages.fetch(DeviceFunctionsIN.fetch(@destinationName).fetch(bytesCheck))
                methodType = "static"
                #puts "  --> [✓] Message Found in Static Hash. It says: #{StaticMessages.fetch(DeviceFunctionsIN.fetch(@destinationName).fetch(bytesCheck))}"
            rescue Exception => ex
              methodType = "none"
              #puts "  --> [x] Problem looking for this message in the Staic Hash. #{ex.class}: #{ex.message}"
            end
          end
          #puts "  ---> Bytes Used: #{byteCounter}"
          for i in 1..byteCounter do
            @processedData.shift
          end
          # Check if this message type needs converting (the whole or part) of the message into ASCII
          #puts " ---> Method Type: #{methodType}"
          if methodType == "function"
            functionToPerform = FunctionDetailsDecode.fetch(DeviceFunctionsIN.fetch(@destinationName).fetch(bytesCheck))[1]
            #puts "Function: #{functionToPerform}"
            #puts send(functionToPerform, @processedData)
            messageOutput = send(functionToPerform, @processedData)
            return "#{FunctionDetailsDecode.fetch(DeviceFunctionsIN.fetch(@destinationName).fetch(bytesCheck))[0]}: #{messageOutput}"
          # Check if this message type is just some form of identifier that we have statically recorded
          elsif methodType == "static"
            staticMessage = StaticMessages.fetch(DeviceFunctionsIN.fetch(@destinationName).fetch(bytesCheck))
            #puts "Static Message: #{staticMessage}"
            return staticMessage
          elsif methodType == "none"
            # puts "No specific instructions for decoding message."
            puts "Message: #{DeviceFunctionsIN.fetch(@destinationName).fetch(bytesCheck)}"
          end
        end
      }
      puts "#{@sourceName} #{@length} #{@destinationName} #{@data} #{@checksum}"
      return "Unknown Message"
    end
    return "Device has no method, sozzle. #{@data}"
    @methodMessage = nil
  #rescue Exception => ex
  #    puts "  --> [x] Problem looking for this message in the Functions Hash. #{ex.class}: #{ex.message}"
  #  end
  end


  def findDevice(device)
    #puts "In findDevice"
    if IBusDevices.key?([device]) == false
      return "Unknown Device (#{device})"
    else
      #puts "Device: #{IBusDevices.fetch([device])}"
      return IBusDevices.fetch([device])
    end
  end

  def findDeviceFriendly(device)
    #puts "In findDevice"
    if IBusDevicesFriendly.key?([device]) == false
      return "Unknown Device (#{device})"
    else
      #puts "Device: #{IBusDevices.fetch([device])}"
      return IBusDevicesFriendly.fetch([device])
    end
  end


  def lengthInAscii
    #puts "in findDestination"
    #puts "#{self.toAscii2(@length)}"
    return self.toAscii2(@length)
  end
end

# iBus Checksum Bit Starting Hex value
ChecksumBitStart = ["00"]

# iBus Device HEX values and their module names
IBusDevices = {
  ["00"] => "BOD",
  ["08"] => "SUN",
  ["18"] => "CDC",
  ["28"] => "RCC",
  ["30"] => "CCM",
  ["3B"] => "GT",
  ["3F"] => "DIA",
  ["40"] => "LOC",
  ["43"] => "RVD",
  ["44"] => "IMM",
  ["46"] => "CID",
  ["50"] => "MFL",
  ["51"] => "MMY",
  ["5B"] => "IHKA",
  ["60"] => "PDC",
  ["68"] => "RAD",
  ["6A"] => "DSP",
  ["72"] => "SM",
  ["73"] => "SIR",
  ["76"] => "CDD",
  ["7F"] => "NAV",
  ["80"] => "IKE",
  ["9B"] => "MMS",
  ["9C"] => "MMT",
  ["A0"] => "RMID",
  ["A4"] => "AIR",
  ["A8"] => "UNK5",
  ["B0"] => "SPCH",
  ["BB"] => "NAVJ",
  ["BF"] => "GLO",
  ["C0"] => "MID",
  ["C8"] => "TEL",
  ["CA"] => "ASST",
  ["D0"] => "LCM",
  ["E0"] => "IRIS",
  ["E7"] => "OBC", # Also known as ANZV
  ["E8"] => "RLS",
  ["ED"] => "VID",
  ["F0"] => "BM",
  ["F5"] => "CSU",
  ["FF"] => "BRD",
  ["100"] => "Unset",
  ["101"] => "Unknown"
}

# iBus Device HEX values and their names (Friendly)
IBusDevicesFriendly = {
  ["00"] => "General Module",
  ["08"] => "Sunroof",
  ["18"] => "CD Changer",
  ["28"] => "Radio Clock Control",
  ["30"] => "Check Control Module",
  ["3B"] => "Video Controller",
  ["3F"] => "Diagnostics Request",
  ["40"] => "Central Locking",
  ["43"] => "Rear Video Controller",
  ["44"] => "Immobaliser",
  ["46"] => "Central Information Display",
  ["50"] => "Steering Wheel Controls",
  ["51"] => "Mirror Memory",
  ["5B"] => "Climate Control",
  ["60"] => "Park Distance Control",
  ["68"] => "Radio",
  ["6A"] => "DSP Amplifier",
  ["72"] => "Seat Memory Module",
  ["73"] => "Sirius",
  ["76"] => "Cd Changer DIN",
  ["7F"] => "Navigation",
  ["80"] => "Instrument Cluster",
  ["9B"] => "Mirror Memort Second",
  ["9C"] => "Mirror Memory Third",
  ["A0"] => "Rear MID",
  ["A4"] => "Airbag Controller",
  ["A8"] => "Unknown 'A8'",
  ["B0"] => "Speech Recognition",
  ["BB"] => "Naigation Japan",
  ["BF"] => "Global Message",
  ["C0"] => "Multifunction Information Display",
  ["C8"] => "Telephone",
  ["CA"] => "Assist Button",
  ["D0"] => "Light Controller Module",
  ["E0"] => "Integrated Radio Information System",
  ["E7"] => "Cluster Text Display",
  ["E8"] => "Rain and Light Sensor",
  ["ED"] => "TV Module",
  ["F0"] => "Front Display",
  ["F5"] => "CSU",
  ["FF"] => "Broadcast Message",
  ["100"] => "Unset",
  ["101"] => "Unknown '101'"
}



# The fields that can be written to on the board monitor.
VideoControllerFields = {
  [""] => "Title", # 11 Characters
  ["01"] => "HeadingField1", # 5 Characters
  ["02"] => "HeadingField2", # 5 Characters
  ["03"] => "HeadingField3", # 5 Characters
  ["04"] => "HeadingField4", # 5 Characters
  ["05"] => "HeadingField5", # 7 Characters
  ["06"] => "HeadingField6", # 20 Characters
  ["07"] => "HeadingField7", # 20 Characters
  ["40"] => "LowerField1", # 14 Characters
  ["41"] => "LowerField2", # 14 Characters
  ["42"] => "LowerField3", # 14 Characters
  ["43"] => "LowerField4", # 14 Characters
  ["44"] => "LowerField5", # 14 Characters
  ["45"] => "LowerField6", # 14 Characters
  ["46"] => "LowerField7", # 14 Characters
  ["47"] => "LowerField8", # 14 Characters
  ["48"] => "LowerField9", # 14 Characters
  ["49"] => "LowerField10", # 14 Characters
}

BoardMonitorLED = {
  ["00"] => "AllOff", # All LEDs are off
  ["01"] => "RedOn", # Red LED On
  ["03"] => "RedFlash", # Red LED Flashing
  ["04"] => "YellowOn", # Yellow LED On
  ["05"] => "RedOnYellowOn", # Red and Yellow LEDs On
  ["07"] => "RedFlashYellowOn", # Red LED Flashing (Fast?), Yellow LED On
  ["10"] => "GreenOn", # Green LED On
  ["11"] => "RedOnGreenOn", # Red and Green LEDs on
  ["14"] => "YellowOnGreenOn", # Red LED On
  ["15"] => "AllOn", # All LEDs On
  ["17"] => "RedFlashYellowOnGreenOn", # Red LED Flashing (Double?)
  ["31"] => "RedOnGreenFlash",
  ["32"] => "GreenFlash",
  ["33"] => "RedFlashGreenFlash",
  ["04"] => "YellowOnGreenFlash",
  ["35"] => "RedOnYellowOnGreenFlash",
  ["37"] => "RedFlashYellowOnGreenFlash",
  ["39"] => "RedOnGreen"
}

FunctionDetailsEncode = {
   "MessageType1" => ["Message Type 1", "toHex"]
 }
FunctionDetailsDecode = {
   "MessageType1" => ["Message Type 1", "toAscii2"],
   "CurrentLocationSuburb" => ["Current City and Suburb", "toAscii2"],
   "CurrentLocationStreetAndNumber" => ["Current Street and Number", "toAscii2"],
   "CurrentLocationCoordinates" => ["Current Location in Coordinates", "toAscii2"],
   "CurrentSpeedAndRPM" => ["Current Speed and RPM", "speedAndRPM"],
   "CDChangerStatusReply" => ["CD Changer Status", "cdChangerStatus"],
   "TemperatureStatus" => ["Current Temperatures", "temperatureStatusUpdate"],
   "WriteToTitle" => ["Title Text Updated", "toAscii2"]
 }

StaticMessages = {
   "UnknownLocationStatusMessage" => "Unknown Location Status Message (ID 1)",
   "CDChangerStatusRequest" => "Is a CD Changer Connected?",
   "DSPStatusRequest" => "Is there a DSP Amplifier Connected?",
   "FrontCDStatusRequest" => "Is there a Front CD Player Connected?",
   "KnobPress" => "Volume Knob Pressed (Toggle Radio)",
   "KnobHold" => "Volume Knob Held",
   "KnobRelease" => "Volume Knob Released",
   "KnobRotateLeftSpeed1" => "Volume Decreased (1 Step)",
   "KnobRotateLeftSpeed2" => "Volume Decreased (2 Steps)",
   "KnobRotateLeftSpeed3" => "Volume Decreased (3 Steps)",
   "KnobRotateLeftSpeed4" => "Volume Decreased (4 Steps)",
   "KnobRotateLeftSpeed5" => "Volume Decreased (5 Steps)",
   "KnobRotateLeftSpeed6" => "Volume Decreased (6 Steps)",
   "KnobRotateLeftSpeed7" => "Volume Decreased (7 Steps)",
   "KnobRotateLeftSpeed8" => "Volume Decreased (8 Steps)",
   "KnobRotateLeftSpeed9" => "Volume Decreased (9 Steps)",
   "KnobRotateRightSpeed1" => "Volume Increased (1 Step)",
   "KnobRotateRightSpeed2" => "Volume Increased (2 Steps)",
   "KnobRotateRightSpeed3" => "Volume Increased (3 Steps)",
   "KnobRotateRightSpeed4" => "Volume Increased (4 Steps)",
   "KnobRotateRightSpeed5" => "Volume Increased (5 Steps)",
   "KnobRotateRightSpeed6" => "Volume Increased (6 Steps)",
   "KnobRotateRightSpeed7" => "Volume Increased (7 Steps)",
   "KnobRotateRightSpeed8" => "Volume Increased (8 Steps)",
   "KnobRotateRightSpeed9" => "Volume Increased (9 Steps)",
   "RadioStatusRequest" => "Is there a Radio Connected?",
   "RadioStatusReply" => "Radio Connected and Ready",
   "ClusterStatusRequest" => "Is there a Cluster Connected?",
   "GeneralDeviceStatusReply" => "Connected and Ready",
   "CurrentPhoneStatusRequest" => "Is a Phone Connected?",
   "CurrentNetworkConnectedStatusRequest" => "Is the Cell Network Connected?",
   "VideoModuleStatusRequest" => "Is there a TV Module Connected?",
   "VideoModuleStatusReply" => "TV Module Connected and Ready",
   "BoardMonitorStatusRequest" => "Is there a Board Monitor Connected?"
}

# Hash containing individual hashes for each of the devices
DeviceFunctionsIN = {
}

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

# This method will search the IBusDevices hash to see if we have a name for the Device (Source / Destination).
# The device should be passed as an array of one byte, EG ["00"]
def findDevice(device)
  if IBusDevices.key?([device]) == false
   return "Unknown Device (#{device})"
  else
    return IBusDevices.fetch([device])
  end
end
