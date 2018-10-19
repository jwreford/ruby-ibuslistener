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

    ## From the Radio broadcasting that it's ready.
    ["02", "01", "D1"] => "Radio Connected and Ready",

    ## From Various Devices
    ["02", "00"] => "Device Connected and Ready",



  }

  GLOFunctionsIN = {
    ## From the Cluster broadcasting some general information
    ["18"] => ["Current Speed And RPM", "speedAndRPM"],
    ## From the Cluster
    ["19", "80", "80"] => ["Temperature Reading", "temperatureStatusUpdate"]
  }

  def speedAndRPM(hex)
    speed = hex[0]
    speed = speed.to_i(16) * 2  # Speed is Hex value converted to Decimal multiplied by 2
    rpm = hex[1]
    # If the DME isn't supplying the RPM (either via the tacho wire or the CAN Bus) the IKE will send FF (which converts to 25500 RPM.)
    if rpm == "FF"
      rpm = " Sensor Not Connected"
    else
      rpm = rpm.to_i(16) * 100    # RPM is hex value converted to decimal multiplied by 100
    end
    cleanOutput = "Speed: #{speed} KM/H, RPM: #{rpm}"
    return cleanOutput
  end

  # Decode Cluster Temperature Status Update
  def temperatureStatusUpdate(hex)
    exteriorTemperature = hex[0]  # Range is from -128 Degrees Celcius to +127 Degrees Celcius
    # As coolant temperature range is greater than 255 steps (-128 to +255 Degrees Celcius), two bytes are required.
    coolantTemperature1 = hex[1]  # Range is from -128 to +127 Degrees Celcius
    coolantTemperature2 = hex[2]  # Anything above +127 Degrees Celcuis will be added on with this byte
    if exteriorTemperature == "00"
      exteriorTemperature = "Sensor Not Connected"
    else
      exteriorTemperature = exteriorTemperature.to_i(16) - 128
      exteriorTemperature << "°"
    end
    if coolantTemperature1 == "00" && coolantTemperature2 == "00"
      coolantTemperatureTotal = "Sensor Not Connected"
    else
      coolantTemperatureTotal = "To Be Calculated"
      #coolantTemperatureTotal = coolantTemperature1.to_i(16) + coolantTemperature2.to_i(16) - 128
    end
    cleanOutput = "Exterior Temperature: #{exteriorTemperature}, Coolant Temperature: #{coolantTemperatureTotal}"
    return cleanOutput
  end

  def decodeMessage
    # Returns message as a string
    bytesCheck = []
    byteCounter = 0
    puts "[-] In Decode Message"
    @messageData.each { |currentByte|
      bytesCheck.push(currentByte)
      byteCounter = byteCounter + 1
      puts "[-] -> Checking if #{GLOStaticMessagesIN.key?(bytesCheck)} (Static Message) or #{GLOStaticMessagesIN.key?(@messageData)} (Function) is True"
      if GLOStaticMessagesIN.key?(bytesCheck) == true
        puts "[1] --> Static Message was True. Returning #{GLOStaticMessagesIN.fetch(@messageData)}"
        return "#{GLOStaticMessagesIN.fetch(@messageData)}"
      elsif GLOFunctionsIN.key?(bytesCheck) == true
        puts "[2] --> Function was True."
        for i in 1..byteCounter do
          @messageData.shift # Push the 'function' bits off the front of the array, leaving the message content.
        end
        puts "[2] --> Array:  #{GLOFunctionsIN.fetch(bytesCheck)}. Length: #{GLOFunctionsIN.fetch(bytesCheck).length}"
        puts "[2] --> Words: #{GLOFunctionsIN.fetch(bytesCheck)[0]}"
        puts "[2] --> Function: #{GLOFunctionsIN.fetch(bytesCheck)[1]}"
        puts "[2] --> Bytes Check: #{bytesCheck}. Message Data: #{@messageData}"
        return "#{@messageData}"
      end
      puts "Outside If"
    }
    puts "Outside 'For each array item'"
    return "--> [In Method]: Unknown Message. #{@messageData}"
  end
end
