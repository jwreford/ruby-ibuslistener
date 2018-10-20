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
    decodedMessage = ""
    puts "[-] In Decode Message (TEL)"
    @messageData.each { |currentByte|
      " "
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      if TELStaticMessagesIN.key?(bytesCheck) == true
        decodedMessage = "#{TELStaticMessagesIN.fetch(@messageData)}"
      elsif TELFunctionsIN.key?(bytesCheck) == true
        for i in 1..byteCounter do
          @messageData.shift # Push the 'function' bits off the front of the array, leaving the message content.
        end
        puts "[2] --> Array:  #{GLOFunctionsIN.fetch(bytesCheck)}. Length: #{GLOFunctionsIN.fetch(bytesCheck).length}"
        puts "[2] --> Words: #{GLOFunctionsIN.fetch(bytesCheck)[0]}"
        puts "[2] --> Function: #{GLOFunctionsIN.fetch(bytesCheck)[1]}"
        puts "[2] --> Bytes Check: #{bytesCheck}. Message Data: #{@messageData}"
        # Need to write the code to process messages that make it to here.
        decodedMessage = @messageData
        return "#{@messageData}"
        puts "[2] --> After the Return: Decoded Message Variable: #{decodedMessage}"
        break
        puts "After the Break"
      end
    }
    if decodedMessage == ""
      puts "decodeMessage was empty, apparently? Setting to unknown."
      decodedMessage = "Unknown Message. Bytes: #{@messageData}"
    end
    puts "[!] Didn't return? Decoded Message Variable (before return): #{decodedMessage}"
    return "#{decodedMessage}"
  end
end
