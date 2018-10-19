# Ruby Library for the Diagnostics Query Command Set


class DIA
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    # Decoding a message
    #puts "[DIA] - Setting Message Decode Variables"
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

  DIAStaticMessagesIN = {
    # Diagnostic Query Replies
  ["A0"] => "Diagnostics Request Recieved"
  }

  DIAFunctionsIN = {
  }


  def decodeMessage
    # Returns message as a string
    bytesCheck = []
    byteCounter = 0
    @messageData.each { |currentByte|
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      if DIAStaticMessagesIN.key?(bytesCheck) == true
        return "#{DIAStaticMessagesIN.fetch(@messageData)}"
      elsif DIAFunctionsIN.key?(bytesCheck) == true
        for i in 1..byteCounter do
          @messageData.shift # Remove the 'function' bits from the front of the array, leaving the bits to process.
        end
        # XXXFunctionsIN.fetch(bytesCheck)[0] = the name of the function
        # XXXFunctionsIN.fetch(bytesCheck)[1] = the method's name for that function.
        # Do that thing here
      end
    }
    return "--> Unknown Message"
  end
end
