# Ruby Library for the Telephone Module


class TEL
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    # Decoding a message
    puts "[TEL] - Setting Message Decode Variables"
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

  TELStaticMessagesIN = {
    # Messages that devices can send to the Telephone
    ["3B", "80"] => "Speech Key Pressed (Steering Wheel)",
    ["3B", "A0"] => "Speech Key Released (Steering Wheel)",
    ["3B", "40"] => "R/T Key Pressed (Steering Wheel)",
    ["A9", "0A", "30", "30"] => "Phone Status Request",
    ["A9", "03", "30", "30"] => "Cell Network Status Request"

  }
  TELFunctionsIN = {
    ["A2", "00", "00"] => ["Current Location: Coordinates", "coordinateDecoder"],
    ["A4", "00", "01"] => ["Current Location: Suburb", "toAscii2"],
    ["A4", "00", "02"] => ["Current Location: Street Address", "toAscii2"]
  }


  def decodeMessage
    # Returns message as a string
    bytesCheck = []
    byteCounter = 0
    @messageData.each { |currentByte|
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      puts "Byte Check: #{bytesCheck}"
      if TELStaticMessagesIN.key?(bytesCheck) == true
        puts "Message Data: #{@messageData}"
        if bytesCheck.length == @messageData.length
          puts "In IF"
          return "#{TELStaticMessagesIN.fetch(@messageData)}"
        else
          puts "Bytes Check #{bytesCheck.length} and Message Data #{@messageData.length} were different. I think that was supposed to be a function."
        end
      elsif TELFunctionsIN.key?(bytesCheck) == true
        for i in 1..byteCounter do
          @messageData.shift # Remove the 'function' bits from the front of the array, leaving the bits to process.
        end
        puts "--> Array:  #{TELFunctionsIN.fetch(bytesCheck)}. Length: #{TELFunctionsIN.fetch(bytesCheck).length}"
        puts "--> Words: #{TELFunctionsIN.fetch(bytesCheck)[0]}"
        puts "--> Function: #{TELFunctionsIN.fetch(bytesCheck)[1]}"
        return "#{TELFunctionsIN.fetch(bytesCheck)[0]}: TODO: Plug in Decoder"
        # Do that thing here
      end
    }
    return "--> Unknown Message"
  end
end
