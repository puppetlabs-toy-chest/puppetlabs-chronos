require 'spec_helper'

describe 'chronos::config', :type => :class do

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do

        # rspec-puppet-facts does not include the 'puppetversion' fact anywhere
        # So we need to stub it out here.
        let(:facts) do
          facts.merge!({:puppetversion => ENV['PUPPET_VERSION'] || '3.7.0' })
        end

        if facts[:osfamily] == 'Debian'
          config_file_path = '/etc/default/chronos'
        elsif facts[:osfamily] == 'RedHat'
          config_file_path = '/etc/sysconfig/chronos'
        else
          config_file_path = '/etc/chronos/config.sh'
        end

        context 'with default parameters' do

          parameters = {
              :owner => 'root',
              :group => 'root',
              :mode => '0640',
          }

          config_file_content = <<-eof
# Mesos connection information
# Master can be set either to the Zookeeper URL
# or to the direct URL of the Mesos master
export CHRONOS_MASTER='zk://localhost:2181/mesos'
# Zookeeper URL for Chronos to use for its data
export CHRONOS_ZK_HOSTS='localhost:2181'
# You should provide the IP for libprocess to use for the Mesos master connection
# It will be 127.0.0.1 by default and 0.0.0.0 will not work
# Without this value set Chronos will be able to connect only to the local Mesos master
export LIBPROCESS_IP='127.0.0.1'
# Java options
export JAVA_OPTS='-Xmx512m'
          eof

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_file('chronos_config_base').with(parameters).with_path('/etc/chronos') }

          it { is_expected.to contain_file('chronos_config_dir').with(parameters).with_path('/etc/chronos/conf') }

          it { is_expected.to contain_file('chronos_secret_file').with(parameters).with_path('/etc/chronos/auth_secret') }

          it { is_expected.to contain_file('chronos_config_file').with(parameters).with_path(config_file_path).with_content(config_file_content) }

        end

        context 'with custom config parameters' do

          let(:params) do
            {
                :zk_servers => %w(zk1 zk2:2183),
                :zk_chronos_servers => %w(zk3 zk4:2183),
                :zk_mesos_path => 'my-mesos',
                :zk_default_port => '2182',
                :config_base_path => '/usr/local/etc/chronos',
                :config_dir_path => '/usr/local/etc/chronos/conf',
                :config_file_path => '/usr/local/etc/chronos/config',
                :config_file_mode => '0600',
                :java_opts => '-Xmx1024m',
                :java_home => '/usr/local/java',
                :mesos_principal => 'admin',
                :mesos_secret => 'secret',
                :options => {
                    'hostname' => 'my-host',
                    'http_port' => '80',
                }
            }
          end

          parameters = {
              :owner => 'root',
              :group => 'root',
              :mode => '0600',
          }

          config_file_content = <<-eof
# Mesos connection information
# Master can be set either to the Zookeeper URL
# or to the direct URL of the Mesos master
export CHRONOS_MASTER='zk://zk1:2182,zk2:2183/my-mesos'
# Zookeeper URL for Chronos to use for its data
export CHRONOS_ZK_HOSTS='zk3:2182,zk4:2183'
# Mesos Auth connection credentials
# They will be used to connect to the Mesos master
export CHRONOS_MESOS_AUTHENTICATION_PRINCIPAL='admin'
export CHRONOS_MESOS_AUTHENTICATION_SECRET_FILE='/etc/chronos/auth_secret'
# You should provide the IP for libprocess to use for the Mesos master connection
# It will be 127.0.0.1 by default and 0.0.0.0 will not work
# Without this value set Chronos will be able to connect only to the local Mesos master
export LIBPROCESS_IP='127.0.0.1'
# Java options
export JAVA_OPTS='-Xmx1024m'
export JAVA_HOME='/usr/local/java'
          eof

          config_file_path_custom = '/usr/local/etc/chronos/config'

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_file('chronos_config_base').with(parameters).with_path('/usr/local/etc/chronos') }

          it { is_expected.to contain_file('chronos_config_dir').with(parameters).with_path('/usr/local/etc/chronos/conf') }

          it { is_expected.to contain_chronos__option('hostname').with_value('my-host') }

          it { is_expected.to contain_file('chronos-option-hostname').with_content("my-host\n") }

          it { is_expected.to contain_chronos__option('http_port').with_value('80') }

          it { is_expected.to contain_file('chronos-option-http_port').with_content("80\n") }

          it { is_expected.to contain_file('chronos_secret_file').with(parameters).with_path('/etc/chronos/auth_secret').with_content('secret') }

          it { is_expected.to contain_file('chronos_config_file').with(parameters).with_path(config_file_path_custom).with_content(config_file_content) }

        end

        context 'with empty zk_servers' do
          let(:params) do
            {
                :zk_servers => [],
            }
          end

          config_file_content = <<-eof
# You should provide the IP for libprocess to use for the Mesos master connection
# It will be 127.0.0.1 by default and 0.0.0.0 will not work
# Without this value set Chronos will be able to connect only to the local Mesos master
export LIBPROCESS_IP='127.0.0.1'
# Java options
export JAVA_OPTS='-Xmx512m'
          eof

          it { is_expected.to contain_file('chronos_config_file').with_content(config_file_content) }
        end

        context 'unsupported operating system' do
          describe 'falls back to the default values on Solaris/Nexenta' do
            let(:facts) do
              {
                :osfamily => 'Solaris',
                :operatingsystem => 'Nexenta',
                :puppetversion => ENV['PUPPET_VERSION'] || '3.7.0',
              }
            end

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_file('chronos_config_file').with_path('/etc/chronos/config.sh') }

          end
        end

      end
    end
  end

end
