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

  NAVStaticMessagesIN = {
    # From the Board Monitor
    # Knob
    ["48", "05"] => "Knob Pressed",
    ["48", "45"] => "Knob Held",
    ["48", "85"] => "Knob Released",
    ["49", "10"] => "Knob Turned Left (Speed 1)",
    ["49", "20"] => "Knob Turned Left (Speed 2)",
    ["49", "30"] => "Knob Turned Left (Speed 3)",
    ["49", "40"] => "Knob Turned Left (Speed 4)",
    ["49", "50"] => "Knob Turned Left (Speed 5)",
    ["49", "60"] => "Knob Turned Left (Speed 6)",
    ["49", "70"] => "Knob Turned Left (Speed 7)",
    ["49", "80"] => "Knob Turned Left (Speed 8)",
    ["49", "90"] => "Knob Turned Left (Speed 9)",
    ["49", "11"] => "Knob Turned Right (Speed 1)",
    ["49", "21"] => "Knob Turned Right (Speed 2)",
    ["49", "31"] => "Knob Turned Right (Speed 3)",
    ["49", "41"] => "Knob Turned Right (Speed 4)",
    ["49", "51"] => "Knob Turned Right (Speed 5)",
    ["49", "61"] => "Knob Turned Right (Speed 6)",
    ["49", "71"] => "Knob Turned Right (Speed 7)",
    ["49", "81"] => "Knob Turned Right (Speed 8)",
    ["49", "91"] => "Knob Turned Right (Speed 9)"
  }

  NAVFunctionsIN = {
  }


  def decodeMessage
    # Returns message as a string
    bytesCheck = []
    byteCounter = 0
    @messageData.each { |currentByte|
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      if NAVStaticMessagesIN.key?(bytesCheck) == true
        return "#{NAVStaticMessagesIN.fetch(@messageData)}"
      elsif NAVFunctionsIN.key?(bytesCheck) == true
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
