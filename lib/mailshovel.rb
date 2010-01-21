require 'rubygems'
require 'daemons'
require 'socket'
require 'trollop'

#
# Speaks pidgin-POP3 to serve out mail in mailtrap's folder format.
# If nothing works, look at the \r\n conversion: this was written and tested on a mac.
#
class Mailshovel
  VERSION = '0.1'

  def initialize(service, msgdir)
    @service = service
    @msgdir = msgdir
    @deletion_queue = []
    
    accept(service)
  end

  def self.connect(host, port, msgdir)
    service = TCPServer.new(host, port)
    new(service, msgdir)
  end

  # Service one or more POP3 client connections
  def accept( service )
    while session = service.accept
      class << session
        def get_line
          line = gets
          line.chomp! unless line.nil?
          line
        end
      end
      begin
        serve( session )
      rescue Exception => e
        warn e.message
        puts "Erk! #{e.message}"
      end
    end
  end

  #Return an array of full filenames, in the proper order
  def messages
    Dir.entries(@msgdir).collect{|e| File.join(@msgdir,e) if e[0..0] != "."}.compact.sort
  end

  # Talk pidgin-POP3 to the client
  def serve( connection )
    puts "Connected."
    senddata connection, "+OK Mailshovel. I'm a testing server that speaks poor POP3: try Apple's Mail.App if nothing else works.\r\n"
    loop do
      if incoming = connection.get_line
        puts "< #{incoming}"
        case incoming.split(" ")[0]
        when "USER", "PASS"
          senddata connection, "+OK Whatever, man.\r\n"
        when "STAT"
          senddata connection, "+OK #{messages.length} #{messages.length}\r\n"
        when "UIDL"
          senddata connection, "+OK\r\n"
          0.upto(messages.length-1) do |n| #Fudging needed since POP3 indices start at 1, not 0
            senddata connection, "#{n+1} #{messages[n].gsub("/","Z")}\r\n"
          end
          senddata connection, ".\r\n"
        when "LIST"
          senddata connection, "+OK\r\n"
          0.upto(messages.length-1) do |n|
            senddata connection, "#{n+1} 100\r\n"
          end
          senddata connection, ".\r\n"
        when "RETR"
          senddata connection, "+OK\r\n"
          senddata connection, File.new(messages[incoming.split(" ")[1].to_i-1],"r").read.gsub("\r","\r\n")
          senddata connection, "\r\n.\r\n"
        when "DELE"
          senddata connection, "+OK\r\n"
          schedule_for_delete(messages[incoming.split(" ")[1].to_i-1])
        when "QUIT"
          senddata connection, "+OK Closing connection.\r\n"
          delete_pending_mail
          connection.close
        else
          senddata connection, "-ERR I don't understand '#{incoming}'.\r\n"
        end
      end
    end
  end

  def senddata(connection,data)
    puts "> #{data}"
    connection.puts data
  end
  
  private
  
  def schedule_for_delete(message)
    @deletion_queue << message
  end
  
  def delete_pending_mail
    @deletion_queue.each { |message| FileUtils.rm(message) }
  end
end
