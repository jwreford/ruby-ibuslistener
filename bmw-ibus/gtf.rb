# Ruby Library for the Graphics Driver (for the Board Monitor Text)


class GTF
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    @sourceDeviceName = sourceDeviceName
    @messageData = messageData
    @messageLength = messageLength
  end

  StaticMessagesIN = {
  }

  FunctionsIN = {
    ["AB"] => ["Rear Display Status Request", "requestDecoder"]
  }

  Statuses = {
    ["21"] => "Status Request (?)"
  }

  def requestDecoder(hexRequest)
    if Statuses.key?([hexRequest]) == true
      return "#{Statuses.fetch([currentBit]}"
    else
      return "Unknown Request (#{hexRequest})"
    end
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
