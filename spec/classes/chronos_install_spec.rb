require 'spec_helper'

describe 'chronos::install' do

  context 'supported operating systems', :type => :class do
    on_supported_os.each do |os, facts|
      context "on #{os}" do

        # rspec-puppet-facts does not include the 'puppetversion' fact anywhere
        # So we need to stub it out here.
        let(:facts) do
          facts.merge!(
              {
                  :puppetversion => ENV['PUPPET_VERSION'] || '3.7.0'
              }
          )
        end

        context 'with default parameters' do

          it { is_expected.to compile.with_all_deps }

          parameters = {
              :ensure => 'present',
              :name => 'chronos'
          }

          it { is_expected.to contain_package('chronos').with(parameters) }

        end

        context 'if package_manage is disabled' do
          let(:params) do
            {
                :package_manage => false
            }
          end

          it { is_expected.to compile.with_all_deps }

          it { is_expected.not_to contain_package('chronos') }
        end

        context 'with custom package parameters' do
          let(:params) do
            {
                :package_name => 'my-chronos',
                :package_ensure => 'latest',
                :package_provider => 'pip',
            }
          end

          parameters = {
              :ensure => 'latest',
              :name => 'my-chronos',
              :provider => 'pip',
          }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_package('chronos').with(parameters) }
        end

      end
    end
  end

end
