# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	config.vm.box = "trusty-cloudimage"
	config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

	config.vm.network :private_network, ip: "192.168.42.42"

	config.vm.synced_folder "vHosts/", "/var/www/", :mount_options => ["dmode=777","fmode=777"], :nfs => true

	# configure the VM via Puppet
	config.vm.provision :puppet
end
