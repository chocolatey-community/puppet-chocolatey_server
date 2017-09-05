# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

      config.vm.box          = "windows_2012_r2_virtualbox"
      config.vm.communicator = "winrm"

      config.vm.provider :virtualbox do |v|
        v.gui    = true
        v.name   = "chocolatey-server"
        v.memory = 2048
        v.cpus   = 2
        v.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
      end

      config.vm.boot_timeout = 1600
      config.vm.hostname     = "chocolatey-server"

      config.vm.provision :shell, inline: 'robocopy /mir c:\vagrant c:\puppet /xd examples /xd spec /xd scripts /xd .git /NFL /NDL /NJH /NJS /nc /ns /np' 
      config.vm.provision :shell, path: 'scripts/puppet-provisioning.bat'

      config.vm.provision :serverspec do |spec|
        spec.pattern = "spec/acceptance/windows_2012r2_spec.rb"
      end

    end
