require 'socket'
require_relative 'ibus'

# Open a Socket to the pibus Application (port 55537)
class IBusListener
  # What happens when we make a listener
  def initialize
    #puts "In Initialise for IBusListener"
    # Instance variables
    @ibusListener = TCPSocket.new '127.0.0.1', 55537
  end

  def listen
    while @message = @ibusListener.gets # Read lines from socket
      # Trim the first three characters from the string
      @message.slice!(0,3)
      # Make the string uppercase
      @message.upcase!
      # Split the string into groups of two characters in an array.
      @message = @message.scan(/.{1,2}/)
      @message = IBusMessage.new(@message) # Shove them into a new ibus message object
      #@message.printRawMessage
      @message.printDecodedMessage
      @message = nil # destroy the message, ready for the next one.
    end
    ibusListener.close             # close socket when done
  end
end
