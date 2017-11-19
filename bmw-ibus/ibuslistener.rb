require 'socket'
require_relative 'ibus'

# Open a Socket to the pibus Application (port 55537)
class IBusListener
  # What happens when we make a listener
  def initialize
    #puts "In Initialise for IBusListener"
    # Instance variables
    @ibusListener = TCPSocket.new '127.0.0.1', 55537
    @@lastMessage = ""
  end

  def listen
    while @message = @ibusListener.gets # Read lines from socket
      # If we are transmitting a message, don't flash the LEDs because it will go around forever in a loop.
      puts "This Message: #{@message}"
      puts "Last Message: #{@@lastMessage}"
      if @@lastMessage.contain?("tx") and @@lastMessage[3..-1] == @message[3..-1]
        puts "We sent that message - skipping"
      else
        # Flash the Board Monitor LEDs when a message comes in.
        @ibusListener.puts("tx C804E72B3200")
        @ibusListener.puts("tx C804E72B0000")
        # strip the first three characters (the "tx " or "rx ")
        @message.slice!(0,3)
        # Make the string uppercase
        @message.upcase!
        # Split the string into groups of two characters in an array.
        @message = @message.scan(/.{1,2}/)
        @message = IBusMessage.new(@message) # Shove them into a new ibus message object
        #@message.printRawMessage
        @message.printDecodedMessage

        # Copy this messag into the @lastMessage variable so we can compare it next time around.
        @@lastMessage = @message

        @message = nil # destroy the message, ready for the next one.
      end
    end
    ibusListener.close             # close socket when done
  end
end
