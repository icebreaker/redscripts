#!/usr/bin/ruby

# Copyright (c) 2010, Mihail Szabolcs
# See LICENSE for more details.
#
# Installs essential set of packages and gems not installed by default.

require 'rubygems' # EVIL => https://gist.github.com/54177
require 'pickled_optparse'

def info(text)
	puts "\033[32m#{text}\033[0m"
end

def error(text)
	puts "\033[31m#{text}\033[0m"
end

dest = nil # required

op = OptionParser.new do |o|
	o.banner = "Usage: echroot [options]"
	
	o.on('-d', '--dest DIR', :required, 'Destination directory') do |d|
		dest = d
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

# Packages to install via apt from the repositories (apt-get install)
packages = 
[
	"language-pack-en", # default language pack to prevent LOCAL warnings
	"subversion",
	"mercurial",
	"git-core",
	"bzr",
	"wget",
	"build-essential",
	"gcc-mingw32", # 32-64 bit mingw32 for cross-compiling
	"cmake",
	"jam",
	"bjam",
	"yasm",
	"nasm",
	"unzip",
	"unrar",
	"vim",
	"automake",
	"autoconf",
	"python2.6",
	"python2.6-dev",
	"python-setuptools",
	"python-pygments",
	"scons",
	"ruby1.8",
	"ruby1.8-dev",
	"rubygems",
	"libsdl1.2-dev",
	"libsdl-console-dev",
	"libsdl-gfx1.2-dev",
	"libsdl-image1.2-dev",
	"libsdl-mixer1.2-dev",
	"libsdl-net1.2-dev",
	"libsdl-pango-dev",
	"libsdl-sge-dev",
	"libsdl-sound1.2-dev",
	"libsdl-ttf2.0-dev",
	"libdevil-dev",
	"libfreetype6-dev", 
	"libgl1-mesa-dev",
	"liblua5.1-0-dev",
	"libphysfs-dev",
	"libopenal-dev",
	"libogg-dev",
	"libvorbis-dev",
	"libflac-dev",
	"libflac++-dev", 
	"libmodplug-dev",
	"libmpg123-dev"
]

# Gems to install via RubyGems (gem install)
gems =
[
	"sinatra",
	"bundler",
	"rake",
	"shotgun",
	"haml",
	"rdiscount"
]

# TODO: install latest QT (not from the repo)

# Pre-requisites
unless Process.uid == 0 then
	error('You must be root in order to use this.')
	exit(-2)
end

unless File.directory?(dest) then
	error("Directory \"#{dest}\" doesn't exist.")
	exit(-3)
end

BOOT_SCRIPT = File.join(File.dirname(__FILE__), 'bchroot.rb')
BOOT_DEST = "--dest #{dest}"

# Perform apt-get update
unless system("#{BOOT_SCRIPT} #{BOOT_DEST} --cmd \"apt-get update\"") then
	exit(-4)
end

# Perform apt-get dist-upgrade
unless system("#{BOOT_SCRIPT} #{BOOT_DEST} --cmd \"apt-get dist-upgrade\"") then
	exit(-4)
end

# Perform installation of extra packages as specified
unless system("#{BOOT_SCRIPT} #{BOOT_DEST} --cmd \"apt-get install #{packages.join(' ')}\"") then
	exit(-4)
end

# Perform installation of extra gems with no documentation
unless system("#{BOOT_SCRIPT} #{BOOT_DEST} --cmd \"gem install --no-rdoc --no-ri #{gems.join(' ')}\"") then
	exit(-4)
end

info('All Done!')
exit(0)
