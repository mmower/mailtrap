require 'rubygems'
require 'rspec'

require File.join(File.dirname(__FILE__), %w[ .. .. lib mailtrap log_parser ])

LOG_DIR = File.join(File.dirname(__FILE__), 'sample_logs')
SAMPLE_LOG_FILENAME = File.join(LOG_DIR, 'sample.log')
SAMPLE_EMPTY_LOG_FILENAME = File.join(LOG_DIR, 'sample_empty.log')

describe Mailtrap::LogParser do
  it "should extract two emails from the sample log file" do
    emails = Mailtrap::LogParser.parse(SAMPLE_LOG_FILENAME)
    expect(emails.size).to eq(2)
  end
  
  it "should extract the details of each email" do
    emails = Mailtrap::LogParser.parse(SAMPLE_LOG_FILENAME)
    
    # let's just enough of TMail to know it's doing something useful...
    expect(emails[0].destinations).to eq %w[ recipient@test.com ]
    expect(emails[1].destinations).to eq %w[ bear@zoo.com giraffe@zoo.com ]
    
    expect(emails[0].body).to include("Body content A")
    expect(emails[1].body).to include("Body content B")
  end
  
  it "should not include the message boundary lines" do
    emails = Mailtrap::LogParser.parse(SAMPLE_LOG_FILENAME)
    
    expect(emails[0].body).to_not include("* Message begins")
    expect(emails[0].body).to_not include("* Message ends")
    
    expect(emails[1].body).to_not include("* Message begins")
    expect(emails[1].body).to_not include("* Message ends")
  end
  
  it "should handle an empty file" do
    emails = Mailtrap::LogParser.parse(SAMPLE_EMPTY_LOG_FILENAME)
    expect(emails).to be_empty
  end
end
