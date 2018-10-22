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
    ["A2", "00"] => ["Current Location: Coordinates", "coordinateDecoder"],
    ["A4", "00", "01"] => ["Current Location: Suburb", "suburbDecoder"],
    ["A4", "00", "02"] => ["Current Location: Street Address", "streetDecoder"]
  }

  CardinalDirections = {
    ["0"] => "E",
    ["1"] => "S",
    ["2"] => "W",
    ["3"] => "N"
  }

  # Decode the GPS Coordinates
  def coordinateDecoder(coordinates)
    # Format is XX XX YY ZZ A, XX XX YY ZZ A # XX XX = Degrees, YY = Minutes, ZZ = Seconds, A = Cardinal Direction
    # The hex are treated as base 10 standard digits.
    degrees1 = ""
    minutes1 = 0
    seconds1 = 0
    decimalSeconds1 = 0
    cardinalDirection1 = ""
    degrees2 = ""
    minutes2 = 0
    seconds2 = 0
    decimalSeconds2 = 0
    cardinalDirection2 = ""
    tempSecondsArray = []
    degrees1 = coordinates.shift
    degrees1 = degrees1 + coordinates.shift
    degrees1.sub!(/^0/, "")
    degrees1.sub!(/^0/, "")
    minutes1 = coordinates.shift
    seconds1 = coordinates.shift
    puts "Coordinates Array: #{coordinates}"
    puts "Coordinates at Index 0 #{coordinates[0]}"
    puts tempSecondsArray
    tempSecondsArray = coordinates.shift.scan(/./)
    puts tempSecondsArray
    decimalSeconds1 = tempSecondsArray[0]
    cardinalDirection1 = CardinalDirections.fetch([tempSecondsArray[1]])
    tempSecondsArray = []
    degrees2 = coordinates.shift
    degrees2 = degrees2 + coordinates.shift
    degrees2.sub!(/^0/, "")
    degrees2.sub!(/^0/, "")
    minutes2 = coordinates.shift
    seconds2 = coordinates.shift
    tempSecondsArray = coordinates.shift.scan(/./)
    decimalSeconds2 = tempSecondsArray[0]
    cardinalDirection2 = CardinalDirections.fetch([tempSecondsArray[1]])
    return "#{degrees1}° #{minutes1}' #{seconds1}.#{decimalSeconds1}\" #{cardinalDirection1}, #{degrees2}° #{minutes2}' #{seconds2}.#{decimalSeconds2}\" #{cardinalDirection2}"
  end

  def suburbDecoder(locationHex)
      return "City / Suburb: #{toAscii2(locationHex)}"
  end

  def streetDecoder(locationHex)
      return "Street: #{toAscii2(locationHex)}"
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
