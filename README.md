Vagrant Config for TYPO3 Flow Development
=========================================

My default Linux box for PHP development with [TYPO3 Flow](http://flow.typo3.org/) (but should work with other PHP stuff, too).

Installation:
-------------

Install [Vagrant](http://vagrantup.com/) with the installer that fits your hosts operating system.

Download and Install [VirtualBox](http://www.virtualbox.org/)

Clone this repository

	git clone git://github.com/mrimann/VagrantTYPO3Flow.git

Change to the cloned repository

	cd VagrantTYPO3Flow

Boot up the virtual box:

	vagrant up

The box gets a static IP address *192.168.42.42* which is only accessible from your local computer.

To log in via SSH, just execute the following command from within the current directory:

	vagrant ssh


What it contains:
-----------------

- MySQL server (user: *root*, no password)

TODO:
-----

The following stuff is what I want to add to this box:

- Apache
- PHP (FPM)
- phpMyAdmin
- composer

Optional and maybe later:

- NginX
- xDebug
- zsh with oh-my-zsh
- git
- nano
- Postfix / Mail-Access for testing Mails