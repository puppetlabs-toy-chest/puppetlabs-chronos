require 'spec_helper'

describe 'chronos' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "chronos class without any parameters" do
          let(:params) {{ :manage_package_deps => true }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_package('httparty').with_ensure('present') }
          it { is_expected.to contain_package('json').with_ensure('present') }
          it { is_expected.to contain_class('chronos::params') }
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
