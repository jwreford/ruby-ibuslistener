require_relative 'bmw-ibus/lib/bmw/ibuslistener'
#require_relative 'bmw-ibus/lib/bmw/ibus'

listener = IBusListener.new
listener.listen
