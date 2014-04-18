require 'minitest/autorun'
require 'csv'

class BattingFile
  attr_accessor :data, :rows

  def initialize(file=nil)
    @data = IO.read(file) if file
  end

  def self.load(data)
    batting_file = new.tap{|file|
      file.data = data
      file.parse
    }
  end

  def parse
    @rows ||= CSV.parse(data, headers: true)
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

SAMPLE_DATA = <<CSV_DATA
playerID,yearID,league,teamID,G,AB,R,H,2B,3B,HR,RBI,SB,CS
abreubo01,2010,AL,LAA,154,573,88,146,41,1,20,78,24,10
abreubo01,2009,AL,LAA,152,563,96,165,29,3,15,103,30,8
CSV_DATA

describe BattingFile do
  it 'should have a BattingFile class' do
    assert BattingFile.is_a? Class
  end

  describe 'BattingFile.load(csv_data)' do
    it 'should return a new BattingFile instance' do
      assert BattingFile.load(SAMPLE_DATA).class == BattingFile
    end

    it 'should contain 3 CSV Rows'
  end
end

describe Year do
  describe '#batting_average' do
    it 'calculates the proper batting average'
    it 'returns a float'
  end
end

