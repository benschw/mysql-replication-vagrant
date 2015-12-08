# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.box = "trusty64"

  # mysqlmaster
  config.vm.define "mysqlmaster" do |mysqlmaster|

    mysqlmaster.vm.hostname = "mysqlmaster.local"
    mysqlmaster.vm.network "private_network", ip: "172.10.10.10"

    mysqlmaster.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "hiera/hiera.yaml"
      puppet.manifests_path = "puppet"
      puppet.module_path    = ["puppet/modules", "puppet/local-modules"]
      puppet.manifest_file  = "node.pp"
    end
  end

  # mysqlslave
  config.vm.define "mysqlslave" do |mysqlslave|

    mysqlslave.vm.hostname = "mysqlslave.local"
    mysqlslave.vm.network "private_network", ip: "172.10.20.10"

    mysqlslave.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "hiera/hiera.yaml"
      puppet.manifests_path = "puppet"
      puppet.module_path    = ["puppet/modules", "puppet/local-modules"]
      puppet.manifest_file  = "node.pp"
    end
  end

  # common
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

end


