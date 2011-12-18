require 'mail'

# Class to read a Mailtrap log file and extract the emails,
# returning them as TMail objects.  (Interim solution until
# we can get Mailtrap outputting structured log files.)
# --
# hacked together by Ashley Moran <ashley.moran@patchspace.co.uk> 06-Apr-2008
class Mailtrap
  class LogParser
    class << self
      # Reads a file by its filename and returns an array of TMail objects
      def parse(filename)
        emails = nil
      
        File.open(filename, "r") do |f|
          emails = extract_messages(f.readlines)
        end
      
        emails.map { |email| TMail::Mail.parse(email) }
      end
    
      private
    
      def extract_messages(lines)
        in_message = false
      
        messages = []
        message_lines = []
      
        lines.each do |line|
          next if line =~ /^\* Mailtrap started/
        
          if line.chomp == "* Message begins"
            in_message = true
            next
          end
        
          if in_message && line !~ /^\* Message (begins|ends)/
            message_lines << line
          end
        
          if line.chomp == "* Message ends"
            messages << message_lines.join
            message_lines = []
            in_message = false
            next
          end
        end
      
        messages
      end
    end
  end
end
