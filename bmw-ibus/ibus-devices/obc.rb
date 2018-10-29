# Ruby Library for the Onboard Computer Statistics and Data (Physically Within the IKE)


class OBC
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    # Decoding a message
    #puts "[OBC] - Setting Message Decode Variables"
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
    # Not sure about this one
    ["2B"] => "Board Monitor LED"
  }

  OBCFunctionsIN = {
    # Sent from the IKE, at least some of them.
    ["24"] => ["OBC Data Update", "obcDataUpdateDecoder"],
  }

  OBCDataTypes = {
    ["01", "00"] => ["Time"],
    ["02", "00"] => ["Date"],
    ["03", "00"] => ["Outside Temperature", "obcUpdateDecoder"],
    ["04", "00"] => ["Fuel Consumption 1", "obcUpdateDecoder"],
    ["05", "00"] => ["Fuel Consumption 2", "obcUpdateDecoder"],
    ["06", "00"] => ["Range", "obcUpdateDecoder"],
    ["07", "00"] => ["Distance To Destination", "obcUpdateDecoder"],
    ["08", "00"] => ["Time To Destination", "obcUpdateDecoder"],
    ["09", "00"] => ["Speed Limit", "obcUpdateDecoder"],
    ["0A", "00"] => ["Average Speed", "obcUpdateDecoder"],
    ["0E", "00"] => ["Timer", "obcUpdateDecoder"],
    ["0F", "00"] => ["Auxilliary Air Circulation Timer 1", "obcUpdateDecoder"],
    ["10", "00"] => ["AuxHeating Air Circulation Timer 2", "obcUpdateDecoder"],
    ["1A", "00"] => ["Unknown Function", "obcUpdateDecoder"]
  }



  def obcDataUpdateDecoder(hex)
    obcMessageTypeHex = []
    obcMessageTypeHex[0] = hex.shift
    obcMessageTypeHex[1] = hex.shift
    finalMessage
    ## send(toAscii2, hex)
    if OBCDataTypes.key?(obcMessageTypeHex) == true
      audioStateResponse = "OBC #{OBCDataTypes.fetch(obcMessageTypeHex)[0]}:  "
    else
      audioStateResponse = "OBC Data Update (#{hex})"
    end
    return audioStateResponse
  end

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
return "--> Unknown Message. #{@messageData}"

  end
end
