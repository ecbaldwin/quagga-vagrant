# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

my_config = YAML.load_file("provisioning/virtualbox.conf.yml")

Vagrant.configure(2) do |vagrant_config|
    vagrant_config.vm.box = my_config['box']

    if Vagrant.has_plugin?("vagrant-cachier")
        # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
        vagrant_config.cache.scope = :box
    end

    machines = ["top", "tor-r1"]
    machines.each do |machine|
        vagrant_config.vm.define machine, primary: true do |vm|
            config = my_config[machine]
            vm.vm.host_name = config['host_name']
            vm.vm.network "private_network", ip: config['ip']
            vm.vm.provision "shell",
                path: "provisioning/setup-base.sh",
                privileged: true,
                :args => "#{machine}"
            vm.vm.provider "virtualbox" do |vb|
                vb.memory = config['memory']
                vb.cpus = config['cpus']
                vb.customize [ 'modifyvm', :id, '--nictype1', "virtio" ]
                vb.customize [ 'modifyvm', :id, '--nictype2', "virtio" ]

                # The vagrant private network didn't seem to carry vlan packets
                vb.customize [ 'modifyvm', :id, '--nic3', "intnet" ]
                vb.customize [ 'modifyvm', :id, '--intnet3', "physnet1" ]
                vb.customize [ 'modifyvm', :id, '--nicpromisc3', "allow-all" ]
                vb.customize [
                    "guestproperty", "set", :id,
                    "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000
                   ]
            end
        end
    end
end
