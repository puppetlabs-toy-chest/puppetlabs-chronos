require 'spec_helper_acceptance'

describe 'chronos' do
  pp = <<-eof
if $::operatingsystem == 'Ubuntu' {
  $startup_system = 'upstart'
} elsif $::operatingsystem == 'CentOS' {
  $startup_system = 'systemd'
}

class { '::chronos' :
  package_deps_manage => false,
  launcher_manage     => true,
  launcher_path       => '/usr/bin/chronos-launcher',
  startup_manage      => true,
  startup_system      => $startup_system,
  jar_file_path       => '/usr/bin/chronos',
  options             => {
    'http_port' => '8080',
  }
}
  eof

  it_behaves_like 'manifest', pp

  describe service('chronos') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  config_file_path = if os[:family] == 'ubuntu'
                       '/etc/default/chronos'
                     elsif os[:family] == 'redhat'
                       '/etc/sysconfig/chronos'
                     else
                       '/etc/chronos/config.sh'
                     end

  describe file(config_file_path) do
    it { is_expected.to be_file }
    its(:content) { is_expected.to match(%r{export CHRONOS_MASTER='zk:\/\/localhost:2181\/mesos'}) }
    its(:content) { is_expected.to match(/export CHRONOS_ZK_HOSTS='localhost:2181'/) }
    its(:content) { is_expected.to match(/export LIBPROCESS_IP='127.0.0.1'/) }
    its(:content) { is_expected.to match(/export JAVA_OPTS='-Xmx512m'/) }
  end

  describe file('/usr/bin/chronos-launcher') do
    it { is_expected.to be_file }
  end

  describe file('/usr/bin/chronos') do
    it { is_expected.to be_file }
  end

  describe file('/etc/chronos/conf/http_port') do
    it { is_expected.to be_file }
    its(:content) { is_expected.to eq "8080\n" }
  end

  describe command('wget --retry-connrefused -t 10 -qO - http://localhost:8080/scheduler/jobs') do
    its(:stdout) { is_expected.to match(/\[\]/) }
  end

  describe command('wget --retry-connrefused -t 10 -qO - http://localhost:5050/frameworks') do
    its(:stdout) { is_expected.to match(/chronos/) }
  end
end
