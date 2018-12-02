# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.


Vagrant.configure("2") do |config|

    config.vm.define "fhem-ovulation-calendar" do |machine|

        machine.vm.box = "debian/contrib-stretch64"
        machine.vm.hostname = "fhem-ovulation-calendar"

        machine.vm.network "public_network", bridge: [
            "en0: WLAN (AirPort)",
            "en0: Ethernet"
        ]

        # mount for later created user "fhem" with later uid 999
        machine.vm.synced_folder ".", "/vagrant",
            owner: "998", group: "dialout"

        machine.vm.provider "virtualbox" do |v|
            # Customize the amount of memory on the VM:
            v.cpus = 1
            v.memory = 1024
        end

        machine.vm.provision "shell", path: "deployment.sh"
    end
end
