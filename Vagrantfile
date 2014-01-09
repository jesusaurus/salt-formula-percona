Vagrant.configure("2") do |config|
  config.vm.box = "test"
  config.ssh.forward_agent = true

  # LXC Specific Config
  config.vm.provider :lxc do |lxc|
    lxc.customize 'cgroup.memory.limit_in_bytes', '512M'
  end

  # Enable the HostManager Provisioner
  config.vm.provision :hostmanager

  # Define the salt master
  config.vm.define "salt" do |salt|
      salt.vm.hostname = "salt"
      salt.vm.synced_folder "percona", "/srv/salt/percona"
      salt.vm.provision "shell", path: "vagrant/install-tops.sh"

      salt.vm.provision "salt" do |salt|
        salt.install_master = true
        salt.no_minion = true
        salt.master_config = "vagrant/master.config"
      end
  end

  # Define the instances to boot
  config.vm.define "percona1" do |percona|
      percona.vm.hostname = "percona1"

      percona.vm.provision "salt" do |salt|
        salt.minion_config = "vagrant/minion.config"
      end
  end

  config.vm.define "percona2" do |percona|
      percona.vm.hostname = "percona2"

      percona.vm.provision "salt" do |salt|
        salt.minion_config = "vagrant/minion.config"
      end
  end

  config.vm.define "percona3" do |percona|
      percona.vm.hostname = "percona3"

      percona.vm.provision "salt" do |salt|
        salt.minion_config = "vagrant/minion.config"
      end
  end

end
