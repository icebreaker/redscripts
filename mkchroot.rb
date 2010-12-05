#!/usr/bin/ruby

# Copyright (c) 2010, Mihail Szabolcs
# See LICENSE for more details.
#
# Creates a basic chroot.

require 'etc'
require 'fileutils'
require 'optparse'

def info(text)
	puts "\033[32m#{text}\033[0m"
end

def error(text)
	puts "\033[31m#{text}\033[0m"
end

# Sensible Defaults
arch = 'amd64'
repo = 'http://mirror.arlug.ro/pub/ubuntu/ubuntu/'
code = 'maverick'
dest = '/opt/chroot/test64'

op = OptionParser.new do |o|
	o.banner = "Usage: mkchroot [options]"
	
	o.on('-a', '--arch ARCH', [:i386, :amd64], 'Architecture') do |a|
		arch = a
	end
	
	o.on('-r', '--repo REPO', 'Repository to pull packages from') do |r|
		repo = r
	end
	
	o.on('-c', '--code NAME', 'Codename of the distro') do |c|
		code = c
	end
	
	o.on('-d', '--dest DIR', 'Destination directory') do |d|
		dest = d
	end
	
	o.on('-h', '--help', 'Display this screen') do
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

name = File.basename(dest)
user = Etc.getlogin

# Pre-requisites
unless Process.uid == 0 then
	error('You must be root in order to use this.')
	exit(-2)
end

if File.exist?(dest) then
	error("Destination \"#{dest}\" exists. You must use an empty directory.")
	exit(-3)
end

# Step 1:
CONF_FILENAME = '/etc/schroot/schroot.conf'

# Verify the existence of the configuration file
unless File.exist?(CONF_FILENAME) then
	error("Chroot configuration #{CONF_FILENAME} file doesn't exist.")
	exit(-4)
end

# Check for an existing configuration with the same name
conf = File.read(CONF_FILENAME)
if conf =~ /^\[#{code}\-#{name}\]$/ then
	error("A chroot configuration with the name \"#{code}-#{name}\" already exists in \"#{CONF_FILENAME}\".")
	exit(-5)
end

# Write a new configuration pointing to the destination directory
conf = <<CONF
[#{code}-#{name}]
description=#{code.capitalize} #{name.capitalize} Linux
location=#{dest}
priority=3
users=#{user}
groups=sbuild
root-groups=root
CONF

f = File.open(CONF_FILENAME,"a")
f.write(conf)
f.close

# Create Destination
FileUtils.mkdir_p(dest)

# Step 2:
unless system("debootstrap --variant=buildd --arch #{arch} #{code} #{dest} #{repo}") then
	error('An error ocurred while trying to create the chroot environment. Bleah {}')
	exit(-6)
end

# Create User Home Directory
FileUtils.mkdir_p(File.join(dest,"home/#{user}"))

# Step 3:
APT_FILENAME = File.join(dest,'etc/apt/sources.list')
apt = <<APT
deb #{repo} #{code} main restricted
deb-src #{repo} #{code} main restricted
deb #{repo} #{code}-updates main restricted
deb-src #{repo} #{code}-updates main restricted
deb #{repo} #{code} universe
deb-src #{repo} #{code} universe
deb #{repo} #{code}-updates universe
deb-src #{repo} #{code}-updates universe
deb #{repo} #{code} multiverse
deb-src #{repo} #{code} multiverse
deb #{repo} #{code}-updates multiverse
deb-src #{repo} #{code}-updates multiverse
deb #{repo} #{code}-backports main restricted universe multiverse
deb http://archive.canonical.com/ubuntu #{code} partner
deb-src http://archive.canonical.com/ubuntu #{code} partner
deb http://extras.ubuntu.com/ubuntu #{code} main
deb-src http://extras.ubuntu.com/ubuntu #{code} main
deb #{repo} #{code}-security main restricted
deb-src #{repo} #{code}-security main restricted
deb #{repo} #{code}-security universe
deb-src #{repo} #{code}-security universe
deb #{repo} #{code}-security multiverse
deb #{repo} #{code}-proposed restricted main multiverse universe
deb-src #{repo} #{code}-security multiverse
APT

f = File.open(APT_FILENAME,"a")
f.write(apt)
f.close

info('All done!')
info('Use `echroot` to install some essential packages not installed by default.')
info('Use `bchroot` to boot into your newly created chroot environment.')
exit(0)
