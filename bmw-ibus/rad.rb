# Ruby Library for the RADIO

class RAD
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    # Decoding a message
    @sourceDeviceName = sourceDeviceName
    @messageData = messageData
    @messageLength = messageLength
  end

  RADStaticMessagesIN = {
    # Messages that other devices can send to the Radio
      # Diagnostics Data
      ["00"] => "Diagnostic: Reading ID",
      ["04", "00"] => "Diagnostic: Reading Fault Memory",

      # From the CD Changer. This is a bit of a guess - I might be stripping part of the message off unintentionally.
      #["39", "00", "02", "00"] => "CDChangerStatusReply",

      # From the Board Monitor to the Radio
      ["01"] => "Radio Status Request",
      ["4B", "05"] => "No Tape in Cassette Player",

      # From the Steering Wheel Controls
      ["32", "10"] => "Volume Down (Steering Wheel)",
      ["32", "11"] => "Volume Up (Steering Wheel)",
      ["3B", "01"] => "Next Track Pressed(Steering Wheel)",
      ["3B", "21"] => "Next Track Released (Steering Wheel)",
      ["3B", "08"] => "Previous Track Pressed (Steering Wheel)",
      ["3B", "28"] => "Previous Track Released (Steering Wheel)",

      # From the Board Monitor
      ## Buttons
      ["48", "14"] => "Tape Change Direction Pressed",
      ["48", "11"] => "1 Key Pressed",
      ["48", "12"] => "3 Key Pressed",
      ["48", "13"] => "5 Key Pressed",
      ["48", "32"] => "TP Pressed",
      ["48", "31"] => "FM Pressed",
      ["48", "33"] => "Audio Effects Pressed",
      ["48", "04"] => "Tone Pressed",
      ["48", "10"] => "Previous Track Pressed",
      ["48", "30"] => "Menu Pressed",
      ["48", "54"] => "Tape Change Direction Held Down",
      ["48", "51"] => "1 Key Held Down",
      ["48", "52"] => "3 Key Held Down",
      ["48", "53"] => "5 Key Held Down",
      ["48", "72"] => "TP Held Down",
      ["48", "71"] => "FM Held Down",
      ["48", "73"] => "Audio Effects Held Down",
      ["48", "44"] => "Tone Held Down",
      ["48", "50"] => "Previous Track Held Down",
      ["48", "70"] => "Menu Held Down",
      ["48", "94"] => "Tape Change Direction Released",
      ["48", "91"] => "1 Key Released",
      ["48", "92"] => "3 Key Released",
      ["48", "93"] => "5 Key Released",
      ["48", "B2"] => "TP Released",
      ["48", "B1"] => "FM Released",
      ["48", "84"] => "Audio Effects Released",
      ["48", "90"] => "Next Track Released",
      ["48", "B0"] => "Menu Released",
      ["48", "24"] => "Eject Pressed",
      ["48", "01"] => "2 Key Pressed",
      ["48", "02"] => "4 Key Pressed",
      ["48", "03"] => "6 Key Pressed",
      ["48", "22"] => "RDS Pressed",
      ["48", "21"] => "AM Pressed",
      ["48", "23"] => "Mode Pressed",
      ["48", "20"] => "Select Pressed",
      ["48", "00"] => "Next Track Pressed",
      ["48", "64"] => "Eject Held Down",
      ["48", "41"] => "2 Key Held Down",
      ["48", "42"] => "4 Key Held Down",
      ["48", "43"] => "6 Key Held Down",
      ["48", "62"] => "RDS Held Down",
      ["48", "61"] => "AM Held Down",
      ["48", "63"] => "Mode Held Down",
      ["48", "60"] => "Select Held Down",
      ["48", "40"] => "Next Track Held Down",
      ["48", "A4"] => "Eject Released",
      ["48", "81"] => "2 Key Released",
      ["48", "82"] => "4 Key Released",
      ["48", "83"] => "6 Key Released",
      ["48", "A2"] => "RDS Released",
      ["48", "A1"] => "AM Released",
      ["48", "A3"] => "Mode Released",
      ["48", "A0"] => "Select Released",
      ["48", "80"] => "Next Track Released",
      ## Volume Knob
      ["48", "06"] => "Volume Pressed",
      ["48", "46"] => "Volume Held Down",
      ["48", "86"] => "Volume Released",
      ["32", "10"] => "Volume Down (Speed 1)",
      ["32", "20"] => "Volume Down (Speed 2)",
      ["32", "30"] => "Volume Down (Speed 3)",
      ["32", "40"] => "Volume Down (Speed 4)",
      ["32", "50"] => "Volume Down (Speed 5)",
      ["32", "60"] => "Volume Down (Speed 6)",
      ["32", "70"] => "Volume Down (Speed 7)",
      ["32", "80"] => "Volume Down (Speed 8)",
      ["32", "90"] => "Volume Down (Speed 9)",
      ["32", "11"] => "Volume Up (Speed 1)",
      ["32", "21"] => "Volume Up (Speed 2)",
      ["32", "31"] => "Volume Up (Speed 3)",
      ["32", "41"] => "Volume Up (Speed 4)",
      ["32", "51"] => "Volume Up (Speed 5)",
      ["32", "61"] => "Volume Up (Speed 6)",
      ["32", "71"] => "Volume Up (Speed 7)",
      ["32", "81"] => "Volume Up (Speed 8)",
      ["32", "91"] => "Volume Up (Speed 9)",

      # This is sent from the CD Changer
      ["02", "01"] => "CD Changer Connected and Ready"

  }
  RADFunctionsIN = {
    # From the GT
    ["22", "0"] => ["Messages Received","messagesReceivedDecoder"]
  }

  def messagesReceivedDecoder(messagesHex)
    return "OK - Messages Recieved: #{toAscii2(messagesHex)}"
  end

  def toAscii2(hex)
    if hex.length > 2
      hex = hex.join("")
    end
    hex = [hex]
    return hex.pack('H*')
  end

  def decodeMessage
    # Returns message as a string
    bytesCheck = []
    byteCounter = 0
    @messageData.each { |currentByte|
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      if RADStaticMessagesIN.key?(bytesCheck) == true
        return "#{RADStaticMessagesIN.fetch(@messageData)}"
      elsif RADFunctionsIN.key?(bytesCheck) == true
        for i in 1..byteCounter do
          @messageData.shift # Push the 'function' bits off the front of the array, leaving the message content.
        end
        # IKEFunctionsIN.fetch(bytesCheck)[0] = the name of the function
        # IKEFunctionsIN.fetch(bytesCheck)[1] = the method's name for that function.
        # Do that thing here
      end
      #
    }
return "--> Unknown Message. #{@messageData}"

  end
end
