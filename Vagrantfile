# -*- mode: ruby -*-
# vi: set ft=ruby :
#

boxes = [
  {
    :box         => "puppetlabs/centos-6.6-64-puppet",
    :name        => "server1",
#   :eth1        => "192.168.205.10",
    :mem         => "1024",
    :cpu         => "2",
    :branch      => "production",
    :role        => "role"
  },
  {
    :box         => "puppetlabs/centos-6.6-64-puppet",
    :name        => "server2",
#   :eth1        => "192.168.205.11",
    :mem         => "1024",
    :cpu         => "2",
    :branch      => "production",
    :role        => "role"
  },
  {
    :box         => "puppetlabs/centos-6.6-64-puppet",
    :name        => "server3",
#   :eth1        => "192.168.205.12",
    :mem         => "1024",
    :cpu         => "2",
    :branch      => "production",
    :role        => "role"
  }
]

$script = <<SCRIPT
echo Setting up VM...
yum install -y --quiet git
SCRIPT

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure(2) do |config|

  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  #config.vm.box = "puppetlabs/centos-6.5-64-puppet"
  #config.vm.box = "puppetlabs/centos-6.6-64-puppet"
  #config.vm.box = "puppetlabs/centos-7.0-64-puppet"
  #config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"

  boxes.each do |opts|
    config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
    config.vm.box = opts[:box]
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name]
      config.vm.provider "vmware_fusion" do |v|
        v.gui = false
        v.vmx["memsize"] = opts[:mem]
        v.vmx["numvcpus"] = opts[:cpu]
      end
      config.vm.provider "virtualbox" do |v|
        v.gui = false
        v.customize ["modifyvm", :id, "--memory", opts[:mem]]
        v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
      end
#     config.vm.network :private_network, ip: opts[:eth1]
    end
    config.vm.provision "shell", inline: $script
    config.vm.provision "puppet" do |puppet|
      puppet.facter = {
        "role"   => opts[:role],
      }
#     puppet.options = "--verbose --debug"
      puppet.module_path = "puppet-r10k-environments/modules"
      puppet.hiera_config_path = "hiera.yaml"
    end
  end
end
