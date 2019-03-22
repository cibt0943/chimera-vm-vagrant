Vagrant.configure(2) do |config|
  config.ssh.insert_key = false

  ## DB & Redis & DNS ###########################################################

  dns_ip = "172.16.99.10"
  db_ip  = dns_ip
  db_username = "mysql"
  db_password = "mysql"

  config.vm.define "chimera.db" do |node|
    node.vm.box = "cibt0943/centos7_mysql5.6"
    node.vm.hostname = "chimera.db"
    node.vm.network "private_network", ip: db_ip
    node.vm.provider "virtualbox" do |vb|
      vb.cpus = "1"
      vb.memory = "1024"
      vb.name = "chimera.db"
    end

    node.vm.provision "shell", path: "provision/scripts/db/mysql.sh", privileged: true, args: [db_username, db_password]
    node.vm.provision "shell", path: "provision/scripts/kvs/redis.sh", privileged: true
    node.vm.provision "shell", path: "provision/scripts/dns/bind.sh", privileged: true
  end

  ###############################################################################


  # AP  #########################################################################

  ap_ip = "172.16.100.10"
  ap_domain = "tamechimera"
  ap_code = "chimera"
  ap_dir_name = "chimera"

  config.vm.define "chimera.ap" do |node|
    node.vm.box = "cibt0943/centos7_ruby2.5"
    node.vm.hostname = "chimera.ap"
    node.vm.network "private_network", ip: ap_ip
    node.vm.synced_folder "../#{ap_dir_name}", "/var/www/rails_app/#{ap_dir_name}", create: true, mount_options: ['dmode=755','fmode=755']
    node.vm.provider "virtualbox" do |vb|
      vb.cpus = "1"
      vb.memory = "1024"
      vb.name = "chimera.ap"
    end

    node.vm.provision "shell", path: "provision/scripts/ap/resolv.sh", privileged: true, args: [dns_ip]
    node.vm.provision "shell", path: "provision/scripts/ap/chimera.sh", privileged: false, args: ['development', ap_code, ap_domain, ap_dir_name]
  end

  ###############################################################################
end
