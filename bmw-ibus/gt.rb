# Ruby Library for the Graphics Driver (for the Board Monitor Text)


class GT
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    @sourceDeviceName = sourceDeviceName
    @messageData = messageData
    @messageLength = messageLength
  end

  def setEncode(field, text)
    @field = messagePriority
    @text = textLength
  end

  GTStaticMessagesIN = {
    ["01"] => "GT Status Request",
    ["02", "30"] => "General Device Status Reply(?)",
    ["A5", "61", "01"] => "Partial Write Complete",

    # Sent from the Board Monitor
    ["02", "30", "FD"] => "Board Monitor Connected and Ready",

    # Sent from the TV Module (VID)
    ["02", "00", "D0"] => "Video Module Connected and Ready"
  }

  GTFunctionsIN = {
    ["23", "62", "10", "03", "20"] => ["Write to Title", "readFields", "title"],    # This is the big text area as part of the banner at the top left of the screen.
    ["A5", "62", "01"] => ["Write To Heading", "readFields", "heading"],
    ["21", "61", "00"] => ["Partial Write To Lower Field", "readFields", "lower"],
    ["A5", "60", "01", "00"] => ["Clear Lower Fields", "readFields","clearLower"]
  }

  def readFields(data)
    # TODO: Write this functionality.

    TextFields = {
      [""] => "Title", # 11 Characters
      ["01"] => "HeadingField1", # 5 Characters
      ["02"] => "HeadingField2", # 5 Characters
      ["03"] => "HeadingField3", # 5 Characters
      ["04"] => "HeadingField4", # 5 Characters
      ["05"] => "HeadingField5", # 7 Characters
      ["06"] => "HeadingField6", # 20 Characters
      ["07"] => "HeadingField7", # 20 Characters
      ["40"] => "LowerField1", # 14 Characters
      ["41"] => "LowerField2", # 14 Characters
      ["42"] => "LowerField3", # 14 Characters
      ["43"] => "LowerField4", # 14 Characters
      ["44"] => "LowerField5", # 14 Characters
      ["45"] => "LowerField6", # 14 Characters
      ["46"] => "LowerField7", # 14 Characters
      ["47"] => "LowerField8", # 14 Characters
      ["48"] => "LowerField9", # 14 Characters
      ["49"] => "LowerField10" # 14 Characters
    }

    if TextFields.key?(data[0]) == true
      return " [+] - I think they're writing to #{TextFields.fetch(data[0])}"
    else
      return "[-] Not sure what field was being written to."
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
