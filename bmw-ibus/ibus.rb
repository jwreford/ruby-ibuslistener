
require_relative 'carStats'
require_relative 'ike'
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

  # Creates the Message to send to the cluster.
  ## Options for the messagePriority:
  ## - ClearMessage: Clears the current alert.
  ## - Priority3: Low priority message
  ## - Priority2: Medium priority message
  ## - Priority1: High priority message
  ## Options for textLength
  ## - LengthSpecified
  ## - LengthNotSpecified
  ## Options for the displayType:
  ## - NoChange: Display is not changed
  ## - NoText: Display is cleared
  ## - Text: Text is shown on the display
  ## - TextFlashing: Text is shown flashing (once per second) on the display
  ## Options for the gongType:
  ## - NoGong: No gong is sounded: Example: Changing radio station using the steering wheel controls.
  ## - SilenceGong: Switch gong off if currently 'gonging'
  ## - SingleT3: A single standard Gong tone. Example: Speed limit exceeded
  ## - ConstantT3: The standard gong tone is sounded every 1.5 seconds for the duration of the message. Example: Key In Ignition alert.
  ## - DoubleT3: The standard gong tone is sounded twice (0.75 seconds apart). Example: Handbreak on alert.
  ## - SingleT2: A single 'check control' gong tone is sounded.
  ## - TripleT3: Three short standard gong tones are sounded. Example: Memo alert for the tine.
  ## - SingleT1: A single lower-pitched gong tone is sounded. Example: CODE
  ## - NOTE: Pass in messageContent as array of hex. EG: ["AA", "BB", "CC"]
  def clusterMessageBuilder(messagePriority, textLength, displayType, gongType, messageContent)
    byte1 = "00000000"
    byte2 = "00000000"
    case messagePriority
    when "ClearMessage"
      byte1[5] = "0"
      byte1[6] = "0"
      byte1[7] = "0"
    when "Priority3"
      byte1[5] = "1"
      byte1[6] = "0"
      byte1[7] = "1"
    when "Priority2"
      byte1[5] = "1"
      byte1[6] = "1"
      byte1[7] = "1"
    when "Priority1"
      byte1[5] = "1"
      byte1[6] = "0"
      byte1[7] = "1"
    when "Unknown"
      byte1[5] = "0"
      byte1[6] = "0"
      byte1[7] = "1"
    end

    case textLength
    when "LengthSpecified"
      byte1[4] = "0"
    when "LengthNotSpecified"
      byte1[4] = "1"
    end

    case displayType
    when "NoChange"
      byte1[2] = "0"
    when "NoText"
      byte1[2] = "1"
      byte2[6] = "0"
      byte2[7] = "0"
    when "Text"
      byte1[2] = "1"
      byte2[6] = "1"
      byte2[7] = "0"
    when "TextFlashing"
      byte1[2] = "1"
      byte2[6] = "1"
      byte2[7] = "1"
    end

    case gongType
    when "NoGong"
      byte1[3] = "0"
    when "SilenceGong"
      byte1[3] = "1"
      byte2[2] = "0"
      byte2[3] = "0"
      byte2[4] = "0"
      byte2[5] = "0"
    when "SingleT3"
      byte1[3] = "1"
      byte2[2] = "0"
      byte2[3] = "0"
      byte2[4] = "0"
      byte2[5] = "1"
    when "ConstantT3"
      byte1[3] = "1"
      byte2[2] = "0"
      byte2[3] = "0"
      byte2[4] = "1"
      byte2[5] = "0"
    when "DoubleT3"
      byte1[3] = "1"
      byte2[2] = "0"
      byte2[3] = "0"
      byte2[4] = "1"
      byte2[5] = "1"
    when "SingleT2"
      byte1[3] = "1"
      byte2[2] = "0"
      byte2[3] = "1"
      byte2[4] = "0"
      byte2[5] = "1"
    when "SingleT1"
      byte1[3] = "1"
      byte2[2] = "0"
      byte2[3] = "1"
      byte2[4] = "1"
      byte2[5] = "0"
    # Missing TripleT3
    end

    puts "Bits (Gong and Message Type): #{byte1} #{byte2}"
    messageContent = messageContent.toHex
    byte1 = byte1.pack('H*')
    byte2 = byte2.pack('H*')
    puts "Hex (Gong and Message Type): #{byte1} #{byte2}"
    puts "Message Content: #{messageContent}"
    finishedMessage = []
    finishedMessage[0] = byte1
    finishedMessage[1] = byte2
    messageContent.each { |x|
      puts "Current Array Element: #{x}"
      messageContent.push(messageContent.fetch(x))
      puts "Size of messageContent: #{messageContent.length}"
    }
    puts "Finished Message: #{finishedMessage}"
    return finishedMessage
  end

  # Pass in OBC Messge to the cluster as an array of hex bytes
  def clusterMessageDecoder(bytes)
    # TODO: Write toBinary method or find another way to convert a hex byte to binary.
    byte1 = bytes[0].shift.toBinary
    byte2 = bytes[1].shift.toBinary
    messagePriority = ""
    textLength = ""
    displayType = ""
    gongType = ""
    messageContent = bytes.toAscii2

    # Message Priority
    case
    when byte1[5] == "0" && byte1[6] == "0" && byte1[7] == "0"
      messagePriority = "ClearMessage"
    when byte1[5] == "1" && byte1[6] == "0" && byte1[7] == "1"
      messagePriority = "Priority3"
    when byte1[5] == "1" && byte1[6] == "1" && byte1[7] == "1"
      messagePriority =  "Priority2"
    when byte1[5] == "1" && byte1[6] == "0" && byte1[7] == "1"
      messagePriority =  "Priority1"
    when byte1[5] == "0" && byte1[6] == "0" && byte1[7] == "1"
      messagePriority = "Unknown"
    end

    # Text Length
    case
    when byte1[4] == "0"
      textLength = "LengthSpecified"
    when byte1[4] == "1"
      textLength = "LengthNotSpecified"
    end

    # Display Type
    case
    when byte1[2] == "0"
      displayType = "NoChange"
    when byte1[2] == "1" && byte2[6] == "0" && byte2[7] == "0"
      displayType = "NoText"
    when byte1[2] == "1" && byte2[6] == "1" && byte2[7] == "0"
      displayType = "Text"
    when byte1[2] == "1" && byte2[6] == "1" && byte2[7] == "1"
      displayType = "TextFlashing"
    end

    # Gong Type
    case
    when byte1[3] == "0"
      gongType = "NoGong"
    when byte1[3] == "1" && byte2[2] == "0" && byte2[3] == "0" && byte2[4] == "0" && byte2[5] == "0"
      gongType = "SilenceGong"
    when byte1[3] == "1" && byte2[2] == "0" && byte2[3] == "0" && byte2[4] == "0" && byte2[5] == "1"
      gongType = "SingleT3"
    when byte1[3] == "1" && byte2[2] == "0" && byte2[3] == "0" && byte2[4] == "1" && byte2[5] == "0"
      gongType = "ConstantT3"
    when byte1[3] == "1" && byte2[2] == "0" && byte2[3] == "0" && byte2[4] == "1" && byte2[5] == "1"
      gongType = "DoubleT3"
    when byte1[3] == "1" && byte2[2] == "0" && byte2[3] == "1" && byte2[4] == "0" && byte2[5] == "1"
      gongType = "SingleT2"
    when byte1[3] == "1" && byte2[2] == "0" && byte2[3] == "1" && byte2[4] == "1" && byte2[5] == "0"
      gongType = "SingleT1"
    end
    #puts "Cluster Message - Priority: #{messagePriority}, Text Length: #[textLength], Display Type: #{displayType}, Gong Type: #{gongType}. Message Content: #{messageContent}"
    return [messagePriority, textLength, displayType, gongType, messageContent]
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
    #puts "In Decode Data"
    @processedData = @data.clone
    bytesCheck = []
    byteCounter = 0
    methodType = ""
    # Check and see whether this device has any methods in the hash, and if not, skip to the end.
    if @destinationName == "IKE"
          @methodMessage = IKE.new
          @methodMessage.setRawMessage(@sourceName,@data,@length)
          @methodMessage.putsHello
          puts "Source Source: #{@sourceName}"
          puts "#{@methodMessage.decodeFunction}"
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
    return "Device has no method, sozzle"
    @methodMessage = nil
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

IKEMessages = {
    # There are a number of combinations for Instrument Cluster messages.
    # Display: No Text, Text, and Text with Flashing Triangles.
    # Gong: No Gong, T3 (single), T2 (double) T3 (triple), T3 (continuous), T2, T1

    # Confirmed
    ["00", "00"] => "MessageClear",
    ["35", "00"] => "MessageTextNoGong",

    # Not Confirmed
    ["00", "00"] => "MessageTextT1",
    ["00", "00"] => "MessageTextT2",
    ["00", "00"] => "MessageTextT3Single",
    ["00", "00"] => "MessageTextT3Double",
    ["00", "00"] => "MessageTextT3Triple",
    ["00", "00"] => "MessageTextT3Continuous",
    ["00", "00"] => "MessageFlashingTextT1",
    ["00", "00"] => "MessageFlashingTextT2",
    ["00", "00"] => "MessageFlashingTextT3Single",
    ["00", "00"] => "MessageFlashingTextT3Double",
    ["00", "00"] => "MessageFlashingTextT3Triple",
    ["00", "00"] => "MessageFlashingTextT3Continuous"

}

# Hash containing individual hashes for each of the devices
DeviceFunctionsIN = {
  # Messages that devices can send to the Instrument CLuster
  # Note: For custom messages, add message content after the hex below.
  "IKE" => {
      ["1A"] => "Message",
      ["10"] => "RequestTerminalStatus",
      ["12"] => "SensorRequest",
      ["01"] => "ClusterStatusRequest",

      # Sent from the Video Controller (presumably to know whether to show the logo when a door is opened)
      ["10"] => "IgnitionStatusRequest"
},

  "DIA" => {
    ["A0"] => "DiagnosticsRequestRecieved"

  },
  # Messages tht other devices can send the LCM
  "LCM" => {
    # From the Instrument Cluster usually
    ["13", "00", "13", "00", "00", "00", "00"] => "ReversingSignal",
    ["18", "06", "0E"] => "TVNotPermittedWhileMoving",
    ["18", "00", "07"] => "TVPermitted"
  },

  # Broadcast Messages (sent globally)
  "GLO" => {
    # From the Instrument Cluster
    ## Terminal Status
    # KL 0 = OFF (ignition off position)
    # KL R = ignition position 1 ("run" - some electonics & modules are powered up)
    # KL 15 = ignition position 2 ("accessory" - all electronics & modules are powered)
    # KL 30 = ignition position 3 (where the ignition defauts after starting the engine)
    # KL 50 = ignition start position
    ["11", "00"] => "TerminalKL30",
    ["11", "01"] => "TerminalKLR",
    ["11", "03"] => "TerminalKLRAndKL15",
    ["11", "07"] => "TerminalKLRAndKL15AndKL50",

    # From the Board Monitor.
    ["48", "08"] => "PhonePress",
    ["48", "48"] => "PhoneHold",
    ["48", "88"] => "PhoneRelease",
    ["48", "45"] => "MenuPress",
    ["48", "85"] => "MenuHold",
    ["48", "85"] => "MenuRelease",

    # I think this is from the IHKA
    ["48", "07"] => "AuxHeatingPress",

    # From the Cluster broadcasting some general information
    ["18"] => "CurrentSpeedAndRPM",

    # From the Radio broadcasting that it's ready.
    ["02", "01", "D1"] => "RadioStatusReply",

    # From Various Devices
    ["02", "00"] => "GeneralDeviceStatusReply",

    # From the Cluster
    ["19", "80", "80"] => "TemperatureStatus"



  },

  # Messages that devices can send to the 'OBC'
  "OBC" => {
    ["24", "01", "00"] => "Time",
    ["24", "02", "00"] => "Date",
    ["24", "03", "00"] => "OutsideTemperature",
    ["24", "04", "00"] => "Consumption1",
    ["24", "05", "00"] => "Consumption2",
    ["24", "06", "00"] => "Range",
    ["24", "07", "00"] => "DistanceToDestination",
    ["24", "08", "00"] => "TimeToDestination",
    ["24", "09", "00"] => "SpeedLimit",
    ["24", "0A", "00"] => "AverageSpeed",
    ["24", "0E", "00"] => "Timer",
    ["24", "0F", "00"] => "AuxHeatingTimer1",
    ["24", "10", "00"] => "AuxHeatingTimer2",
    ["24", "1A", "00"] => "UnknownFunction",

    # Board Monitor LEDs
    ["2B"] => "BoardMonitorLED"
  },

  # Messages that other devices can send to the Radio
  "RAD" => {
    # Diagnostics Data
    ["00"] => "DiagnosticsReadID",
    ["04", "00"] => "DiagnosticsReadFaultMemory",
    # From the CD Changer. This is a bit of a guess - I might be stripping part of the message off unintentionally.
    ["39", "00", "02", "00"] => "CDChangerStatusReply",

    # From the Board Monitor to the Radio
    ["01"] => "RadioStatusRequest",

    # From the Steering Wheel Controls
    ["32", "10"] => "VolumeDownPress",
    ["32", "11"] => "VolumeUpPress",
    ["3B", "01"] => "NextTrackPress",
    ["3B", "21"] => "NextTrackRelease",
    ["3B", "08"] => "PreviousTrackPress",
    ["3B", "28"] => "PreviousTrackRelease",

    # From the Board Monitor
    ## Buttons
    ["48", "14"] => "ReverseTapePress",
    ["48", "11"] => "1Press",
    ["48", "12"] => "3Press",
    ["48", "13"] => "5Press",
    ["48", "32"] => "TPPress",
    ["48", "31"] => "FMPress",
    ["48", "33"] => "DolbyPress",
    ["48", "04"] => "TonePress",
    ["48", "10"] => "PreviousTrackPress",
    ["48", "30"] => "MenuPress",
    ["48", "54"] => "ReverseTapeHold",
    ["48", "51"] => "1Hold",
    ["48", "52"] => "3Hold",
    ["48", "53"] => "5Hold",
    ["48", "72"] => "TPHold",
    ["48", "71"] => "FMHold",
    ["48", "73"] => "DolbyHold",
    ["48", "44"] => "ToneHold",
    ["48", "50"] => "PreviousTrackHold",
    ["48", "70"] => "MenuHold",
    ["48", "94"] => "ReverseTapeRelease",
    ["48", "91"] => "1Release",
    ["48", "92"] => "3Release",
    ["48", "93"] => "5Release",
    ["48", "B2"] => "TPRelease",
    ["48", "B1"] => "FMRelease",
    ["48", "84"] => "DolbyRelease",
    ["48", "90"] => "NextTrackRelease",
    ["48", "B0"] => "MenuRelease",
    ["48", "24"] => "EjectPress",
    ["48", "01"] => "2Press",
    ["48", "02"] => "4Press",
    ["48", "03"] => "6Press",
    ["48", "22"] => "RDSPress",
    ["48", "21"] => "AMPress",
    ["48", "23"] => "ModePress",
    ["48", "20"] => "SelectPress",
    ["48", "00"] => "NextTrackPress",
    ["48", "64"] => "EjectHold",
    ["48", "41"] => "2Hold",
    ["48", "42"] => "4Hold",
    ["48", "43"] => "6Hold",
    ["48", "62"] => "RDSHold",
    ["48", "61"] => "AMHold",
    ["48", "63"] => "ModeHold",
    ["48", "60"] => "SelectHold",
    ["48", "40"] => "NextTrackHold",
    ["48", "A4"] => "EjectRelease",
    ["48", "81"] => "2Release",
    ["48", "82"] => "4Release",
    ["48", "83"] => "6Release",
    ["48", "A2"] => "RDSRelease",
    ["48", "A1"] => "AMRelease",
    ["48", "A3"] => "ModeRelease",
    ["48", "A0"] => "SelectRelease",
    ["48", "80"] => "NextTrackRelease",
    ## Volume Knob
    ["48", "06"] => "KnobPress",
    ["48", "46"] => "KnobHold",
    ["48", "86"] => "KnobRelease",
    ["32", "10"] => "KnobRotateLeftSpeed1",
    ["32", "20"] => "KnobRotateLeftSpeed2",
    ["32", "30"] => "KnobRotateLeftSpeed3",
    ["32", "40"] => "KnobRotateLeftSpeed4",
    ["32", "50"] => "KnobRotateLeftSpeed5",
    ["32", "60"] => "KnobRotateLeftSpeed6",
    ["32", "70"] => "KnobRotateLeftSpeed7",
    ["32", "80"] => "KnobRotateLeftSpeed8",
    ["32", "90"] => "KnobRotateLeftSpeed9",
    ["32", "11"] => "KnobRotateRightSpeed1",
    ["32", "21"] => "KnobRotateRightSpeed2",
    ["32", "31"] => "KnobRotateRightSpeed3",
    ["32", "41"] => "KnobRotateRightSpeed4",
    ["32", "51"] => "KnobRotateRightSpeed5",
    ["32", "61"] => "KnobRotateRightSpeed6",
    ["32", "71"] => "KnobRotateRightSpeed7",
    ["32", "81"] => "KnobRotateRightSpeed8",
    ["32", "91"] => "KnobRotateRightSpeed9",

    # This is sent from the CD Changer
    ["02", "01"] => "CDChangerConnectedResponse"
  },

  # Hash containing messages that other devices can send the DSP Amplifier
  "DSP" => {
    # From the RAD
    ["01"] => "DSPStatusRequest"
  },

  # Hash containing messages that other devices can send the DSP Amplifier
  "CDD" => {
    # From the RAD
    ["01"] => "FrontCDStatusRequest"
  },

  # Hash containing messages that other devices can send the Telephone Module (ULF)
  "TEL" => {
    # From the Steering Wheel Controls
    ["3B", "80"] => "SpeechKeyPress",
    ["3B", "A0"] => "SpeechKeyRelease",
    ["3B", "40"] => "RTPress",
    ["A2", "00", "00"] => "CurrentLocationCoordinates",
    ["A4", "00", "01"] => "CurrentLocationSuburb",
    ["A4", "00", "02"] => "CurrentLocationStreetAndNumber",
    ["A9", "0A", "30", "30"] => "CurrentPhoneStatusRequest",
    ["A9", "03", "30", "30"] => "CurrentNetworkConnectedStatusRequest"
  },

  # Messages that other devices can send the Navigation Computer
  "NAV" => {
    # From the Board Monitor
    # Knob
    ["48", "05"] => "KnobPress",
    ["48", "45"] => "KnobHold",
    ["48", "85"] => "KnobRelease",
    ["49", "10"] => "KnobRotateLeftSpeed1",
    ["49", "20"] => "KnobRotateLeftSpeed2",
    ["49", "30"] => "KnobRotateLeftSpeed3",
    ["49", "40"] => "KnobRotateLeftSpeed4",
    ["49", "50"] => "KnobRotateLeftSpeed5",
    ["49", "60"] => "KnobRotateLeftSpeed6",
    ["49", "70"] => "KnobRotateLeftSpeed7",
    ["49", "80"] => "KnobRotateLeftSpeed8",
    ["49", "90"] => "KnobRotateLeftSpeed9",
    ["49", "11"] => "KnobRotateRightSpeed1",
    ["49", "21"] => "KnobRotateRightSpeed2",
    ["49", "31"] => "KnobRotateRightSpeed3",
    ["49", "41"] => "KnobRotateRightSpeed4",
    ["49", "51"] => "KnobRotateRightSpeed5",
    ["49", "61"] => "KnobRotateRightSpeed6",
    ["49", "71"] => "KnobRotateRightSpeed7",
    ["49", "81"] => "KnobRotateRightSpeed8",
    ["49", "91"] => "KnobRotateRightSpeed9"
  },

  "GT" => {
    ["23", "62", "10", "03", "20"] => "WriteToTitle",     # This is the big text area as part of the banner at the top left of the screen.
    ["A5", "62", "01"] => "WriteToHeading",
    ["A5", "61", "01"] => "PartialWriteComplete",
    ["21", "61", "00"] => "PartialWriteToLowerField",
    ["A5", "60", "01", "00"] => "ClearLowerFields",
    ["01"] => "GTStatusRequest",
    ["02", "30"] => "GeneralDeviceStatusReply",

    # Sent from the Board Monitor
    ["02", "30", "FD"] => "BoardMonitorStatusReply",

    # Sent from the TV Module (VID)
    ["02", "00", "D0"] => "VideoModuleStatusReply"
  },

  "BM" => {
    # Sent from the Video Controller (GT)
    ["01"] => "BoardMonitorStatusRequest"

  },
  "CDC" => {
    # This is sent from the Radio (BM53, BM54, and a couple of others)
    ["38", "00", "00"] => "CDChangerStatusRequest"
  },
  "VID" => {
    ["01"] => "VideoModuleStatusRequest"
  },

  "D0" => {
    # Sent from the RLS advising the status of the light outside.
    ["59"] => "LightingConditionsUpdate"
  }
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
