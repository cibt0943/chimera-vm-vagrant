Vagrant.configure(2) do |config|
  config.ssh.insert_key = false

  app_code = "chimera"
  domain = "chimera"
  domain_global = "#{domain}.com"
  domain_local = "#{domain}.lan"

  ## DB & Redis & DNS ###########################################################

  dns_ip = "172.16.99.10"
  db_ip  = "172.16.99.10"
  db_username = "mysql"
  db_password = "mysql"

  config.vm.define "#{app_code}.db" do |node|
    node.vm.box = "cibt0943/centos7_mysql5.6"
    node.vm.hostname = "#{app_code}.db"
    node.vm.network "private_network", ip: db_ip
    node.vm.provider "virtualbox" do |vb|
      vb.cpus = "1"
      vb.memory = "1024"
      vb.name = "#{app_code}.db"
    end

    node.vm.provision "shell", path: "provision/scripts/db/mysql.sh", privileged: true, args: [db_username, db_password]
    node.vm.provision "shell", path: "provision/scripts/kvs/redis.sh", privileged: true
    node.vm.provision "shell", path: "provision/scripts/dns/bind.sh", privileged: true
  end

  ###############################################################################


  # Chimera #####################################################################

  chimera_ip = "172.16.100.10"
  chimera_dir_name = "chimera"

  config.vm.define "#{app_code}.ap" do |node|
    node.vm.box = "cibt0943/centos7_ruby2.5"
    node.vm.hostname = "#{app_code}.ap"
    node.vm.network "private_network", ip: chimera_ip
    node.vm.synced_folder "../#{chimera_dir_name}", "/var/www/rails_app/#{chimera_dir_name}", create: true, mount_options: ['dmode=755','fmode=755']
    node.vm.provider "virtualbox" do |vb|
      vb.cpus = "1"
      vb.memory = "1024"
      vb.name = "#{app_code}.ap"
    end

    node.vm.provision "shell", path: "provision/scripts/ap/resolv.sh", privileged: true, args: [dns_ip]
    node.vm.provision "shell", path: "provision/scripts/ap/chimera.sh", privileged: false, args: ['development', domain_global, domain_local]
  end

  ###############################################################################
end
