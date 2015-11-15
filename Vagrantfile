VAGRANTFILE_API_VERSION = "2"

$script = <<SCRIPT
wget "https://apt.puppetlabs.com/puppetlabs-release-trusty.deb" 
dpkg -i puppetlabs-release-trusty.deb 
apt-get update -y --fix-missing
apt-get install -y puppet ruby-dev git
gem install librarian-puppet
cd /vagrant/puppet
librarian-puppet install --verbose
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty32"
  config.vm.provision :shell, inline: $script, run: "once"

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.manifest_file = "site.pp"
    puppet.options = "--verbose"
  end

  config.vm.define "development" do |dev|
    dev.vm.hostname = "development.neighbormarket.local"
    dev.vm.network :private_network, ip: "192.168.11.3"
    dev.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
    end
  end
  
  config.vm.define "staging" do |stag|
    stag.vm.hostname = "staging.mysite.com"
    stag.vm.synced_folder ".", "/vagrant", disabled: true
    stag.vm.provider "digital_ocean" do |provider, override|
      override.ssh.private_key_path = '~/.ssh/neighbormarket'
      override.vm.box = 'digital_ocean'
      override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      provider.token = ''
      provider.image = 'ubuntu-14-04-x32'
      provider.region = "sfo1"
      provider.ssh_key_name = "neighbormarket"
    end
  end
  
  config.vm.define "production" do |prod|
    prod.vm.hostname = "production.mysite.com"
    prod.vm.synced_folder ".", "/vagrant", disabled: true
    prod.vm.provider "digital_ocean" do |provider, override|
      override.ssh.private_key_path = '~/.ssh/neighbormarket'
      override.vm.box = 'digital_ocean'
      override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      provider.token = ''
      provider.image = 'ubuntu-14-04-x32'
      provider.region = "sfo1"
      provider.ssh_key_name = "neighbormarket"
    end
  end
end
