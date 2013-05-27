# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	config.vm.box = "precise64"
	config.vm.box_url = "http://files.vagrantup.com/precise64.box"

	config.vm.network :private_network, ip: "192.168.42.42"

	config.vm.synced_folder "vHosts/", "/var/www/"

	# configure the VM via Puppet
	config.vm.provision :puppet
end
