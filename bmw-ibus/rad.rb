# Ruby Library for the Instrument Cluster (IKE)

class RAD
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    # Decoding a message
    puts "[RAD] - Setting Message Decode Variables"
    @sourceDeviceName = sourceDeviceName
    @messageData = messageData
    @messageLength = messageLength
  end

  RADStaticMessagesIN = {
    # Messages that other devices can send to the Radio
      # Diagnostics Data
      ["00"] => "DiagnosticsReadID",
      ["04", "00"] => "DiagnosticsReadFaultMemory",

      # From the CD Changer. This is a bit of a guess - I might be stripping part of the message off unintentionally.
      ["39", "00", "02", "00"] => "CDChangerStatusReply",

      # From the Board Monitor to the Radio
      ["01"] => "RadioStatusRequest",

      # From the Steering Wheel Controls
      ["32", "10"] => "VolumeDownPress",
      ["32", "11"] => "VolumeUpPress",
      ["3B", "01"] => "NextTrackPress",
      ["3B", "21"] => "NextTrackRelease",
      ["3B", "08"] => "PreviousTrackPress",
      ["3B", "28"] => "PreviousTrackRelease",

      # From the Board Monitor
      ## Buttons
      ["48", "14"] => "ReverseTapePress",
      ["48", "11"] => "1Press",
      ["48", "12"] => "3Press",
      ["48", "13"] => "5Press",
      ["48", "32"] => "TPPress",
      ["48", "31"] => "FMPress",
      ["48", "33"] => "DolbyPress",
      ["48", "04"] => "TonePress",
      ["48", "10"] => "PreviousTrackPress",
      ["48", "30"] => "MenuPress",
      ["48", "54"] => "ReverseTapeHold",
      ["48", "51"] => "1Hold",
      ["48", "52"] => "3Hold",
      ["48", "53"] => "5Hold",
      ["48", "72"] => "TPHold",
      ["48", "71"] => "FMHold",
      ["48", "73"] => "DolbyHold",
      ["48", "44"] => "ToneHold",
      ["48", "50"] => "PreviousTrackHold",
      ["48", "70"] => "MenuHold",
      ["48", "94"] => "ReverseTapeRelease",
      ["48", "91"] => "1Release",
      ["48", "92"] => "3Release",
      ["48", "93"] => "5Release",
      ["48", "B2"] => "TPRelease",
      ["48", "B1"] => "FMRelease",
      ["48", "84"] => "DolbyRelease",
      ["48", "90"] => "NextTrackRelease",
      ["48", "B0"] => "MenuRelease",
      ["48", "24"] => "EjectPress",
      ["48", "01"] => "2Press",
      ["48", "02"] => "4Press",
      ["48", "03"] => "6Press",
      ["48", "22"] => "RDSPress",
      ["48", "21"] => "AMPress",
      ["48", "23"] => "ModePress",
      ["48", "20"] => "SelectPress",
      ["48", "00"] => "NextTrackPress",
      ["48", "64"] => "EjectHold",
      ["48", "41"] => "2Hold",
      ["48", "42"] => "4Hold",
      ["48", "43"] => "6Hold",
      ["48", "62"] => "RDSHold",
      ["48", "61"] => "AMHold",
      ["48", "63"] => "ModeHold",
      ["48", "60"] => "SelectHold",
      ["48", "40"] => "NextTrackHold",
      ["48", "A4"] => "EjectRelease",
      ["48", "81"] => "2Release",
      ["48", "82"] => "4Release",
      ["48", "83"] => "6Release",
      ["48", "A2"] => "RDSRelease",
      ["48", "A1"] => "AMRelease",
      ["48", "A3"] => "ModeRelease",
      ["48", "A0"] => "SelectRelease",
      ["48", "80"] => "NextTrackRelease",
      ## Volume Knob
      ["48", "06"] => "KnobPress",
      ["48", "46"] => "KnobHold",
      ["48", "86"] => "KnobRelease",
      ["32", "10"] => "KnobRotateLeftSpeed1",
      ["32", "20"] => "KnobRotateLeftSpeed2",
      ["32", "30"] => "KnobRotateLeftSpeed3",
      ["32", "40"] => "KnobRotateLeftSpeed4",
      ["32", "50"] => "KnobRotateLeftSpeed5",
      ["32", "60"] => "KnobRotateLeftSpeed6",
      ["32", "70"] => "KnobRotateLeftSpeed7",
      ["32", "80"] => "KnobRotateLeftSpeed8",
      ["32", "90"] => "KnobRotateLeftSpeed9",
      ["32", "11"] => "KnobRotateRightSpeed1",
      ["32", "21"] => "KnobRotateRightSpeed2",
      ["32", "31"] => "KnobRotateRightSpeed3",
      ["32", "41"] => "KnobRotateRightSpeed4",
      ["32", "51"] => "KnobRotateRightSpeed5",
      ["32", "61"] => "KnobRotateRightSpeed6",
      ["32", "71"] => "KnobRotateRightSpeed7",
      ["32", "81"] => "KnobRotateRightSpeed8",
      ["32", "91"] => "KnobRotateRightSpeed9",

      # This is sent from the CD Changer
      ["02", "01"] => "CDChangerConnectedResponse"

  }
  RADFunctionsIN = {

  }


  def decodeMessage
    # Returns message as a string
    puts "[RAD] Message: #{@sourceDeviceName} -> #{@destinationDeviceName}: #{@messageData}"
    bytesCheck = []
    byteCounter = 0
    puts "Message Data Length: #{@messageData.length}"
    @messageData.each { |currentByte|
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      puts "Current Byte: #{currentByte}"
      puts "Byte Counter: #{byteCounter}"
      puts "Byte Check Array: #{bytesCheck}, #{bytesCheck.length}"
      if RADStaticMessagesIN.key?(bytesCheck) == true
        puts "In the if: Byte Check #{bytesCheck}, Byte Counter: #{byteCounter}"
        return "#{RADStaticMessagesIN.fetch(@messageData)}"
      elsif RADFunctionsIN.key?(bytesCheck) == true
        # IKEFunctionsIN.fetch(bytesCheck)[0] = the name of the function
        # IKEFunctionsIN.fetch(bytesCheck)[1] = the method's name for that function.
        # Do that thing here
      end
      @messageData.shift
    }
    return "--> Unknown Message"
  end
end
