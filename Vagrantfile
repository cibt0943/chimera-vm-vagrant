Vagrant.configure(2) do |config|
  config.ssh.insert_key = false

  dns_server_ip = "172.16.99.10"

  db_server_ip = dns_server_ip
  db_username = "mysql"
  db_password = "mysql"

  ap_server_ip = "172.16.100.10"
  ap_server_global_domain = "tamechimera.com"


  ## DB & Redis & DNS ###########################################################
  config.vm.define "chimera.db" do |node|
    node.vm.box = "cibt0943/centos7_mysql5.7"
    node.vm.hostname = "chimera.db"
    node.vm.network "private_network", ip: db_server_ip
    node.vm.synced_folder '.', '/vagrant', disabled: true
    node.vm.synced_folder './provision', '/vagrant/provision'
    node.vm.provider "virtualbox" do |vb|
      vb.cpus = "1"
      vb.memory = "1024"
      vb.name = "chimera.db"
    end

    node.vm.provision "shell", path: "provision/db/mysql.sh", privileged: true, args: [db_username, db_password]
    node.vm.provision "shell", path: "provision/kvs/redis.sh", privileged: true
    node.vm.provision "shell", path: "provision/dns/bind.sh", privileged: true
  end

  ###############################################################################


  # AP  #########################################################################

  config.vm.define "chimera.ap" do |node|
    node.vm.box = "cibt0943/centos7_ruby2.7"
    node.vm.hostname = "chimera.ap"
    node.vm.network "private_network", ip: ap_server_ip
    node.vm.synced_folder '.', '/vagrant', disabled: true
    node.vm.synced_folder './provision', '/vagrant/provision'
    node.vm.synced_folder "../chimera", "/var/www/rails_app/chimera", create: true
    node.vm.provider "virtualbox" do |vb|
      vb.cpus = "1"
      vb.memory = "2048"
      vb.name = "chimera.ap"
    end

    node.vm.provision "shell", path: "provision/ap/resolv.sh", privileged: true, args: [dns_server_ip]
    node.vm.provision "shell", path: "provision/ap/chimera.sh", privileged: false, args: ['development', ap_server_global_domain]
  end

  ###############################################################################
end
