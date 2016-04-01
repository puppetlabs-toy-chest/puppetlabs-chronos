require 'spec_helper'

describe 'chronos::service' do
  context 'supported operating systems', type: :class do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        # rspec-puppet-facts does not include the 'puppetversion' fact anywhere
        # So we need to stub it out here.
        let(:facts) do
          facts.merge!(
            puppetversion: ENV['PUPPET_VERSION'] || '3.7.0'
          )
        end

        context 'with default parameters' do
          it { is_expected.to compile.with_all_deps }

          parameters = {
            ensure: 'running',
            enable: true,
            name: 'chronos'
          }

          it { is_expected.to contain_service('chronos').with(parameters) }
        end

        context 'if service_manage is disabled' do
          let(:params) do
            {
              service_manage: false
            }
          end

          it { is_expected.to compile.with_all_deps }

          it { is_expected.not_to contain_service('chronos') }
        end

        context 'with custom service parameters' do
          let(:params) do
            {
              service_name: 'my-chronos',
              service_enable: false,
              service_provider: 'systemd',
            }
          end

          parameters = {
            ensure: 'stopped',
            enable: false,
            name: 'my-chronos',
            provider: 'systemd',
          }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_service('chronos').with(parameters) }
        end
      end
    end
  end
end
