# Ruby Library for the Broadcast (Global) Messages

class GLO
  def initialize
    # Nothing to do here for now.
  end

  def setDecode(sourceDeviceName, messageData, messageLength)
    # Decoding a message
    @sourceDeviceName = sourceDeviceName
    @messageData = messageData
    @messageLength = messageLength
  end

  GLOStaticMessagesIN = {
    # Messages that other devices can send to ALL devices (Global)

    ## From the Instrument Cluster
    # Terminal Status
    ["11", "00"] => "TerminalKL30", # KL 0 = OFF (ignition off position)
    ["11", "01"] => "TerminalKLR", # KL R = ignition position 1 ("run" - some electonics & modules are powered up, such as the RAD, NAV and ULF)
    ["11", "03"] => "TerminalKLRAndKL15", # KL 15 = ignition position 2 ("accessory" - all electronics & modules are powered)
    ["11", "07"] => "TerminalKLRAndKL15AndKL50", # KL 30 = ignition position 3 (where the ignition defauts after starting the engine), # KL 50 = ignition start position

    ## From the Board Monitor.
    ["48", "08"] => "Phone Key Pressed",
    ["48", "48"] => "Phone Key Held Down",
    ["48", "88"] => "Phone Key Released",
    ["48", "45"] => "Menu Key Pressed",
    ["48", "85"] => "Menu Key Held Down",
    ["48", "85"] => "Menu Key Release",

    ## I think this is from the IHKA
    ["48", "07"] => "Auxilliary Heating Key Press",

    ## From the Cluster broadcasting some general information
    ["18"] => "Current Speed And RPM",

    ## From the Radio broadcasting that it's ready.
    ["02", "01", "D1"] => "Radio Connected and Ready",

    ## From Various Devices
    ["02", "00"] => "Device Connected and Ready",

    ## From the Cluster
    ["19", "80", "80"] => "Temperature Reading"

  }

  GLOFunctionsIN = {

  }


  def decodeMessage
    # Returns message as a string
    bytesCheck = []
    byteCounter = 0
    @messageData.each { |currentByte|
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      if GLOStaticMessagesIN.key?(bytesCheck) == true
        return "#{GLOStaticMessagesIN.fetch(@messageData)}"
      elsif GLOFunctionsIN.key?(bytesCheck) == true
        for i in 1..byteCounter do
          @messageData.shift # Push the 'function' bits off the front of the array, leaving the message content.
        end
        # XXXFunctionsIN.fetch(bytesCheck)[0] = the name of the function
        # XXXFunctionsIN.fetch(bytesCheck)[1] = the method's name for that function.
        # Do that thing here
      end
      #
    }
    return "--> Unknown Message"
  end
end
