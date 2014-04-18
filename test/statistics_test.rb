require 'minitest/autorun'

class BattingFile

end

class Player
  def initialize(stats)

  end
end

class Year
  def initialize(stats)

  end
end

describe BattingFile do
  it 'should have a BattingFile class' do
    BattingFile.is_a? Class
  end

  describe '#batting_average' do
    it 'calculates the proper batting average'
    it 'returns a float'
  end
end

