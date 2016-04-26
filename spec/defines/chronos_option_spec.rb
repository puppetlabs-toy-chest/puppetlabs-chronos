require 'spec_helper'

describe 'chronos::option', type: :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        # rspec-puppet-facts does not include the 'puppetversion' fact anywhere
        # So we need to stub it out here.
        let(:facts) do
          facts.merge!(
            puppetversion: ENV['PUPPET_VERSION'] || '3.7.0'
          )
        end

        let(:title) { 'test' }

        context 'with default parameters' do
          let(:params) do
            {
              value: '123',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it 'contains the option file with correct content' do
            parameters = {
              content: "123\n",
              ensure: 'present',
              owner: 'root',
              group: 'root',
              mode: '0640',
            }
            is_expected.to contain_file('chronos-option-test').with(parameters)
          end
        end

        context 'with non-default parameters' do
          let(:params) do
            {
              value: '321',
              ensure: 'absent',
              owner: 'user',
              group: 'group',
              mode: '0755',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it 'contains the option file with correct content' do
            parameters = {
              content: "321\n",
              ensure: 'absent',
              owner: 'user',
              group: 'group',
              mode: '0755',
            }
            is_expected.to contain_file('chronos-option-test').with(parameters)
          end
        end

        context 'with undefined value' do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_chronos__option('test').with_value(nil) }

          it { is_expected.to contain_file('chronos-option-test').with(content: "\n") }
        end
      end
    end
  end
end
