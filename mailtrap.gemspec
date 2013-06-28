# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mailtrap"
  s.version = "0.2.2.20130627220419"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Mower"]
  s.date = "2013-06-28"
  s.description = "Mailtrap is a mock SMTP server for use in Rails development. This package also includes Mailshovel, a mock POP3 server that works with Mailtrap. You can configure your mail client (eg Mail.App) to connect to Mailshovel, and then manage messages that ActionMailer has \"sent\" using its GUI.\n\nMailtrap waits on your chosen port for a client to connect and talks _just enough_ SMTP protocol for ActionMailer to successfully deliver its message.\n\nMailtrap makes *no* attempt to actually deliver messages and, instead, writes them into a series of files which are read by Mailshovel.\n\nYou can configure the hostname (default: localhost) and port (default: 2525) for the server and also where the messages get written (default: /var/tmp/mailtrap.log)."
  s.email = ["self@mattmower.com"]
  s.executables = ["mailtrap"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/mailtrap", "lib/mailtrap.rb", "lib/mailshovel.rb", "test/test_mailtrap.rb", "test/mailshovel_test.rb", ".gemtest"]
  s.homepage = "http://matt.blogs.it/"
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "simplyruby"
  s.rubygems_version = "1.8.25"
  s.summary = "Mailtrap is a mock SMTP server for use in Rails development"
  s.test_files = ["test/test_mailtrap.rb", "test/mailshovel_test.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<daemons>, [">= 1.0.8"])
      s.add_runtime_dependency(%q<trollop>, [">= 1.7"])
      s.add_runtime_dependency(%q<tmail>, [">= 1.2.2"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.6"])
    else
      s.add_dependency(%q<daemons>, [">= 1.0.8"])
      s.add_dependency(%q<trollop>, [">= 1.7"])
      s.add_dependency(%q<tmail>, [">= 1.2.2"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe>, ["~> 3.6"])
    end
  else
    s.add_dependency(%q<daemons>, [">= 1.0.8"])
    s.add_dependency(%q<trollop>, [">= 1.7"])
    s.add_dependency(%q<tmail>, [">= 1.2.2"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe>, ["~> 3.6"])
  end
end
