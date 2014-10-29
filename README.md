Vagrant Config for TYPO3 Flow Development
=========================================

My default Linux box for PHP development with [TYPO3 Flow](http://flow.typo3.org/) (but should work with other PHP stuff, too).

The usual approach (ok, seen more-often than mine) is to have one Vagrant based system per project. While that makes perfectly sense in many situations, I needed something different: I'm working on many smaller projects during my spare-time and based on that, my Vagrant setup suffices the following requirements:

- I need to be able to work offline, e.g. in the train
- I want a minimum overhead for creating a new "site" or virtual host
- I prefer the GUI Git client ([Tower](http://www.git-tower.com/)) over the command line - so the project files shall remain locally on the host system
- I want a documented and recoverable setup of the VM

For that I thought of a solution based on Apaches *vhost_alias" module, which allows me to call whatever domain name I want - and it will be dynamically mapped locally. E.g. for a request for "example.com", Apache will look in the document-root at "/var/www/example.com" - without having to declare that in a vHost directive for each new project. Just let the DNS or hosts file point to the IP of the Vagrant box and you're ready to go. The subdirectory "vHost" of this repository is mounted as /var/www in the guest OS.

**This changed with version 2:** Until v1.x the box shipped both Apache and Ningx at the same time - but since I've never used Apache anymore on my dev-system, I've dropped it for v2.0 and chose nginx as the default web server.

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

The box gets the static IP addresses **192.168.42.42** which is only accessible from your local computer.

Now add any project you're working on (e.g. "example.com") to your hosts file and let it point to 192.168.42.42 - and create a directory with the domain name within the sub-directory "vHosts". As soon as you call that domain from your browser, you should see it working. As an alternative to editing your hosts file over and over again, you can of course also install dnsmasq on your host system.

For name resolution from within the guest system (e.g. within the vagrant box), the dnsmasq tool is installed and configured so that lookups to *.dev, *.prod and *.lo will always result in the IP of Nginx (192.168.42.42).

For demonstration purpose, I've added "phpconfig.lo" already, as soon as you let that name point to the IP 192.168.42.42, you should see some _phpinfo()_ output when accessing "phpconfig.lo" with your browser.

To log in via SSH, just execute the following command from within the current directory:

	vagrant ssh

If you fiddle around/extend/change/improve with the Puppet manifests contained in here, you can simple re-run the puppet apply command from outside of the VM with the following command (instead of rebooting the VM):

	vagrant provision

What it contains:
-----------------

- Ubuntu 14.04 LTS (trusty)
- PHP 5.5.x
- MySQL server 5.5.x (user: *root*, password *vagrant*)
- Remote-Access for MySQL
- Nginx 1.4.x with mass host config
- dnsmasq config (for local name resolution within the vagrant-box)
- phpMyAdmin (http://192.168.42.42/phpmyadmin/ - or any other "domain" that points to this IP)
- mailcatcher (http://192.168.42.42:1080/) a "Mock SMTP-Server" that catches all Mails sent to it and makes them available via a web-frontend (perfectly suited for testing applications that send mails
- nano-Editor
- git and tig
- Composer (installed + kept up to date)
- Node including npm and Bower
- OpenLDAP Server, LDAP CLI Tools and PHP LDAP-Module


MySQL access from "remote":
---------------------------

Sometimes, the included phpMyAdmin installation is not enough and you want to connect to the DB from your host system (from outside of the box). To do that, just run the following command to connect to the MySQL database that runs inside of the box:

	mysql -h 192.168.42.42 -u root -pvagrant

LDAP Server configuration:
--------------------------
If you want to use LDAP, you should reconfigure the package with the following command:

	dpkg-reconfigure slapd

Basically to set your username/password to connect to your new OpenLDAP-Server.


Where it was tested:
--------------------

- Windows 7 with VirtualBox v4.3.6 and Vagrant v1.4.1

TODO:
-----

The following stuff is what I want to add to this box:

[vacuum]

Optional and maybe later:

- xDebug
- adminer instead of phpMyAdmin
- zsh with oh-my-zsh


## How to contribute?

Feel free to [file new issues](https://github.com/mrimann/VagrantTYPO3Flow/issues) if you find a problem or to propose a new feature. If you want to contribute your time and submit an improvement, I'm very eager to look at your pull request!

In case you want to discuss a new feature with me, just send me an [e-mail](mailto:mario@rimann.org).

## License

Licensed under the permissive [MIT license](http://opensource.org/licenses/MIT) - have fun with it!

### Can I use it in commercial projects?

Yes, please! And if you save some of your precious time with it, I'd be very happy if you give something back - be it a warm "Thank you" by mail, spending me a drink at a conference, [send me a post card or some other surprise](http://www.rimann.org/support/) :-)
