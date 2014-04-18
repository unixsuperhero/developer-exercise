require 'minitest/autorun'
require 'pp'
require './lib/batting_file'
require './lib/year'
require './lib/year_collection'
require './lib/stats'

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

  describe '#triple_crown_winner and helpers' do
    let(:top_players_set) {[
        Year.new('playerID' => 'home_runs_player',        'yearID' => 2000,  'league' => 'AL',  'H' => 10,   'AB' => 400,   'HR' => 30,   'RBI' => 10),
        Year.new('playerID' => 'batting_average_player',  'yearID' => 2000,  'league' => 'AL',  'H' => 80,   'AB' => 400,   'HR' => 10,   'RBI' => 20),
        Year.new('playerID' => 'rbis_player',             'yearID' => 2000,  'league' => 'AL',  'H' => 20,   'AB' => 400,   'HR' => 20,   'RBI' => 30),
    ]}
    let(:losing_set) { top_players_set }
    let(:winning_set) {[
        Year.new('playerID' => 'triple_crown_player', 'yearID' => 2000,  'league' => 'AL', 'H' => 10, 'AB' => 400, 'HR' => 30, 'RBI' => 10),
        Year.new('playerID' => 'triple_crown_player', 'yearID' => 2000,  'league' => 'AL', 'H' => 80, 'AB' => 400, 'HR' => 10, 'RBI' => 20),
        Year.new('playerID' => 'triple_crown_player', 'yearID' => 2000,  'league' => 'AL', 'H' => 20, 'AB' => 400, 'HR' => 20, 'RBI' => 30),
    ]}
    let(:skipping_at_bats_set) {[
        Year.new('playerID' => 'skip', 'yearID' => 2000,  'league' => 'AL', 'H' => 10, 'AB' => 100, 'HR' => 30, 'RBI' => 10),
        Year.new('playerID' => 'skip', 'yearID' => 2000,  'league' => 'AL', 'H' => 80, 'AB' => 100, 'HR' => 10, 'RBI' => 20),
        Year.new('playerID' => 'skip', 'yearID' => 2000,  'league' => 'AL', 'H' => 20, 'AB' => 100, 'HR' => 20, 'RBI' => 30),
    ]}
    let(:top_players_collection) { YearCollection.new(top_players_set) }
    let(:top_player_stats) { Stats.new(top_players_collection) }

    describe '#triple_crown_winner' do
      it 'should ignore players with < 400 at_bats' do
        Stats.new(YearCollection.new(skipping_at_bats_set)).triple_crown_winner('AL', 2000).must_equal '(No winner)'
      end

      it 'should return (No winner) if same player does not match all 3 scenarios' do
        Stats.new(YearCollection.new(losing_set)).triple_crown_winner('AL', 2000).must_equal '(No winner)'
      end

      it 'should pick a winner if they meet all criteria' do
        Stats.new(YearCollection.new(winning_set)).triple_crown_winner('AL', 2000).must_equal 'triple_crown_player'
      end
    end

    describe '#highest_batting_average' do
      it 'should return the player_id with the highest batting average' do
        top_player_stats.highest_batting_average.must_equal 'batting_average_player'
      end
    end

    describe '#most_rbis' do
      it 'should return the player_id with the highest rbis' do
        top_player_stats.most_rbis.must_equal 'rbis_player'
      end
    end

    describe '#most_home_runs' do
      it 'should return the player_id with the highest home runs' do
        top_player_stats.most_home_runs.must_equal 'home_runs_player'
      end
    end
  end
end

