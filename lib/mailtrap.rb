require 'base64'
require 'rubygems'
require 'daemons'
require 'socket'
require 'trollop'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__)))

#
# Mailtrap creates a TCP server that listens on a specified port for SMTP
# clients. Accepts the connection and talks just enough of the SMTP protocol
# for them to deliver a message which it writes to disk.
#
# Based on Matt Mower's original; slightly modified by Gwyn Morfey to write messages
# as separate files so that we can serve them out by POP3. 
class Mailtrap
  VERSION = '0.2.3.20130709144258'
  
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
    connection.puts( "220 #{@host} MailTrap ready ESMTP" )
    
    # Keep handling commands until we see a MAIL FROM:
    from = nil
    loop do
      client_cmd = connection.get_line
      if client_cmd =~ /^EHLO\s*/
        puts "Seen an EHLO"
        connection.puts "250-#{@host} offers just ONE extension my pretty"
        connection.puts "250 HELP"
      elsif client_cmd =~ /^HELO\s*/
        puts "Helo: #{client_cmd}"
        connection.puts '250 OK'
      elsif client_cmd =~ /^STARTTLS$/
        #connection.puts "220 Ready to start TLS" ## TODO: if ye want a challenge
        connection.puts "454 TLS not available due to temporary reason (mailtrap doesn't support it yet)"
        connection.close
      elsif client_cmd =~ /^AUTH LOGIN$/
        # Support plaintext login
        connection.puts "334 VXNlcm5hbWU6" # 334 Username:
        username = Base64.decode64(connection.get_line)
        connection.puts "334 UGFzc3dvcmQ6" # 334 Password:
        password = Base64.decode64(connection.get_line)
        connection.puts '235 Authentication succeeded'
        log_credentials(username, password)
      elsif client_cmd =~ /^AUTH LOGIN\s+.+$/
        # Support alternate login style
        username = Base64.decode64(client_cmd.gsub(/^AUTH LOGIN\s+(.+)$/, '\1'))
        connection.puts "334 UGFzc3dvcmQ6" # 334 Password:
        password = Base64.decode64(connection.get_line)
        connection.puts '235 Authentication succeeded'
        log_credentials(username, password)
      elsif client_cmd =~ /^NOOP$/
        connection.puts '250 OK'
      elsif client_cmd =~ /^MAIL FROM:.*/i
        # Accept MAIL FROM:
        from = client_cmd
        puts "From: #{from}"
        connection.puts '250 OK'
      elsif client_cmd =~ /^QUIT$/
        connection.puts '221 Seeya'
        connection.close
      else
        # Not sure what they said... Eat the command & look the other way?
        puts "Fishy client sent us: #{client_cmd}"
        connection.puts '250 OK'
      end

      break if !from.nil?
    end 

    
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

  private
  
  def log_credentials(username, password)
      puts "What a silly client, it sent us their password in the clear!" if !username.nil? && !password.nil? && !password.empty?
      puts "Username: #{username}"
      puts "Password: #{password}"
  end
  
end
