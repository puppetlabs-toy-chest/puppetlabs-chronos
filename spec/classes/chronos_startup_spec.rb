require 'spec_helper'

describe 'chronos::startup', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      # rspec-puppet-facts does not include the 'puppetversion' fact anywhere
      # So we need to stub it out here.
      let(:facts) do
        facts.merge!(
          puppetversion: ENV['PUPPET_VERSION'] || '3.7.0'
        )
      end

      context 'with default parameters and startup_manage and launcher_manage enabled' do
        let(:params) do
          {
            startup_manage: true,
            launcher_manage: true,
          }
        end

        it { is_expected.to compile.with_all_deps }

        launcher_parameters = {
          ensure: 'present',
          owner: 'root',
          group: 'root',
          mode: '0755',
          path: '/usr/bin/chronos',
        }

        it { is_expected.to contain_file('chronos_launcher_file').with(launcher_parameters) }
      end

      context 'with custom parameters' do
        let(:params) do
          {
            startup_manage: true,
            launcher_manage: true,
            launcher_path: '/usr/local/bin/chronos',
            service_name: 'my-chronos',
            jar_file_path: false,
          }
        end

        it { is_expected.to compile.with_all_deps }

        launcher_parameters = {
          ensure: 'present',
          owner: 'root',
          group: 'root',
          mode: '0755',
          path: '/usr/local/bin/chronos',
        }

        it { is_expected.to contain_file('chronos_launcher_file').with(launcher_parameters) }
      end

      context 'with launcher_manage disabled' do
        let(:params) do
          {
            launcher_manage: false,
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.not_to contain_file('chronos_launcher_file') }
      end

      context 'with Upstart system' do
        let(:params) do
          {
            startup_manage: true,
            startup_system: 'upstart',
            launcher_manage: true,
            launcher_path: '/usr/local/bin/chronos',
            service_name: 'my-chronos',
            jar_file_path: '/usr/share/java/my-chronos-runnable.jar',
            run_user: 'user',
          }
        end

        upstart_content = <<-eof
description "Chronos scheduler for Mesos"

start on runlevel [2345]
stop on runlevel [!2345]

respawn
respawn limit 10 5

setuid user

exec /usr/local/bin/chronos --jar '/usr/share/java/my-chronos-runnable.jar'
        eof
        upstart_parameters = {
          ensure: 'present',
          owner: 'root',
          group: 'root',
          mode: '0644',
          content: upstart_content,
        }

        it { is_expected.to contain_file('chronos_upstart_file').with(upstart_parameters) }

        init_parameters = {
          ensure: 'symlink',
          target: '/lib/init/upstart-job',
          path: '/etc/init.d/my-chronos',
        }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('chronos::startup::upstart') }

        it { is_expected.to contain_file('chronos_init.d_wrapper').with(init_parameters) }
      end

      context 'with Systemd system' do
        let(:params) do
          {
            startup_manage: true,
            startup_system: 'systemd',
            launcher_manage: true,
            launcher_path: '/usr/local/bin/chronos',
            service_name: 'my-chronos',
            jar_file_path: '/usr/share/java/my-chronos-runnable.jar',
            run_user: 'user',
          }
        end

        systemd_content = <<-eof
[Unit]
Description=Chronos
After=network.target
Wants=network.target

[Service]
ExecStart=/usr/local/bin/chronos --jar /usr/share/java/my-chronos-runnable.jar
Restart=on-abort
Restart=always
RestartSec=20

User=user

[Install]
WantedBy=multi-user.target
        eof
        upstart_parameters = {
          ensure: 'present',
          owner: 'root',
          group: 'root',
          mode: '0644',
          content: systemd_content,
        }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('chronos::startup::systemd') }

        it { is_expected.to contain_file('chronos_systemd_unit').with(upstart_parameters) }
      end
    end
  end
end
