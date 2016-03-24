require 'spec_helper'

describe 'chronos' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do

        # rspec-puppet-facts does not include the 'puppetversion' fact anywhere
        # So we need to stub it out here.
        let(:facts) do
          facts.merge!({ :puppetversion => ENV['PUPPET_VERSION'] || '3.7.0' })
        end

        params = {
          :master   => 'zk://127.0.0.1/mesos',
          :zk_hosts => '127.0.0.1:2181',
        }

        let(:params) do
          params
        end

        it { is_expected.to compile.with_all_deps }

        context 'with overridden service provider' do
          let(:params) do
            params.merge!({force_provider => 'upstart'})
          end

          it { is_expected.to contain_service('chronos').with({
            'provider' => 'upstart'
          })
        end

        context 'when manage_package_deps is true' do
          let(:params) do
            params.merge!({:manage_package_deps => true})
          end

          it { is_expected.to contain_package('httparty').with_ensure('present') }
          it { is_expected.to contain_package('json').with_ensure('present') }

          context 'on a system running Puppet Open Source' do
            let(:facts) do
              facts.merge!({ :puppetversion => '3.7.5' })
            end

            it { should contain_package('httparty').with_provider('gem') }
            it { should contain_package('json').with_provider('gem') }
          end

          context 'on a system running Puppet Enterprise' do
            let(:facts) do
              facts.merge!({:puppetversion => '3.6.2 (Puppet Enterprise 3.3.0)'})
            end

            it { should contain_package('httparty').with_provider('pe_gem') }
            it { should contain_package('json').with_provider('pe_gem') }
          end

          context 'with default params' do
            it 'should configure http_port to 4400' do
              should contain_file('/etc/chronos/conf/http_port').with(
                'content' => /4400/
              )
            end
            it 'should manage the chronos package' do
              should contain_package('chronos')
            end
            it 'should manage the chronos service' do
              should contain_service('chronos')
            end
            it 'should not contain the hostname config file' do
              should_not contain_file('/etc/chronos/conf/hostname')
            end
          end

          context 'with mandatory params' do
            let(:params) do
              params.merge!({
                :master   => 'zk://myhost1:2181,myhost2:2181,myhost3:2181/mesos',
                :zk_hosts => 'myhost1:2181,myhost2:2181,myhost3:2181',
              })
            end
            it 'should manage the chronos conf directory' do
              should contain_file('/etc/chronos/conf')
            end
            it 'should manage the chronos config files' do
              should contain_file('/etc/chronos/conf/master').with(
                'content' => 'zk://myhost1:2181,myhost2:2181,myhost3:2181/mesos'
              )
              should contain_file('/etc/chronos/conf/zk_hosts').with(
                'content' => 'myhost1:2181,myhost2:2181,myhost3:2181',
              )
            end
          end

          context 'with a custom listening port' do
            let(:params) do
              params.merge!({ :http_port => '9999' })
            end
            it do
              should contain_file('/etc/chronos/conf/http_port').with(
                'content' => /9999/
              )
            end
          end

          context 'with a custom package name and service name' do
            let(:params) do
              params.merge!({
                :package_name => 'fake-chronos-package',
                :service_name => 'fake-chronos-service',
              })
            end

            it do
              should contain_package('fake-chronos-package')
              should contain_service('fake-chronos-service')
            end
          end

          context 'with a custom hostname' do
            let(:params) do
              params.merge!({
                :hostname => 'fake-chronos-hostname.foo.bar.baz',
              })
            end

            it do
              should contain_file('/etc/chronos/conf/hostname').with(
                'content' => 'fake-chronos-hostname.foo.bar.baz',
              )
            end
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'chronos class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { is_expected.to raise_error(Puppet::Error, /Solaris not supported/) }
    end
  end
end
