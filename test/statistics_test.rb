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
    @players ||= parse.inject({}) do |all,year|
      id = year['playerID']
      all.merge id => all.fetch(id, Player.new(id)).tap{|p| p.add_year(year) }
    end
  end
end

class Player
  attr_accessor :id, :years
  def initialize(id, years={})
    @id = id
    @years = years
  end

  def add_year(stats)
    this_year = Year.new(stats)
    years.merge!(this_year.year => this_year)
  end
end

class Year
  attr_accessor :player_id, :year, :league, :team, :g, :ab, :r, :h, :doubles, :triples, :hr, :rbi, :sb, :cs

  STATS = [ 'G', 'AB', 'R', 'H', '2B', '3B', 'HR', 'RBI', 'SB', 'CS' ]

  def initialize(stats)
    stat_map.each{|header,var_name|
      stats[header] = stats[header].to_i if STATS.include?(header)
      instance_variable_set(var_name, stats[header])
    }
  end

  def stat_map
    {
      'playerID' => :@player_id,
      'yearID'   => :@year,
      'league'   => :@league,
      'teamID'   => :@team,
      'G'        => :@g,
      'AB'       => :@ab,
      'R'        => :@r,
      'H'        => :@h,
      '2B'       => :@doubles,
      '3B'       => :@triples,
      'HR'       => :@hr,
      'RBI'      => :@rbi,
      'SB'       => :@sb,
      'CS'       => :@cs,
    }
  end

  def batting_average
    sprintf("%0.4f", h.to_f / ab.to_f).to_f
  end
end

SAMPLE_DATA = <<CSV_DATA
playerID,yearID,league,teamID,G,AB,R,H,2B,3B,HR,RBI,SB,CS
abreubo01,2010,AL,LAA,154,573,88,146,41,1,20,78,24,10
abreubo01,2009,AL,LAA,152,563,96,165,29,3,15,103,30,8
CSV_DATA

describe 'Exercise' do
  let(:batting_file) { BattingFile.load(SAMPLE_DATA) }
  let(:player_id) { 'abreubo01' }
  let(:player) { Player.new(player_id) }
  let(:year_row) { batting_file.rows.first }
  let(:year) { Year.new(year_row) }
  let(:year_two) { Year.new(batting_file.rows[1]) }

  describe BattingFile do
    it 'should have a BattingFile class' do
      BattingFile.must_be_instance_of Class
    end

    describe 'BattingFile.load(csv_data)' do
      it 'should return a new BattingFile instance' do
        batting_file.must_be_instance_of BattingFile
      end

      it 'should contain an array with 2 elements' do
        batting_file.rows.count.must_equal 2, "#{batting_file.rows.count} is not 2"
      end

      it 'should return 1 player class' do
        batting_file.players.count.must_equal 1
      end

      it 'properly loads a player with > 1 year of stats' do
        a_player = batting_file.players[player_id]
        a_player.years.count.must_equal 2
      end
    end
  end

  describe Player do
    describe '#add_year' do
      it 'should have 0 starting years' do
        player.years.count.must_equal 0
      end

      it 'year could should increase by 1' do
        player.add_year year_row
        player.years.count.must_equal 1
      end
    end
  end

  describe Year do
    it 'should properly load all stats' do
      year.player_id.must_equal player_id
      year.hr.must_equal 20
    end

    describe '#batting_average' do
      it 'calculates the proper batting average' do
        year.batting_average.must_equal 0.2548
        year_two.batting_average.must_equal 0.2931
      end

      it 'returns a float' do
        year.batting_average.must_be_instance_of Float
      end
    end
  end
end

