require 'minitest/autorun'
require 'csv'

class BattingFile
  attr_accessor :data, :rows, :players

  def initialize(file=nil)
    @data = IO.read(file) if file
  end

  def self.load(data)
    batting_file = new.tap{|file|
      file.data = data
      file.parse
      file.load_players
    }
  end

  def parse
    @rows ||= CSV.parse(data, headers: true)
  end

  def load_players
    parse.inject({}) do |all,player|
      id = player['playerID']
      player = all.fetch(id, Player.new(id))
      all.merge(id => player)
    end
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

    it 'should contain an array with 2 elements' do
      row_count = BattingFile.load(SAMPLE_DATA).rows.count
      assert row_count == 2, "#{row_count} is not 2"
    end

    it 'should return 1 player class'
  end
end

describe Year do
  describe '#batting_average' do
    it 'calculates the proper batting average'
    it 'returns a float'
  end
end

