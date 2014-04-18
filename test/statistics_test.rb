require 'minitest/autorun'
require 'csv'

class BattingFile
  attr_accessor :data, :years

  def initialize(file=nil)
    @data = File.read(file) if file
  end

  def self.load(data)
    new.tap{|file|
      file.data = data
      file.read
    }
  end

  def read
    @years ||= YearCollection.new CSV.parse(@data, headers: true).map{|year| Year.new(year) }
  end
end

class YearCollection
  include Enumerable
  attr_accessor :members

  def initialize(years)
    @members = years
  end

  def each(&block)
    members.each{|member| block.call(member) }
  end

  def by_year(year)
    YearCollection.new members.select{|y| y.year == year }
  end

  def by_league(league)
    YearCollection.new members.select{|y| y.league == league }
  end

  def by_team(team)
    YearCollection.new members.select{|y| y.team == team }
  end

  def by_player(player)
    YearCollection.new members.select{|y| y.player == player }
  end

  def by_minimum_at_bats(at_bats)
    YearCollection.new members.select{|y| y.ab >= at_bats }
  end
end

class Year
  attr_accessor :player, :year, :league, :team, :g, :ab, :r, :h, :doubles, :triples, :hr, :rbi, :sb, :cs

  STATS = [ 'yearID', 'G', 'AB', 'R', 'H', '2B', '3B', 'HR', 'RBI', 'SB', 'CS' ]

  def initialize(stats={})
    stat_map.each do |header,var_name|
      instance_variable_set var_name,
                            is_numeric?(header) ? stats[header].to_i : stats[header]
    end
  end

  def is_numeric?(name)
    STATS.include? name
  end

  def stat_map
    {
      'playerID' => :@player,
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
    sprintf("%0.4f", h / ab.to_f).to_f
  end

  def slugging_percentage
    hits = h - (doubles + triples + hr)
    score = hits + (doubles * 2) + (triples * 3) + (hr * 4)
    sprintf('%0.4f', score / ab.to_f).to_f
  end
end

class Stats
  attr_accessor :years

  def initialize(years)
    @years = years
  end

  def most_improved_batting_average(from_year,to_year)
    player = nil
    from_set = years.by_minimum_at_bats(200).by_year(from_year)
    stop_set = years.by_minimum_at_bats(200).by_year(  to_year)
    from_set.inject({}){|hash,y|
      next hash unless stop_set.map(&:player).include?(y.player)
      from_player = from_set.by_player(y.player).first
      hash.merge( y.player => y.batting_average - from_player.batting_average )
    }.max{|(k,v),(kk,vv)| v <=> vv }.first
  end

  def slugging_percentages_by_team_and_year(team,year)
    years.by_team(team).by_year(year).inject({}) do |hash,year|
      hash.merge( year.player => year.slugging_percentage )
    end
  end

  def highest_batting_average
    years.max_by{|player| player.batting_average }.player
  end

  def most_home_runs
    years.max_by{|player| player.hr }.player
  end

  def most_rbis
    years.max_by{|player| player.rbi }.player
  end

  def triple_crown_winner(league,year)
    @years = years.by_league(league).by_year(year).by_minimum_at_bats(400)
    highest_batting_average == most_home_runs && most_home_runs == most_rbis && most_rbis || '(No winner)'
    # avg = set.max_by{|y| y.batting_average }.player
    # hrs = set.max_by{|y| y.hr }.player
    # rbi = set.max_by{|y| y.rbi }.player
    # avg == hrs && hrs == rbi && avg || '(No winner)'
  end
end

# years = BattingFile.new('./public/batting.csv').read
# stats = Stats.new(years)
# puts stats.most_improved_batting_average(2009,2010)
# puts stats.slugging_percentages_by_team_and_year('OAK',2007)
# puts stats.triple_crown_winner('AL', 2011)
# puts stats.triple_crown_winner('AL', 2012)
# puts stats.triple_crown_winner('NL', 2011)
# puts stats.triple_crown_winner('NL', 2012)

SAMPLE_DATA = <<CSV_DATA
playerID,yearID,league,teamID,G,AB,R,H,2B,3B,HR,RBI,SB,CS
abreubo01,2010,AL,LAA,154,573,88,146,41,1,20,78,24,10
abreubo01,2009,AL,LAA,152,563,96,165,29,3,15,103,30,8
CSV_DATA

describe 'Exercise' do
  let(:batting_file) { BattingFile.load(SAMPLE_DATA) }
  let(:player_id) { 'abreubo01' }
  let(:year_row) {{
    'playerID' => player_id,
    'yearID' => '2009',
    'league' => 'AL',
    'teamID' => 'LAA',
    'AB' => '10000',
    'H' => '1234',
    'HR' => '20'
  }}
  let(:year_row_two) {{
    'playerID' => player_id,
    'yearID' => '2010',
    'league' => 'AL',
    'teamID' => 'LAA',
    'AB' => '10000',
    'H' => '4321',
    'HR' => '20'
  }}
  let(:year) { Year.new(year_row) }
  let(:year_two) { Year.new(year_row_two) }

  describe BattingFile do
    it 'should have a BattingFile class' do
      BattingFile.must_be_instance_of Class
    end

    describe 'BattingFile.load(csv_data)' do
      it 'should return a new BattingFile instance' do
        batting_file.must_be_instance_of BattingFile
      end

      it 'should contain an array with 2 elements' do
        batting_file.years.count.must_equal 2, "#{batting_file.years.count} is not 2"
      end

      it 'should return a year collection' do
        batting_file.years.must_be_instance_of YearCollection
      end

      it 'should have 2 years' do
        batting_file.years.count.must_equal 2
      end
    end
  end

  describe Year do
    it 'should properly load all stats' do
      year.player.must_equal player_id
      year.hr.must_equal 20
    end

    it 'should set values to 0 if stats are nil' do
      Year.new.ab.must_equal 0
    end

    describe '#batting_average' do
      it 'calculates the proper batting average' do
        year.batting_average.must_equal 0.1234
        year_two.batting_average.must_equal 0.4321
      end

      it 'returns a float' do
        year.batting_average.must_be_instance_of Float
      end
    end

    describe '#slugging_percentage' do
      it 'should give scores to each type of hit and divide by total at_bats' do
        this_year = Year.new 'playerID' => player_id,
                             'AB' => 100,
                             'H'  =>  20, # 20 -      9  => 11
                             '2B' =>   2, # 11 + (2 * 2) => 15
                             '3B' =>   3, # 15 + (3 * 3) => 24
                             'HR' =>   4  # 24 + (4 * 4) => 40

        this_year.slugging_percentage.must_equal (40 / 100.to_f) # => 0.4
      end
    end
  end

  describe YearCollection do
    let(:oak_2000) { Year.new('playerID' => 'one', 'yearID' => 2000, 'league' => 'AL', 'teamID' => 'OAK', 'AB' => 200) }
    let(:flo_2002) { Year.new('playerID' => 'two', 'yearID' => 2002, 'league' => 'AL', 'teamID' => 'FLO', 'AB' => 180) }
    let(:year_set) {[
        oak_2000,
        Year.new('playerID' => 'one', 'yearID' => 2001, 'league' => 'NL', 'teamID' => 'OAK', 'AB' => 150),
        Year.new('playerID' => 'one', 'yearID' => 2002, 'league' => 'NL', 'teamID' => 'OAK', 'AB' => 160),
        Year.new('playerID' => 'two', 'yearID' => 2000, 'league' => 'NL', 'teamID' => 'FLO', 'AB' => 140),
        Year.new('playerID' => 'two', 'yearID' => 2001, 'league' => 'NL', 'teamID' => 'FLO', 'AB' => 175),
        flo_2002,
    ]}
    describe '#count' do
      it 'should return the size of @years' do
        YearCollection.new(year_set).count.must_equal 6
      end
    end

    describe '#by_minimum_at_bats' do
      it 'should return a new YearCollection' do
        YearCollection.new(year_set).by_minimum_at_bats(180).must_be_instance_of YearCollection
      end

      it 'should return a subset of the original collection' do
        YearCollection.new(year_set).by_minimum_at_bats(180).count.must_equal 2
      end

      it 'should return the expected years' do
        YearCollection.new(year_set).by_minimum_at_bats(180).to_a.must_equal [oak_2000, flo_2002]
      end
    end

    describe '#by_year' do
      it 'should return a new YearCollection' do
        YearCollection.new(year_set).by_year(2001).must_be_instance_of YearCollection
      end

      it 'should return a subset of the original collection' do
        YearCollection.new(year_set).by_year(2001).count.must_equal 2
      end
    end

    describe '#by_league' do
      it 'should return a new YearCollection' do
        YearCollection.new(year_set).by_league('AL').must_be_instance_of YearCollection
      end

      it 'should return a subset of the original collection' do
        YearCollection.new(year_set).by_league('AL').count.must_equal 2
      end
    end

    describe '#by_team' do
      it 'should return a new YearCollection' do
        YearCollection.new(year_set).by_team('OAK').must_be_instance_of YearCollection
      end

      it 'should return a subset of the original collection' do
        YearCollection.new(year_set).by_team('OAK').count.must_equal 3
      end
    end

    describe '#by_player' do
      it 'should return a new YearCollection' do
        YearCollection.new(year_set).by_player('one').must_be_instance_of YearCollection
      end

      it 'should return a subset of the original collection' do
        YearCollection.new(year_set).by_player('one').count.must_equal 3
      end
    end

    it 'expects the proper results when chaining methods' do
      YearCollection.new(year_set).by_year(2000).by_team('OAK').to_a.must_equal [oak_2000]
    end

    it 'should allow the by_* methods to be chainable' do
      YearCollection.new(year_set).by_year(2000).by_team('OAK').count.must_equal 1
    end
  end

  describe '#highest_batting_average' do
    it 'should return the player_id with the highest batting average' do
      Stats.new(YearCollection.new([
        Year.new('playerID' => 'lowest_average', 'H' => 10, 'AB' => 100),
        Year.new('playerID' => 'highest_average', 'H' => 80, 'AB' => 100),
        Year.new('playerID' => 'middle_average', 'H' => 20, 'AB' => 100),
      ])).highest_batting_average.must_equal 'highest_average'
    end
  end

  describe '#most_rbis' do
    it 'should return the player_id with the highest rbis' do
      Stats.new(YearCollection.new([
        Year.new('playerID' => 'lowest_rbis', 'RBI' => 90),
        Year.new('playerID' => 'highest_rbis', 'RBI' => 140),
        Year.new('playerID' => 'middle_rbis', 'RBI' => 110),
      ])).most_rbis.must_equal 'highest_rbis'
    end
  end

  describe '#most_home_runs' do
    it 'should return the player_id with the highest home runs'
  end
end

