Vagrant.configure(2) do |config|
  config.vm.box = 'centos/7'

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
  end
  config.vm.provider 'vmware_fusion' do |v|
    v.vmx['memsize'] = 2048
    v.vmx['numvcpus'] = 2
  end
  config.vm.provider 'vmware_workstation' do |v|
    v.vmx['memsize'] = 2048
    v.vmx['numvcpus'] = 2
  end
  config.vm.provider 'parallels' do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.provision 'setup', type: 'ansible_local' do |ansible|
    ansible.become = true
    ansible.compatibility_mode = '2.0'
    ansible.playbook = 'main.yml'
    ansible.verbose = false
    ansible.extra_vars = {
      dhis2_version: "2.35.0",
      tomcat_connector_relaxedquerychars: "[]",
      tomcat_parameter_xms: "256m",
      tomcat_parameter_xmx: "512m",
      # tomcat_version: "8.5.59",
    }
  end

  config.vm.network 'forwarded_port', guest: 5432, host: 5432,
    auto_correct: true
  config.vm.network 'forwarded_port', guest: 8080, host: 8080,
    auto_correct: true
  config.vm.network 'forwarded_port', guest: 80, host: 8888,
    auto_correct: true
end
