Gem::Specification.new do |s|
  s.name    = 'mailtrap'
  s.author  = 'Matt Mower'
  s.email   = 'self@mattmower.com'
  s.summary = 'Mailtrap is a mock SMTP server for use in Rails development'
  s.version = '0.2.1'
  
  s.require_paths = ["lib"]
  s.files = %w{lib/mailtrap.rb lib/mailshovel.rb bin/mailtrap}
  s.executables = ['mailtrap']
end
