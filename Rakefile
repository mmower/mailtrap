# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'rspec/core/rake_task'
#require './lib/mailtrap.rb'
#require './lib/mailshovel.rb'
# Hoe.plugin :rcov
Hoe.plugin :gemspec
Hoe.plugin :git

Hoe.spec "mailtrap" do
 self.rubyforge_name = 'simplyruby'
 developer 'Matt Mower', 'self@mattmower.com'
 #summary 'Mailtrap is a mock SMTP server for use in Rails development'
 #description self.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
 #url self.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
 #changes self.paragraphs_of('History.txt', 0..1).join("\n\n")
 #remote_rdoc_dir 'mailtrap'
 extra_deps << ['daemons','>= 1.0.8'] 
 extra_deps << ['trollop','>= 1.7']
 extra_deps << ['mail','~> 2.3.0']
end

namespace :spec do
  desc "Run the specs under spec"
  RSpec::Core::RakeTask.new 'all' do |t|
    t.rspec_opts = [ '--options', "spec/spec.opts" ]
    t.pattern = 'spec/**/*_spec.rb'
  end

  desc "Run the specs under spec in specdoc format"
  RSpec::Core::RakeTask.new 'doc' do |t|
    t.rspec_opts = [ '--format', "documentation" ]
    t.pattern = 'spec/**/*_spec.rb'
  end

  desc "Run the specs in HTML format"
  RSpec::Core::RakeTask.new 'html' do |t|
    t.rspec_opts = [ '--format', "html" ]
    t.pattern = 'spec/**/*_spec.rb'
  end
end

desc "Run the default spec task"
task :spec => :"spec:all"

# vim: syntax=Ruby
