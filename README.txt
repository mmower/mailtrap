mailtrap
    by Matt Mower <self@mattmower.com>
    http://matt.blogs.it/

== DESCRIPTION:

Mailtrap is a mock SMTP server for use in Rails development.

Mailtrap waits on your choosen port for a client to connect and talks _just enough_ SMTP protocol for ActionMailer to successfully deliver its message.

Mailtrap makes *no* attempt to actually deliver messages and, instead, writes them into a file (hence the name 	Mail_trap_). Handy tip: use tail -f to see emails being received.

You can configure the hostname (default: localhost) and port (default: 2525) for the server and also where the messages get written (default: /var/tmp/mailtrap.log).
	
== FEATURES/PROBLEMS:

* Lightweight, no setup
* Runs as a daemon with start, stop, etc..
* Tested with ActionMailer's SMTP delivery method
* Very, very, dumb ... might not work with an arbitrary SMTP client

== SYNOPSIS:

To use the defaults host:localhost, port:2525, file:/var/log/mailtrap.log

* mailtrap start

Customise startup:

* sudo mailtrap start --host my.host --port 25 --once --file=/var/log/messages.txt

(sudo because you want to use restricted port 25)

For more info:

* mailtrap --help (to see Daemonization options)
* mailtrap start --help (to see Mailtrap options)

== REQUIREMENTS:

* Hoe rubygem
* Rubygems rubygem
* Daemons rubygem
* Trollop rubygem

All these are automatically installed if you use gem install -y

== INSTALL:

* sudo gem install -y mailtrap

== LICENSE:

(The MIT License)

Copyright (c) 2007 Matt Mower, Software Heretics

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
