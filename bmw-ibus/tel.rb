# Ruby Library for the Telephone Module


class TEL
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    # Decoding a message
    #puts "[TEL] - Setting Message Decode Variables"
    @sourceDeviceName = sourceDeviceName
    @messageData = messageData
    @messageLength = messageLength
  end

  def setEncode(messagePriority, textLength, displayType, gongType, messageContent)
    @messagePriority = messagePriority
    @textLength = textLength
    @displayType = displayType
    @gongType = gongType
    @messageContent = messageContent
  end

  StaticMessagesIN = {
    # Messages that devices can send to the Telephone
    ["3B", "80"] => "Speech Key Pressed (Steering Wheel)",
    ["3B", "A0"] => "Speech Key Released (Steering Wheel)",
    ["3B", "40"] => "R/T Key Pressed (Steering Wheel)",
    ["A9", "0A", "30", "30"] => "Phone Status Request",
    ["A9", "03", "30", "30"] => "Cell Network Status Request"

  }
  FunctionsIN = {
    ["A2", "00", "00"] => ["Current Location: Coordinates", "coordinateDecoder"],
    ["A4", "00", "01"] => ["Current Location: Suburb", "toAscii2"],
    ["A4", "00", "02"] => ["Current Location: Street Address", "toAscii2"]
  }

  # Decode the GPS Coordinates
  def coordinateDecoder(coordinates)
    # TODO: Work out how to decode the coordinates.
    return "000 000"
  end

  # Convert Hex to ASCII
  def toAscii2(hex)
    if hex.length > 2
      hex = hex.join("")
    end
    hex = [hex]
    return hex.pack('H*')
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
