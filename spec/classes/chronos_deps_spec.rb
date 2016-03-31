require 'spec_helper'

describe 'chronos::deps' do
  deps = %w(httparty json)

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
              :provider => 'gem'
          }

          deps.each do |package|
            it { is_expected.to contain_package(package).with(parameters) }
          end

        end

        context 'on a system running Puppet Enterprise' do
          parameters = {
              :ensure => 'present',
              :provider => 'pe_gem'
          }

          let(:facts) do
            facts.merge!(
                {
                    :puppetversion => '3.6.2 (Puppet Enterprise 3.3.0)'
                }
            )
          end

          deps.each do |package|
            it { is_expected.to contain_package(package).with(parameters) }
          end
        end

        context 'if package_deps_manage is disables' do
          let(:params) do
            {
                :package_deps_manage => false
            }
          end

          it { is_expected.to compile.with_all_deps }

          deps.each do |package|
            it { is_expected.not_to contain_package(package) }
          end
        end

        context 'with custom deps parameters' do
          let(:params) do
            {
                :package_deps_list => %w(dep1 dep2),
                :package_deps_ensure => 'latest',
                :package_deps_provider => 'pip',
            }
          end

          parameters = {
              :ensure => 'latest',
              :provider => 'pip',
          }

          it { is_expected.to compile.with_all_deps }

          %w(dep1 dep2).each do |package|
            it { is_expected.to contain_package(package).with(parameters) }
          end

          deps.each do |package|
            it { is_expected.not_to contain_package(package) }
          end

        end

      end

    end
  end
end
