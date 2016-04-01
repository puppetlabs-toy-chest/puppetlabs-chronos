require 'spec_helper'

describe 'chronos_zk_url', type: :puppet_function do
  context 'interface' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params(nil).and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params(['one']).and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params(nil, nil).and_raise_error(Puppet::ParseError) }
    it { is_expected.to run.with_params(nil, nil, nil).and_raise_error(Puppet::ParseError) }
  end

  context 'values' do
    it { is_expected.to run.with_params(['one'], 'path').and_return('zk://one:2181/path') }
    it { is_expected.to run.with_params('one', 'path').and_return('zk://one:2181/path') }
    it { is_expected.to run.with_params('one', 'path', '100').and_return('zk://one:100/path') }
    it { is_expected.to run.with_params(%w(one two), 'path').and_return('zk://one:2181,two:2181/path') }
    it { is_expected.to run.with_params(%w(one two:100), 'path').and_return('zk://one:2181,two:100/path') }
    it { is_expected.to run.with_params([], 'path').and_return(nil) }
  end
end
