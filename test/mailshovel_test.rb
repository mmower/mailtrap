require 'test/unit'
require 'shoulda'
require 'mocha'
require 'fileutils'
require File.join(File.dirname(__FILE__), *%w[.. lib mailshovel])

require 'fakefs'

class FakeTCP
  attr_reader :input, :output
  
  def initialize
    @input, @output = StringIO.new, StringIO.new
  end
  
  def accept
    self
  end
  
  def puts(string)
    @output.puts(string)
  end
  
  def say(string)
    @input.puts(string + "\r\n")
    @input.rewind
    sleep(0.1)
  end
  
  def gets
    @input.gets
  end
  
  def close
    true
  end
end

class MailshovelTest < Test::Unit::TestCase
  
  context "Mailshovel" do
    setup do
      FileUtils.mkdir_p("/tmp/mailshovel")
      $stdout = StringIO.new
      @connection = FakeTCP.new
    end
    
    teardown do
      FakeFS::FileSystem.clear
      $stdout = STDOUT
      @runner.kill if @runner
    end

    should "say hello to the connection" do
      @runner = Thread.new do
        @mailshovel = Mailshovel.new(@connection, '/tmp/mailshovel') 
      end
      
      with_mailshovel { }
      
      assert_received_response(/\+OK Mailshovel/)
    end
    
    should "respond to LIST command with a list of mail" do
      3.times { |x| FileUtils.touch("/tmp/mailshovel/message#{x + 1}.txt") }

      with_mailshovel do
        say("LIST")
      end
      
      assert_received_response(/1 100\r\n2 100\r\n3 100\r\n/)
    end
    
    should "respond to STAT command with the number of messages" do
      3.times { |x| FileUtils.touch("/tmp/mailshovel/message#{x + 1}.txt") }
      
      with_mailshovel do
        say("STAT")
      end
      
      assert_received_response(/OK 3 3/)
    end
    
    context "when sending a DELE command" do
      setup do
        2.times do |x| 
          File.open("/tmp/mailshovel/message#{x + 1}.txt", 'w+') do |io|
            io.write("MESSAGE #{x + 1}")
          end
        end
      end
      
      teardown do
        FakeFS::FileSystem.clear
      end

      should "not immediately delete messages" do
        with_mailshovel do
          say("DELE 2")
        end
        
        assert File.exist?("/tmp/mailshovel/message2.txt")
      end
      
      should "still allow the message to be retrieved using its original index" do
        with_mailshovel do
          say("DELE 1")
          say("RETR 1")
        end
        
        assert_received_response(/MESSAGE 1/)
      end
      
      should "delete messages on QUIT" do
        with_mailshovel do
          say("DELE 1")
          say("DELE 2")
          say("QUIT")
        end
        
        assert !File.exist?("/tmp/mailshovel/message1.txt")
        assert !File.exist?("/tmp/mailshovel/message2.txt")
      end
    end
  end
  
  private
  
  def with_mailshovel(&block)
    @runner = Thread.new do
      @mailshovel = Mailshovel.new(@connection, '/tmp/mailshovel') 
    end
    
    @connection.instance_eval(&block)
    sleep 1
  end
  
  def assert_received_response(regexp)
    @connection.output.rewind
    assert_match regexp, @connection.output.read
  end
end
