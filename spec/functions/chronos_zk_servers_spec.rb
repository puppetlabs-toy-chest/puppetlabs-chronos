require 'spec_helper'

describe 'chronos_zk_servers', :type => :puppet_function do
  context 'interface' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params().and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params(nil).and_raise_error(Puppet::ParseError) }
    it { is_expected.to run.with_params(nil, nil).and_raise_error(Puppet::ParseError) }
  end

  context 'values' do
    it { is_expected.to run.with_params(['one']).and_return('one:2181') }
    it { is_expected.to run.with_params('one', '2182').and_return('one:2182') }
    it { is_expected.to run.with_params(%w(one two:100), '2183').and_return('one:2183,two:100') }
    it { is_expected.to run.with_params([], 'path').and_return(nil) }
  end
end
