require 'minitest/autorun'
require './statistics'

class Stats < Statistics; end

describe Statistics do
  it 'should have a Statistics class' do
    Statistics.is_a? Class
  end

  it 'testing mapped key in vim' do
    assert 1 + 1 == 2
  end
end

