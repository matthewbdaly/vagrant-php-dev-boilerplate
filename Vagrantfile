Vagrant.configure("2") do |config|
  config.vm.box = "debian-wheezy72-x64-vbox43"
  config.vm.box_url = "https://puphpet.s3.amazonaws.com/debian-wheezy72-x64-vbox43.box"

  config.vm.network :private_network, ip: "192.168.56.101"
    config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--memory", 1024]
    v.customize ["modifyvm", :id, "--name", "vagrant-php-dev-boilerplate-box"]
  end

  
  config.vm.synced_folder "./", "/var/www/webapp", id: "vagrant-root"
  config.vm.provision :shell, :path => "bootstrap.sh"
end
