# Ruby Library for the On-Board Monitor


class BM
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    # Decoding a message
    #puts "[BM] - Setting Message Decode Variables"
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

  BMStaticMessagesIN = {
    # Sent from the Video Controller (GT)
    ["01"] => "Board Monitor Status Request"
  }

  BMFunctionsIN = {
  }


  def decodeMessage
    # Returns message as a string
    bytesCheck = []
    byteCounter = 0
    @messageData.each { |currentByte|
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      if BMStaticMessagesIN.key?(bytesCheck) == true
        return "#{BMStaticMessagesIN.fetch(@messageData)}"
      elsif BMFunctionsIN.key?(bytesCheck) == true
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
