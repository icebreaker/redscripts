RedScripts
==========

Purpose
-------
This is a collection of Ruby scripts I built in order to help me with a couple
of repetitive and rather daughting tasks.

Some of these could have been just plain `shell scripts`, but with
Ruby we have the fine degree of control and above all `readability`.

`Black magick` and `Spaghetti` should not be considered good practices.

I **CANNOT** guarantee that they will work on `Non-Debian` based systems, they might or
might not, *YOU HAVE BEEN WARNED*.

Dependencies
------------
Before we jump straight into the *deep* water let's see the list of dependencies.

Command line utilities:

* chroot
* debootstrap

Gems:

* rubygems
* directory_watcher
* optparse
* pickled_optparse

I backported `pickled_optparse` so it works with Ruby 1.8.x, you can find my
fork `https://github.com/icebreaker/pickled_optparse` here in the `1.8bp` branch. 

How to install
--------------
After you installed the dependencies, feel free to copy the scripts to a convenient
place in your path. (i.e `/usr/bin/`)

Example:

	cp mkchroot.rb /usr/bin/mkchroot

How to use
----------
All scripts have a consistent interface so feel free to pass `-h` or `--help`
as an argument to find out more about each.

Scripts
-------

* mkchroot will create a chroot
* echroot will install addiional packages
* bchroot will boot into a chroot
* watcher will watch a given directory for a pattern of files and execute a cmd

Todo
----------
I'll add more scripts as I need them so be sure to check back or pull often.

* transform the scripts into a gem for easy installation and distribution

Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2010 Mihail Szabolcs. See LICENSE for details.
