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
    @players ||= parse.inject({}) do |all,player|
      id = player['playerID']
      player = all.fetch(id, Player.new(id))
      all.merge(id => player)
    end
  end
end

class Player
  attr_accessor :id, :years
  def initialize(id, years=[])
    @id = id
    @years = years
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
  let(:batting_file) { BattingFile.load(SAMPLE_DATA) }
  it 'should have a BattingFile class' do
    BattingFile.must_be_instance_of Class
  end

  describe 'BattingFile.load(csv_data)' do
    it 'should return a new BattingFile instance' do
      batting_file.class.must_equal BattingFile
    end

    it 'should contain an array with 2 elements' do
      batting_file.rows.count.must_equal 2, "#{batting_file.rows.count} is not 2"
    end

    it 'should return 1 player class' do
      assert batting_file.players.count == 1
    end
  end
end

describe Player do
  let(:player) { Player.new('john doe') }
  describe '#add_year' do

  end
end

describe Year do
  describe '#batting_average' do
    it 'calculates the proper batting average'
    it 'returns a float'
  end
end

