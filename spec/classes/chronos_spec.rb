require 'spec_helper'

describe 'chronos', type: :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        # rspec-puppet-facts does not include the 'puppetversion' fact anywhere
        # So we need to stub it out here.
        let(:facts) do
          facts.merge!(puppetversion: ENV['PUPPET_VERSION'] || '3.7.0')
        end

        config_file_path = if facts[:osfamily] == 'Debian'
                             '/etc/default/chronos'
                           elsif facts[:osfamily] == 'RedHat'
                             '/etc/sysconfig/chronos'
                           else
                             '/etc/chronos/config.sh'
                           end

        context 'with default parameters' do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('chronos') }

          it { is_expected.to contain_class('chronos::params') }

          config_parameters = {
            zk_servers: %w(localhost),
            zk_default_port: '2181',
            zk_mesos_path: 'mesos',
            config_base_path: '/etc/chronos',
            config_dir_path: '/etc/chronos/conf',
            config_file_mode: '0640',
            config_file_path: config_file_path,
            options: {}
          }

          it { is_expected.to contain_class('chronos::config').with(config_parameters) }

          deps_parameters = {
            package_deps_list: %w(httparty json),
            package_deps_manage: true,
            package_deps_ensure: 'present',
            package_deps_provider: 'gem'
          }

          it { is_expected.to contain_class('chronos::deps').with(deps_parameters) }

          install_parameters = {
            package_name: 'chronos',
            package_manage: true,
            package_ensure: 'present'
          }

          it { is_expected.to contain_class('chronos::install').with(install_parameters) }

          service_parameters = {
            service_name: 'chronos',
            service_manage: true,
            service_enable: true
          }

          it { is_expected.to contain_class('chronos::service').with(service_parameters) }

          startup_parameters = {
            startup_manage: false,
            launcher_manage: false,
            launcher_path: '/usr/bin/chronos',
            service_name: 'chronos',
          }

          it { is_expected.to contain_class('chronos::startup').with(startup_parameters) }
        end

        context 'with custom parameters' do
          let(:params) do
            {
              package_name: 'my-chronos',
              package_manage: false,
              package_ensure: 'latest',
              package_provider: 'pip',
              package_deps_list: %w(dep1 dep2),
              package_deps_manage: false,
              package_deps_ensure: 'absent',
              package_deps_provider: 'pip',
              service_name: 'my-chronos',
              service_manage: false,
              service_enable: false,
              service_provider: 'systemd',
              zk_servers: %w(n1 n2 n3),
              zk_default_port: '2182',
              zk_mesos_path: 'my-mesos',
              config_base_path: '/usr/local/etc/chronos',
              config_dir_path: '/usr/local/etc/chronos/conf',
              config_file_path: '/usr/local/etc/defaut/chronos',
              config_file_mode: '0600',
              startup_manage: true,
              launcher_manage: true,
              launcher_path: '/usr/local/bin/chronos',
              jar_file_path: '/usr/share/java/my-chronos-runnable.jar',
              run_user: 'user',
              run_group: 'group',
              options: {
                'hostname' => 'my-node',
              }
            }
          end

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('chronos') }

          it { is_expected.to contain_class('chronos::params') }

          config_parameters = {
            zk_servers: %w(n1 n2 n3),
            zk_default_port: '2182',
            zk_mesos_path: 'my-mesos',
            config_base_path: '/usr/local/etc/chronos',
            config_dir_path: '/usr/local/etc/chronos/conf',
            config_file_mode: '0600',
            config_file_path: '/usr/local/etc/defaut/chronos',
            options: {
              'hostname' => 'my-node',
            }
          }

          it { is_expected.to contain_class('chronos::config').with(config_parameters) }

          deps_parameters = {
            package_deps_list: %w(dep1 dep2),
            package_deps_manage: false,
            package_deps_ensure: 'absent',
            package_deps_provider: 'pip'
          }

          it { is_expected.to contain_class('chronos::deps').with(deps_parameters) }

          install_parameters = {
            package_name: 'my-chronos',
            package_manage: false,
            package_ensure: 'latest',
            package_provider: 'pip'
          }

          it { is_expected.to contain_class('chronos::install').with(install_parameters) }

          service_parameters = {
            service_name: 'my-chronos',
            service_manage: false,
            service_enable: false,
            service_provider: 'systemd',
          }

          it { is_expected.to contain_class('chronos::service').with(service_parameters) }

          startup_parameters = {
            startup_manage: true,
            launcher_manage: true,
            launcher_path: '/usr/local/bin/chronos',
            jar_file_path: '/usr/share/java/my-chronos-runnable.jar',
            service_name: 'my-chronos',
            run_user: 'user',
            run_group: 'group',
          }

          it { is_expected.to contain_class('chronos::startup').with(startup_parameters) }
        end
      end
    end
  end
end
