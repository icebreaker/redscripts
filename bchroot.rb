#!/usr/bin/ruby

# Copyright (c) 2010, Mihail Szabolcs
# See LICENSE for more details.
#
# Boots into a prepared chroot.

require 'rubygems' # EVIL => https://gist.github.com/54177
require 'pickled_optparse'

def info(text)
	puts "\033[32m#{text}\033[0m"
end

def error(text)
	puts "\033[31m#{text}\033[0m"
end

dest = nil 	# required
cmd	 = ''  	# optional command with arguments to execute instead of dropping
			# into the default shell with interactive mode on

op = OptionParser.new do |o|
	o.banner = "Usage: bchroot [options]"
	
	o.on('-d', '--dest DIR', :required, 'Destination directory') do |d|
		dest = d
	end
	
	o.on('-c', '--cmd CMD', 'Command with/without arguments to execute') do |c|
		cmd = " #{c}"
	end
	
	o.on('-h', '--help', 'Display this screen') do
		info(o)
		exit(-1)
	end
	
	if o.missing_switches?
		error(o.missing_switches)
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

# Pre-requisites
unless Process.uid == 0 then
	error('You must be root in order to use this.')
	exit(-2)
end

unless File.directory?(dest) then
	error("Directory \"#{dest}\" doesn't exist.")
	exit(-3)
end

# Mounting /proc for process management
system("mount -o bind /proc #{File.join(dest,'proc')}")
# Copy resolv.conf for network access
system("cp /etc/resolv.conf #{File.join(dest,'etc/resolv.conf')}")

# TODO: mount user's home directory ? into /dest/home/user ?

err = 0
err = 4 unless system("chroot #{dest}#{cmd}")

# Un-mount /proc just to be on the safe side
system("umount #{File.join(dest,'proc')}")

exit(err)
