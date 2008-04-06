# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'spec'
require 'spec/rake/spectask'
require './lib/mailtrap'

Hoe.new('mailtrap', Mailtrap::VERSION ) do |p|
  p.rubyforge_name = 'simplyruby'
  p.author = 'Matt Mower'
  p.email = 'self@mattmower.com'
  p.summary = 'Mailtrap is a mock SMTP server for use in Rails development'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.remote_rdoc_dir = 'mailtrap'
  p.extra_deps << ['daemons','>= 1.0.8'] 
  p.extra_deps << ['trollop','>= 1.7']
  p.extra_deps << ['tmail','>= 1.2.2']
end

namespace :spec do
  desc "Run the specs under spec"
  Spec::Rake::SpecTask.new('all') do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  desc "Run the specs under spec in specdoc format"
  Spec::Rake::SpecTask.new('doc') do |t|
    t.spec_opts = ['--format', "specdoc"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  desc "Run the specs in HTML format"
  Spec::Rake::SpecTask.new('html') do |t|
    t.spec_opts = ['--format', "html"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
end

desc "Run the default spec task"
task :spec => :"spec:all"

# vim: syntax=Ruby
