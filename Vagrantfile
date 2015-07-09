# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	config.vm.box = "trusty-cloudimage"
	config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

	config.vm.provider "virtualbox" do |v|
	  v.memory = 1024
	end

	config.vm.network :private_network, ip: "192.168.42.42"

	config.vm.synced_folder "vHosts/", "/var/www/", :nfs => true

	# configure the VM via Puppet
	config.vm.provision "puppet" do |puppet|
		#puppet.manifest_file = "default.pp"
		puppet.module_path = "modules"
	end
end
