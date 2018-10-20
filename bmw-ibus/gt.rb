# Ruby Library for the Graphics Driver (for the Board Monitor Text)


class GT
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    @sourceDeviceName = sourceDeviceName
    @messageData = messageData
    @messageLength = messageLength
  end

  def setEncode(field, text)
    @field = messagePriority
    @text = textLength
  end

  StaticMessagesIN = {
    ["01"] => "GT Status Request",
    ["02", "30"] => "General Device Status Reply(?)",
    ["A5", "61", "01"] => "Partial Write Complete",

    # Sent from the Board Monitor
    ["02", "30", "FD"] => "Board Monitor Connected and Ready",

    # Sent from the TV Module (VID)
    ["02", "00", "D0"] => "Video Module Connected and Ready"
  }

  FunctionsIN = {
    ["23", "62", "10"] => ["Write to Title", "readTitle"],    # This is the big text area as part of the banner at the top left of the screen.
    ["A5", "62"] => ["Write To Heading", "readHeading"],
    ["21", "61", "00"] => ["Partial Write To Lower Field", "readLower"],
    ["A5", "60", "01", "00"] => ["Clear Lower Fields", "clearLower"]
  }

  HeadingFields = {
    ["41"] => "HeadingField1", # 5 Characters
    ["42"] => "HeadingField2", # 5 Characters
    ["43"] => "HeadingField3", # 5 Characters
    ["44"] => "HeadingField4", # 5 Characters
    ["45"] => "HeadingField5", # 7 Characters
    ["46"] => "HeadingField6", # 20 Characters
    ["47"] => "HeadingField7" # 20 Characters
  }

  LowerFields = {
    #TODO: Work out what these are.
  }

  Layouts = {
    ["A5", "62"] => "RadioDisplay" # 14 Characters
  }

  # Not sure what this is
  FC2 = {
    ["01"] => "01"
  }

  TransmissionType = {
    ["00"] => "Continues Next Packet.."
    ["FF"] => "Transmission Complete"
  }


  def readTitle(data)
    currentBit = ""
    messageLayout = ""
    messageFlags = "None Set"
    messageField = "Title"
    messageASCII = ""
    # Determine Flags
    #TODO

    #Determine Layout
    currentBit = data.shift
    if Layouts.key?(currentBit) == true
      messageLayout = Layouts.fetch(currentBit)
    else
      messageLayout = "Unknown Layout (#{currentBit})"
    end

    # Decode Hex
    messageASCII = toAscii2(data)

    return "Field: #{messageField}, Content: #{messageASCII}. Layout: #{messageLayout}, Flags: #{messageFlags}"
  end

  def toAscii2(hex)
    if hex.length > 2
      hex = hex.join("")
    end
    hex = [hex]
    return hex.pack('H*')
  end

  def readHeading(data)
    puts "It's a Heading, Harry"
    puts "#{data}"
  end

  def readLower(data)
    puts "It's a Lower Text Field, Harry"
    puts "#{data}"
  end

  def clearLower(data)
    "Puts: Clearing Lower Fields, I think?"
    puts "#{data}"
  end

  def decodeMessage
    # Returns message as a string
    bytesCheck = []
    byteCounter = 0
    decodedMessage = ""
    functionToPerform = ""
    @messageData.each { |currentByte|
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      if StaticMessagesIN.key?(bytesCheck) == true
        decodedMessage = "#{StaticMessagesIN.fetch(@messageData)}"
      elsif FunctionsIN.key?(bytesCheck) == true
        for i in 1..byteCounter do
          @messageData.shift # Push the 'function' bits off the front of the array, leaving the message content.
        end
        #puts "--> Words: #{FunctionsIN.fetch(bytesCheck)[0]}"
        #puts "--> Function: #{FunctionsIN.fetch(bytesCheck)[1]}"
        functionToPerform = FunctionsIN.fetch(bytesCheck)[1]
        decodedMessage = send(functionToPerform, @messageData) # Execute whatever functionToPerform ended up as, and use @messageData as a parameter.
        break
      end
    }
    if decodedMessage == ""
      decodedMessage = "Unknown Message. Bytes: #{@messageData}"
    end
    return "#{decodedMessage}"
  end
end
