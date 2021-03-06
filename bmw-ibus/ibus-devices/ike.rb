# Ruby Library for the Instrument Cluster (IKE)


# The Class
class IKE
  # What happens when a new IKE object is created
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    # Decoding a message
    #puts "[IKE] - Setting Message Decode Variables"
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

  StaticMessagesIN = {
    # Messages that devices can send to the Instrument CLuster
    ["10"] => "Requesting Terminal Status",
    ["12"] => "Requesting Sensor Data",
    ["01"] => "Requesting Cluster Status",

    # From the GT to display OBC Data
    ["41", "03", "01"] => "Outside Temperature Request",
    ["41", "0A", "01"] => "Average Speed Request",
    ["43", "09", "01"] => "Current User-Set Speed Limit",
    ["43", "0E", "01"] => "Current Timer Value",
    # Sent from the Video Controller (presumably to know whether to show the logo when a door is opened)
    ["10"] => "Ignition Status Request",

  }
  FunctionsIN = {
    ["1A"] => ["Cluster Message","clusterMessageDecoder"]
  }


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

  def clusterMessageBuilder
    # Creates the Message to send to the cluster.
    ## Options for the messagePriority:
    ## - ClearMessage: Clears the current alert.
    ## - Priority3: Low priority message
    ## - Priority2: Medium priority message
    ## - Priority1: High priority message
    ## Options for textLength
    ## - LengthSpecified
    ## - LengthNotSpecified
    ## Options for the displayType:
    ## - NoChange: Display is not changed
    ## - NoText: Display is cleared
    ## - Text: Text is shown on the display
    ## - TextFlashing: Text is shown flashing (once per second) on the display
    ## Options for the gongType:
    ## - NoGong: No gong is sounded: Example: Changing radio station using the steering wheel controls.
    ## - SilenceGong: Switch gong off if currently 'gonging'
    ## - SingleT3: A single standard Gong tone. Example: Speed limit exceeded
    ## - ConstantT3: The standard gong tone is sounded every 1.5 seconds for the duration of the message. Example: Key In Ignition alert.
    ## - DoubleT3: The standard gong tone is sounded twice (0.75 seconds apart). Example: Handbreak on alert.
    ## - SingleT2: A single 'check control' gong tone is sounded.
    ## - TripleT3: Three short standard gong tones are sounded. Example: Memo alert for the tine.
    ## - SingleT1: A single lower-pitched gong tone is sounded. Example: CODE
    ## - NOTE: Pass in messageContent as array of hex. EG: ["AA", "BB", "CC"]

    byte1 = "00000000"
    byte2 = "00000000"
    case @messagePriority
    when "ClearMessage"
      byte1[5] = "0"
      byte1[6] = "0"
      byte1[7] = "0"
    when "Priority3"
      byte1[5] = "1"
      byte1[6] = "0"
      byte1[7] = "1"
    when "Priority2"
      byte1[5] = "1"
      byte1[6] = "1"
      byte1[7] = "1"
    when "Priority1"
      byte1[5] = "1"
      byte1[6] = "0"
      byte1[7] = "1"
    when "Unknown"
      byte1[5] = "0"
      byte1[6] = "0"
      byte1[7] = "1"
    end

    case @textLength
    when "LengthSpecified"
      byte1[4] = "0"
    when "LengthNotSpecified"
      byte1[4] = "1"
    end

    case @displayType
    when "NoChange"
      byte1[2] = "0"
    when "NoText"
      byte1[2] = "1"
      byte2[6] = "0"
      byte2[7] = "0"
    when "Text"
      byte1[2] = "1"
      byte2[6] = "1"
      byte2[7] = "0"
    when "TextFlashing"
      byte1[2] = "1"
      byte2[6] = "1"
      byte2[7] = "1"
    end

    case @gongType
    when "NoGong"
      byte1[3] = "0"
    when "SilenceGong"
      byte1[3] = "1"
      byte2[2] = "0"
      byte2[3] = "0"
      byte2[4] = "0"
      byte2[5] = "0"
    when "SingleT3"
      byte1[3] = "1"
      byte2[2] = "0"
      byte2[3] = "0"
      byte2[4] = "0"
      byte2[5] = "1"
    when "ConstantT3"
      byte1[3] = "1"
      byte2[2] = "0"
      byte2[3] = "0"
      byte2[4] = "1"
      byte2[5] = "0"
    when "DoubleT3"
      byte1[3] = "1"
      byte2[2] = "0"
      byte2[3] = "0"
      byte2[4] = "1"
      byte2[5] = "1"
    when "SingleT2"
      byte1[3] = "1"
      byte2[2] = "0"
      byte2[3] = "1"
      byte2[4] = "0"
      byte2[5] = "1"
    when "SingleT1"
      byte1[3] = "1"
      byte2[2] = "0"
      byte2[3] = "1"
      byte2[4] = "1"
      byte2[5] = "0"
    # Missing TripleT3
    end

    puts "Bits (Gong and Message Type): #{byte1} #{byte2}"
    messageContent = messageContent.toHex
    byte1 = byte1.pack('H*')
    byte2 = byte2.pack('H*')
    puts "Hex (Gong and Message Type): #{byte1} #{byte2}"
    puts "Message Content: #{messageContent}"
    finishedMessage = []
    finishedMessage[0] = byte1
    finishedMessage[1] = byte2
    messageContent.each { |x|
      puts "Current Array Element: #{x}"
      messageContent.push(messageContent.fetch(x))
      puts "Size of messageContent: #{messageContent.length}"
    }
    puts "Finished Message: #{finishedMessage}"
    return finishedMessage
  end

  def toBinary(hexChomp)
    puts "[!] - Here's the Binary: #{hexChomp.hex.to_s(2).rjust(num.size*4, '0')}"
    return hexChomp.hex.to_s(2).rjust(num.size*4, '0')
  end

  def clusterMessageDecoder(bytes)
    # TODO: Write toBinary method or find another way to convert a hex byte to binary.
    byte1 = bytes[0].shift.toBinary
    byte2 = bytes[1].shift.toBinary
    messagePriority = ""
    textLength = ""
    displayType = ""
    gongType = ""
    messageContent = bytes.toAscii2

    # Message Priority
    case
    when byte1[5] == "0" && byte1[6] == "0" && byte1[7] == "0"
      messagePriority = "ClearMessage"
    when byte1[5] == "1" && byte1[6] == "0" && byte1[7] == "1"
      messagePriority = "Priority3"
    when byte1[5] == "1" && byte1[6] == "1" && byte1[7] == "1"
      messagePriority =  "Priority2"
    when byte1[5] == "1" && byte1[6] == "0" && byte1[7] == "1"
      messagePriority =  "Priority1"
    when byte1[5] == "0" && byte1[6] == "0" && byte1[7] == "1"
      messagePriority = "Unknown"
    end

    # Text Length
    case
    when byte1[4] == "0"
      textLength = "LengthSpecified"
    when byte1[4] == "1"
      textLength = "LengthNotSpecified"
    end

    # Display Type
    case
    when byte1[2] == "0"
      displayType = "NoChange"
    when byte1[2] == "1" && byte2[6] == "0" && byte2[7] == "0"
      displayType = "NoText"
    when byte1[2] == "1" && byte2[6] == "1" && byte2[7] == "0"
      displayType = "Text"
    when byte1[2] == "1" && byte2[6] == "1" && byte2[7] == "1"
      displayType = "TextFlashing"
    end

    # Gong Type
    case
    when byte1[3] == "0"
      gongType = "NoGong"
    when byte1[3] == "1" && byte2[2] == "0" && byte2[3] == "0" && byte2[4] == "0" && byte2[5] == "0"
      gongType = "SilenceGong"
    when byte1[3] == "1" && byte2[2] == "0" && byte2[3] == "0" && byte2[4] == "0" && byte2[5] == "1"
      gongType = "SingleT3"
    when byte1[3] == "1" && byte2[2] == "0" && byte2[3] == "0" && byte2[4] == "1" && byte2[5] == "0"
      gongType = "ConstantT3"
    when byte1[3] == "1" && byte2[2] == "0" && byte2[3] == "0" && byte2[4] == "1" && byte2[5] == "1"
      gongType = "DoubleT3"
    when byte1[3] == "1" && byte2[2] == "0" && byte2[3] == "1" && byte2[4] == "0" && byte2[5] == "1"
      gongType = "SingleT2"
    when byte1[3] == "1" && byte2[2] == "0" && byte2[3] == "1" && byte2[4] == "1" && byte2[5] == "0"
      gongType = "SingleT1"
    end
    #puts "Cluster Message - Priority: #{messagePriority}, Text Length: #[textLength], Display Type: #{displayType}, Gong Type: #{gongType}. Message Content: #{messageContent}"
    return [messagePriority, textLength, displayType, gongType, messageContent]
  end
end
