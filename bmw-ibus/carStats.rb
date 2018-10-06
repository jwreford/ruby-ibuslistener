
# This class lets you make an object to keep track of the current state of the car. Things like which lights are on, which gear you're in, temperatures, and so on.

class CarStats
  # What happens when a new carStats object is created
  def initialize
    # The Lights
    ## Front Lights
    ## Off / On
    @leftLowBeam = ""
    @rightLowBeam = ""
    @leftHighBeam = ""
    @rightHighBeam = ""
    @leftFrontIndicator = ""
    @rightFrontIndicator = ""
    @leftFog = ""
    @rightFog = ""
    @leftParkingLight = ""
    @rightParkingLight = ""
    ## Rear Lights
    ## Off / On
    @leftTailLight = ""
    @rightTailLight = ""
    @leftStopLight = ""
    @rightStopLight = ""
    @thirdStopLight = ""
    @leftReverseLight = ""
    @rightReverseLight = ""
    @leftRearFogLight = ""
    @rightRearFogLight = ""
    @leftRearIndicator = ""
    @rightRearIndicator = ""

    # Powertrain State
    @gear = "" # P, N, D, R. ** Not sure if S or M (1,2,3,4,5) are visible **
    @carThinksItsInReverse = "" # This is if the reverse signal is sent over the iBus
    @coolantTemperature = ""
    @rpm = "" # Rounded to the nearest even number
    @speed = "" # Rounded to the nearest even Kilometer / Mile per hour.
    @fuelCapacity = ""
    @engineState = "" # Running, stopped.

    # Service Information
    @fuelType = ""
    @fuelUsedSinceLastService = ""
    @daysUntilbrakeCheckup = ""
    @numberOfOilChangesHistoric = ""
    @numberOfInspectionsHistoric = ""

    # Audio and Phone Systems
    @currentAudioSource = "" # FM, AM, CDC, Sirius, TAPE, AUX
    @inAPhoneCall = "" # Yes, No
    ## LEDs on the Board Monitor. Either On or Off.
    @boardMonitorLEDStatus = ""
    @telGreenLEDStatus = ""
    @telOrangeEDStatus = ""
    @telRedLEDStatus = ""

    # Exterior Information
    @outsideTemperature = ""
    @outsideAmbientLight = "" # Brightness of ambient light outside. 1-8
    @outsideEnvironment = "" # Daylight, dusk/dawn, nighttime, rain, tunnel, garage
    @outsideRaining = "" # Don't know if the iBus tells us this - I don't think it does.
    @curretLocation = "" # We get this from the NAV
    @gpsTime = ""
    @gpsDate = ""
    ## States:
    ## No GPS signal
    ## No Antenna
    ## Antenna Fault
    ## Antenna Reporting Invalid Information
    ## No Almanac
    ## Searching for Satellites
    ## 1 Sattelite, no Position
    ## 2 Sattelites, no Position
    ## 3 Satellites, no Position
    ## 4 Satellites, no Position
    ## 5 Satellites, no Position
    ## 6 Satellites, no Position
    ## 2D Location (Approximate)
    ## 3D Location.
    @gpsFixState = ""


    # OBC
    @range = ""
    @consumption1 = ""
    @consumption2 = ""
    @averageSpeed = ""
    @stopwatch = ""
    @ventilationTimer1 = ""
    @ventilationTimer2 = ""
    @time = ""
    @date = ""
    @navTimeUntilDestination = ""
    @navDistanceToDestination = ""

    # Detected Equipment
    @cdcPresent = ""
    @sunroofPresent = ""
    @ikePresent = ""
    @kombiPresent = ""
    @midPresent = ""
    @boardMonitorPresent = ""
    @rlsPresent = ""
    @aicPresent = ""
    @ihkaPresent = ""
    @telephonePresent = ""
    @dspPresent


    # Heating, Cooling, and Vents
    @recirculateState # Don't know if the iBus tells us this, or if we can only toggle it

    # Board Monitor Fields
    ## Title Field
    @boardMonitorTitle
    ## Heading Fields
    @boardMonitorHeading1
    @boardMonitorHeading2
    @boardMonitorHeading3
    @boardMonitorHeading4
    @boardMonitorHeading5
    @boardMonitorHeading6
    @boardMonitorHeading7
    ## Main Lower Fields
    @boardMonitorLower1
    @boardMonitorLower2
    @boardMonitorLower3
    @boardMonitorLower4
    @boardMonitorLower5
    @boardMonitorLower6
    @boardMonitorLower7
    @boardMonitorLower8
    @boardMonitorLower9
    @boardMonitorLower10

    # Variables for Doors and Windows
    ## Doors
    ## Opened, closed, locked
    @driverDoorState
    @frontPassengerDoorState
    @rearLeftPassengerDoorState
    @rearRightPassengerDoorState
    ## Windows
    ## Opened, closed
    @driverWindowState
    @frontPassengerWindowState
    @rearLeftPassengerWindowState
    @rearRightPassenegerWindowState
    ## Boot / Hood
    ## Open, closed
    @bootState
    @hoodState


    # Misc stuff
    @driverMirrorSwitchState # Left, right
    @interiorLightsBrightness # 0-255
    @navGyroVoltage
    @navLogicVoltage
    @navBatteryVoltage
    @navSensorVoltage
    @navTemperature

    # Variables for the Immobalizer and Key
    @keyState # Inserted, Position 1, Position 2, Ignition
    @validKey
    @keyNumber # Don't know if the iBus tells us this
    ## Key Buttons
    ## Not Pressed, pressed, hold
    @keyLockState
    @keyUnlockState
    @keyBootState

    # PDC Information
    @typeOfPDC # Rear Only, or Front and Rear
    @rearOuterLeftPDC
    @rearInnerLeftPDC
    @rearinnerRightPDC
    @rearOuterRightPDC
    @frontOuterLeftPDC
    @frontInnerLeftPDC
    @frontInnerRightPDC
    @frontOuterRightPDC
  end
end
