require 'spec_helper'
describe 'flashplayer' do

  context 'with defaults for all parameters' do
    it { should contain_class('flashplayer') }
  end
end
