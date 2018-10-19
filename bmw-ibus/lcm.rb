# Ruby Library for the Light Control Module


class LCM
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    # Decoding a message
    puts "[LCM] - Setting Message Decode Variables"
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

  LCMStaticMessagesIN = {
    # From the Instrument Cluster usually
    ["13", "00", "13", "00", "00", "00", "00"] => "Reversing Signal",
    ["18", "06", "0E"] => "TV Not Permitted While Moving",
    ["18", "00", "07"] => "TV Permitted",
    # Sent from the RLS advising the status of the light outside.
    ["59"] => "Lighting Conditions Update"
  }

  LCMFunctionsIN = {
  }


  def decodeMessage
    # Returns message as a string
    bytesCheck = []
    byteCounter = 0
    @messageData.each { |currentByte|
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      if LCMStaticMessagesIN.key?(bytesCheck) == true
        return "#{LCMStaticMessagesIN.fetch(@messageData)}"
      elsif LCMFunctionsIN.key?(bytesCheck) == true
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
