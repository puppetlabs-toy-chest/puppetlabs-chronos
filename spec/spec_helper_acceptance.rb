require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

debug = ENV['BEAKER_debug'] =~ /yes/i
root_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))

RSpec.configure do |c|
  c.formatter = :documentation

  c.before :suite do
    hosts.each do |host|
      copy_module_to(host, source: root_dir, module_name: 'chronos')
      on host, puppet('module', 'install', 'puppetlabs-stdlib')
      on host, puppet('module', 'install', 'deric-mesos')
      on host, puppet('module', 'install', 'deric-zookeeper')

      if fact('operatingsystem') == 'Ubuntu'

        # Prepare apt and install tool to add ppa repos
        shell 'apt-get clean'
        on host, puppet('module', 'install', 'puppetlabs-apt')
        install_package host, 'software-properties-common'
        install_package host, 'python-software-properties'

        # Add openjdk ppa and install openjdk8
        pp = <<-eof
class { '::apt' :}
apt::ppa { 'ppa:openjdk-r/ppa' :}
        eof
        apply_manifest_on(host, pp, catch_failures: true, debug: debug)
        install_package host, 'openjdk-8-jdk'

        # Install zookeeper
        pp = <<-eof
class { '::zookeeper' :}
        eof
        apply_manifest_on(host, pp, catch_failures: true, debug: debug)

      elsif fact('osfamily') == 'RedHat'

        # Install epel
        on host, puppet('module', 'install', 'stahnma-epel')
        pp = <<-eof
          class { '::epel' :}
        eof
        apply_manifest_on(host, pp, catch_failures: true, debug: debug)

        # Install openjdk8
        install_package host, 'java-1.8.0-openjdk-headless'

        # Cloudera repo and Zookeeper
        ver = fact('operatingsystemmajrelease')
        cmd = "rpm -Uvh http://archive.cloudera.com/cdh5/one-click-install/redhat/#{ver}/x86_64/cloudera-cdh-5-0.x86_64.rpm"
        shell cmd, acceptable_exit_codes: [0, 1]

        pp = <<-eof
class { '::zookeeper' :
  packages             => ['zookeeper', 'zookeeper-server'],
  service_name         => 'zookeeper-server',
  initialize_datastore => true,
}
        eof
        apply_manifest_on(host, pp, catch_failures: true, debug: debug)

      end

      # Install Zookeeper and Mesos Master and Salve
      pp = <<-eof
class { 'mesos' :
  repo        => 'mesosphere',
  zookeeper   => [ '127.0.0.1'],
  single_role => false,
}

class { 'mesos::master' :
  options => {
    quorum => 1,
  }
}

class{ 'mesos::slave' :
  attributes => {
    'env' => 'testing',
  },
  resources => {
    'ports' => '[10000-65535]'
  },
  options   => {
    'isolation'      => 'cgroups/cpu,cgroups/mem',
    'containerizers' => 'docker,mesos',
    'hostname'       => $::fqdn,
  }
}
      eof
      apply_manifest_on(host, pp, catch_failures: true, debug: debug)
    end
  end
end

shared_examples_for 'manifest' do |pp|
  raise 'No manifest to apply!' unless pp

  it 'should apply with no errors' do
    apply_manifest(pp, debug: debug, catch_failures: true)
  end

  it 'should apply a second time without changes', :skip_pup_5016 do
    apply_manifest(pp, debug: debug, catch_changes: true)
  end
end
