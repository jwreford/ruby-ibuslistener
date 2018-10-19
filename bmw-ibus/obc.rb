# Ruby Library for the Onboard Computer Statistics and Data (Physically Within the IKE)


class OBC
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    # Decoding a message
    puts "[OBC] - Setting Message Decode Variables"
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

  OBCStaticMessagesIN = {
    # Messages that devices can send to the Telephone
    ["24", "01", "00"] => "Time",
    ["24", "02", "00"] => "Date",
    ["24", "03", "00"] => "Outside Temperature",
    ["24", "04", "00"] => "Fuel Consumption 1",
    ["24", "05", "00"] => "Fuel Consumption 2",
    ["24", "06", "00"] => "Range",
    ["24", "07", "00"] => "Distance To Destination",
    ["24", "08", "00"] => "Time To Destination",
    ["24", "09", "00"] => "Speed Limit",
    ["24", "0A", "00"] => "Average Speed",
    ["24", "0E", "00"] => "Timer",
    ["24", "0F", "00"] => "Auxilliary Air Circulation Timer 1",
    ["24", "10", "00"] => "AuxHeating Air Circulation Timer 2",
    ["24", "1A", "00"] => "Unknown Function",
    # Not sure about this one
    ["2B"] => "Board Monitor LED"
  }

  OBCFunctionsIN = {
  }


  def decodeMessage
    # Returns message as a string
    bytesCheck = []
    byteCounter = 0
    @messageData.each { |currentByte|
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      if OBCStaticMessagesIN.key?(bytesCheck) == true
        return "#{OBCStaticMessagesIN.fetch(@messageData)}"
      elsif OBCFunctionsIN.key?(bytesCheck) == true
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
