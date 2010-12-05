#!/usr/bin/ruby

# Copyright (c) 2010, Mihail Szabolcs
# See LICENSE for more details.
#
# Watches a certain file / directory glob for 
# changes and executes a given command when appropriate. 

require 'rubygems' # EVIL => https://gist.github.com/54177
require 'pickled_optparse'
require 'directory_watcher'

def info(text)
	puts "\033[32m#{text}\033[0m"
end

def error(text)
	puts "\033[31m#{text}\033[0m"
end

dest = nil 	# required
patn	 = nil	# required
cmd	 = nil	# required

op = OptionParser.new do |o|
	o.banner = "Usage: watcher [options]"
	
	o.on('-d', '--dest DIR', :required, 'Destination directory') do |d|
		dest = d
	end
	
	o.on('-p', '--pattern PATTERN', :required, 'Pattern to match') do |p|
		patn = p
	end
	
	o.on('-c', '--cmd CMD', :required, 'Command with/without arguments to execute') do |c|
		cmd = c
	end
	
	o.on('-h', '--help', 'Display this screen') do
		info(o)
		exit(-1)
	end
	
	if o.missing_switches?
		error(o.missing_switches.join("\n"))
		info(o)
		exit(-1)
	end
end

begin
	op.parse!
rescue Exception=>e
	error(e.message.capitalize)
	info(op)
	exit(-1)
end

dw = DirectoryWatcher.new dest, :glob=>"**/#{patn}", :pre_load => true, :interval => 5
dw.add_observer do |*args| 
	args.each do |event| 
		system(cmd.gsub("{{FILE}}",event.path.to_s))
	end
end

trap("INT") do
	dw.stop()
	error("\nSayonara ...")
	exit(0)
end

dw.start()
while 1 do
	sleep 10
end
