
require 'rubygems'
require 'daemons'
require 'socket'
require 'trollop'

#
# Mailtrap creates a TCP server that listens on a specified port for SMTP
# clients. Accepts the connection and talks just enough of the SMTP protocol
# for them to deliver a message which it writes to disk.
#
# Based on Matt Mower's original; slightly modified by Gwyn Morfey to write messages
# as separate files so that we can serve them out by POP3. 
class Mailtrap
  VERSION = '0.2.2'
  
  # Create a new Mailtrap on the specified host:port. If once it true it
  # will listen for one message then exit. Specify the msgdir where messages
  # are written.
  def initialize( host, port, once, msgfile, msgdir )
    @host = host
    @port = port
    @once = once
    @msgfile = msgfile
    @msgdir = msgdir
    @msgnum = 0
    
    File.open( @msgfile, "a" ) do |file|
      file.puts "\n* Mailtrap started at #{@host}:#{port}\n"
    end
    
    service = TCPServer.new( @host, @port )
    accept( service )
  end
  
  # Service one or more SMTP client connections
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
        puts "Erk! #{e.message}"        
      end
      
      break if @once
    end    
  end
  
  # Write a plain text dump of the incoming email to a text
  # file. The file will be in the @msgdir folder and will
  # be called smtp0001.msg, smtp0002.msg, and so on.
  def write( from, to_list, message )
    @msgnum += 1
    
    # Strip SMTP commands from To: and From:
    from.gsub!( /MAIL FROM:\s*/, "" )
    to_list = to_list.map { |to| to.gsub( /RCPT TO:\s*/, "" ) }
    
    # Append to the end of the messages file
    File.open( @msgfile, "a" ) do |file|
      file.puts "* Message begins"
      file.puts "From: #{from}"
      file.puts "To: #{to_list.join(", ")}"
      file.puts "Body:"
      file.puts message
      file.puts "\n* Message ends"
    end
    
    #Write into msgs dir, also - Mailshovel needs this.
    Dir.mkdir(@msgdir) if !File.exist?(@msgdir)
    File.open(File.join(@msgdir,Time.now.to_i.to_s  + "_" + sprintf("%03.0f",@msgnum) + ".txt"),"w") do |file|
      file.puts message
    end
  end
  
  # Talk pidgeon-SMTP to the client to get them to hand over the message
  # and go away.
  def serve( connection )
    connection.puts( "220 #{@host} MailTrap ready ESTMP" )
    helo = connection.get_line # whoever they are
    puts "Helo: #{helo}"
    
    if helo =~ /^EHLO\s+/
      puts "Seen an EHLO"
      connection.puts "250-#{@host} offers just ONE extension my pretty"
      connection.puts "250 HELP"
    end
    
    # Accept MAIL FROM:
    from = connection.get_line
    connection.puts( "250 OK" )
    puts "From: #{from}"
    
    to_list = []
    
    # Accept RCPT TO: until we see DATA
    loop do
      to = connection.get_line
      break if to.nil?

      if to =~ /^DATA/
        connection.puts( "354 Start your message" )
        break
      else
        puts "To: #{to}"
        to_list << to
        connection.puts( "250 OK" )
      end
    end
    
    # Capture the message body terminated by <CR>.<CR>
    lines = []
    loop do
      line = connection.get_line
      break if line.nil? || line == "."
      lines << line
      puts "+ #{line}"
    end

    # We expect the client will go away now
    connection.puts( "250 OK" )
    connection.gets # Quit
    connection.puts "221 Seeya"
    connection.close
    puts "And we're done with that bozo!"

    write( from, to_list, lines.join( "\n" ) )
    
  end
  
end
