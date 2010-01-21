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
    @input.rewind
    @input.puts(string)
    @input.rewind
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
      3.times { |x| FileUtils.touch("/tmp/mailshovel/message#{x}.txt") }

      with_mailshovel do
        say("LIST")
      end
      
      assert_received_response(/1 100\r\n2 100\r\n3 100\r\n/)
    end
    
    should "respond to STAT command with the number of messages" do
      5.times { |x| FileUtils.touch("/tmp/mailshovel/message#{x}.txt") }
      
      with_mailshovel do
        say("STAT")
      end
      
      assert_received_response(/OK 5 5/)
    end
    
  end
  
  private
  
  def with_mailshovel(&block)
    @runner = Thread.new do
      @mailshovel = Mailshovel.new(@connection, '/tmp/mailshovel') 
    end
    
    @connection.instance_eval(&block)
  end
  
  def assert_received_response(regexp)
    sleep 0.1
    @connection.output.rewind
    assert_match regexp, @connection.output.read
  end
end
