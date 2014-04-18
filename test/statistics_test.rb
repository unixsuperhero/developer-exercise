require 'minitest/autorun'

class BattingFile
  def initialize(file='./batting.csv')
  end

  def self.load(data)
  end

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

  describe 'BattingFile.load(csv_data)' do
    it 'should return a new BattingFile instance'
    it 'should contain 3 CSV Rows'
  end
end

describe Year do
  describe '#batting_average' do
    it 'calculates the proper batting average'
    it 'returns a float'
  end
end

