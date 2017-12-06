require 'socket'
require_relative 'ibus'

# Open a Socket to the pibus Application (port 55537)
class IBusListener
  # What happens when we make a listener
  def initialize
    #puts "In Initialise for IBusListener"
    # Instance variables
    @ibusListener = TCPSocket.new '127.0.0.1', 55537
    # Need to set this to something initially otherwise Ruby will complain that @lastMessage doesn't have the include? method.
  end

  def listen
    while @message = @ibusListener.gets # Read lines from socket

      # Flash the Green Board Monitor LED each time a messasge is sent on the iBus
      # But to prevent loops, ignore messages that want to change the LEDs.
      if @message.include?("e72b")
        #puts "LED Control Message - Skipping"
      else
        puts "Flashing LED"
        @ibusListener.puts("tx C804E72B3200")  # Set the Green Board Monitor LED to flash
        @ibusListener.puts("tx C804E72B0000")  # Set it back to OFF
      end
      # Prepare the message, ready to be processed.
      @message.slice!(0,3)                     # Strip the first three characters (the "tx " or "rx ")
      @message.upcase!                         # Make the string uppercase
      @message = @message.scan(/.{1,2}/)       # Split the string into groups of two characters in an array.
      @message = IBusMessage.new(@message)     # Shove them into a new ibus message object
      #@message.printRawMessage
      @message.printDecodedMessage

      @message = nil # Destroy the message, ready for the next one.
    end
    ibusListener.close             # close socket when done
  end
end
