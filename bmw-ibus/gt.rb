# Ruby Library for the Graphics Driver (for the Board Monitor Text)


class GT
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    # Decoding a message
    #puts "[GT] - Setting Message Decode Variables"
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

  GTStaticMessagesIN = {
    ["23", "62", "10", "03", "20"] => "Write to Title",     # This is the big text area as part of the banner at the top left of the screen.
    ["A5", "62", "01"] => "Write To Heading",
    ["A5", "61", "01"] => "Partial Write Complete",
    ["21", "61", "00"] => "Partial Write To Lower Field",
    ["A5", "60", "01", "00"] => "Clear Lower Fields",
    ["01"] => "GT Status Request",
    ["02", "30"] => "General Device Status Reply(?)",

    # Sent from the Board Monitor
    ["02", "30", "FD"] => "Board Monitor Connected and Ready",

    # Sent from the TV Module (VID)
    ["02", "00", "D0"] => "Video Module Connected and Ready"
  }

  GTFunctionsIN = {
  }


  def decodeMessage
    # Returns message as a string
    bytesCheck = []
    byteCounter = 0
    @messageData.each { |currentByte|
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      if GTStaticMessagesIN.key?(bytesCheck) == true
        return "#{GTStaticMessagesIN.fetch(@messageData)}"
      elsif GTFunctionsIN.key?(bytesCheck) == true
        for i in 1..byteCounter do
          @messageData.shift # Remove the 'function' bits from the front of the array, leaving the bits to process.
        end
        # XXXFunctionsIN.fetch(bytesCheck)[0] = the name of the function
        # XXXFunctionsIN.fetch(bytesCheck)[1] = the method's name for that function.
        # Do that thing here
      end
    }
return "--> Unknown Message. #{@messageData}"

  end
end
