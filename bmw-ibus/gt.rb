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
    ["02", "00", "D0"] => "Video Module Connected and Ready",

    # Sent from the Radio (RAD)
    ["46", "02"] => "Switch to Information Display",
    ["46", "0C"] => "Select Menu Off, Tone Menu Off (??)",
    ["46", "08"] => "Tone Menu Off (??)"
  }

  FunctionsIN = {
    ["23", "62", "10"] => ["Write to Title", "readTitle"],    # This is the big text area as part of the banner at the top left of the screen.
    ["A5", "62"] => ["Write To Heading", "readHeading"],
    ["21", "61", "00"] => ["Partial Write To Lower Field", "readLower"],
    ["A5", "60", "01", "00"] => ["Clear Lower Fields", "clearLower"],
    ["36"] => ["Audio Controls", "decodeAudioControls"]

  }

  HeadingFields = {
    ["41"] => "Heading Field 1 (Lower-Right)", # 5 Characters
    ["42"] => "Heading Field 2 (Upper-Right)", # 5 Characters
    ["43"] => "Heading Field 3", # 5 Characters
    ["44"] => "Heading Field 4", # 5 Characters
    ["45"] => "Heading Field 5 (Lower-Center)", # 7 Characters
    ["46"] => "Heading Field 6", # 20 Characters
    ["07"] => "Heading Field 7" # 20 Characters
  }

  LowerFields = {
    #TODO: Work out what these are.
  }

  Layouts = {
    ["01"] => "Radio Display"
  }

  # Not sure what this is
  FC2 = {
    ["01"] => "01"
  }

  TransmissionType = {
    ["00"] => "Continues Next Packet..",
    ["FF"] => "Transmission Complete"
  }

  # Sent from the RAD
  AudioStates = {
    ## Balance
    ["4F"] => "Left < 15",
    ["4E"] => "Left < 14",
    ["4D"] => "Left < 13",
    ["4C"] => "Left < 12",
    ["4B"] => "Left < 11", # Don't think this is used
    ["4A"] => "Left < 10",
    # ["XX"] => "Left < 9", ## Don't think there is a Left Balance of 9
    ["48"] => "Left < 8",
    ["47"] => "Left < 7", # Don't think this is used
    ["46"] => "Left < 6", # Don't think this is used
    ["45"] => "Left < 5",
    ["44"] => "Left < 4",
    ["43"] => "Left < 3",
    ["42"] => "Left < 2",
    ["41"] => "Left < 1",
    ["40"] => "Centre = 0",
    ["51"] => "Right > 1",
    ["52"] => "Right > 2",
    ["53"] => "Right > 3",
    ["54"] => "Right > 4",
    ["55"] => "Right > 5",
    ["56"] => "Right > 6", # Don't think this is used
    ["57"] => "Right > 7", # Don't think this is used
    ["58"] => "Right > 8",
    # ["XX"] => "Right > 9", ## Don't think there is a Right Balance of 9 either.
    ["5A"] => "Right > 10",
    ["5B"] => "Right > 11", # Don't think this is used
    ["5C"] => "Right > 12",
    ["5D"] => "Right > 13",
    ["5E"] => "Right > 14",
    ["5F"] => "Right > 15",

    ## Fader
    ["8F"] => "Front > 15",
    ["8E"] => "Front > 14",
    ["8D"] => "Front > 13",
    ["8C"] => "Front > 12",
    ["8B"] => "Front > 11", # Don't think this is used
    ["8A"] => "Front > 10",
    # ["XX"] => "Left < 9", ## Don't think there is a Left Balance of 9
    ["88"] => "Front > 8",
    ["87"] => "Front > 7", # Don't think this is used
    ["86"] => "Front > 6", # Don't think this is used
    ["85"] => "Front > 5",
    ["84"] => "Front > 4",
    ["83"] => "Front > 3",
    ["82"] => "Front > 2",
    ["81"] => "Front > 1",
    ["90"] => "Centre = 0",
    ["91"] => "Rear < 1",
    ["92"] => "Rear < 2",
    ["93"] => "Rear < 3",
    ["94"] => "Rear < 4",
    ["95"] => "Rear < 5",
    ["96"] => "Rear < 6", # Don't think this is used
    ["97"] => "Rear < 7", # Don't think this is used
    ["98"] => "Rear < 8",
    # ["XX"] => "Right > 9", ## Don't think there is a Right Balance of 9 either.
    ["9A"] => "Rear < 10",
    ["9B"] => "Rear < 11", # Don't think this is used
    ["9C"] => "Rear < 12",
    ["9D"] => "Rear < 13",
    ["9E"] => "Rear < 14",
    ["9F"] => "Rear < 15",

    ## Treble Adjustment
    ["DC"] => "Treble: -12",
    ["DA"] => "Treble: -10",
    ["D8"] => "Treble: -8",
    ["D6"] => "Treble: -6",
    ["D4"] => "Treble: -4",
    ["D2"] => "Treble: -2",
    ["D0"] => "Treble: Flat (0)",
    ["C2"] => "Treble: +2",
    ["C4"] => "Treble: +4",
    ["C6"] => "Treble: +6",
    ["C8"] => "Treble: +8",
    ["CA"] => "Treble: +10",
    ["CC"] => "Treble: +12",

    ## Bass Adjustment
    ["DC"] => "Bass: -12",
    ["7A"] => "Bass: -10",
    ["78"] => "Bass: -8",
    ["76"] => "Bass: -6",
    ["74"] => "Bass: -4",
    ["72"] => "Bass: -2",
    ["70"] => "Bass: Flat (0)",
    ["62"] => "Bass: +2",
    ["64"] => "Bass: +4",
    ["66"] => "Bass: +6",
    ["68"] => "Bass: +8",
    ["6A"] => "Bass: +10",
    ["6C"] => "Bass: +12"

  }

  def decodeAudioControls(hex)
    audioStateResponse = ""
    if AudioStates.key?(hex) == true
      audioStateResponse = "Audio Settings Changed: #{Layouts.fetch(hex)}"
    else
      audioStateResponse = "Audio State Changed: Unknown (#{hex})"
    end
    return audioStateResponse
  end


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

    if Layouts.key?([currentBit]) == true
      messageLayout = Layouts.fetch([currentBit])
    else
      messageLayout = "Unknown Layout (#{currentBit})"
    end
    # Decode Hex
    messageASCII = toAscii2(data)
    return "Writing to #{messageField} \"#{messageASCII}\". Layout: #{messageLayout}, Flags: #{messageFlags}"
  end

  def readHeading(data)
    currentBit = ""
    messageLayout = ""
    messageFlags = "None Set"
    messageField = ""
    messageASCII = ""
    # Determine Flags
    #TODO
    #Determine Layout
    currentBit = data.shift
    #puts "Layout Bit: #{currentBit}"
    if Layouts.key?([currentBit]) == true
      messageLayout = Layouts.fetch([currentBit])
    else
      messageLayout = "Unknown Layout (#{currentBit})"
    end
    # Determine Field
    currentBit = data.shift
    #puts "Heading Field Bit: #{currentBit}"
    if HeadingFields.key?([currentBit]) == true
      messageField = HeadingFields.fetch([currentBit])
    else
      messageField = "Unknown Field (#{currentBit})"
    end

    # Decode Hex
    messageASCII = toAscii2(data)

    return "Writing to #{messageField} \"#{messageASCII}\". Layout: #{messageLayout}, Flags: #{messageFlags}"
  end

  def toAscii2(hex)
    if hex.length > 2
      hex = hex.join("")
    end
    hex = [hex]
    return hex.pack('H*')
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
