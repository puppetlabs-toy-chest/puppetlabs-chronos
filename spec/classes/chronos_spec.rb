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

        it { is_expected.to compile.with_all_deps }

        context 'when manage_package_deps is true' do
          let(:params) {{ :manage_package_deps => true }}

          it { is_expected.to contain_package('httparty').with_ensure('present') }
          it { is_expected.to contain_package('json').with_ensure('present') }
          it { is_expected.to contain_class('chronos::params') }

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

            it { should contain_package('httparty').with_provider('pe-gem') }
            it { should contain_package('json').with_provider('pe-gem') }
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

      it { expect { is_expected.to contain_package('chronos') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
