Vagrant.configure("2") do |config|
    config.vm.box = "generic/gentoo"

    config.vm.provider "virtualbox" do |vb|    
      vb.cpus = 4
      vb.memory = 4096
    end
  
    config.vm.synced_folder ".", "/home/vagrant/ft_linux", type: "virtualbox"
    config.vm.provision "shell", name: "Setting up the host", privileged: false,  inline: <<-SHELL
      set -e
      
      echo ok
    SHELL
  
  end