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

  def triple_crown_winner(league,year)
    stats = Stats.new(years.by_league(league).by_year(year).by_minimum_at_bats(400))
    stats.highest_batting_average == stats.most_home_runs &&
      stats.most_home_runs == stats.most_rbis &&
      stats.most_rbis ||
      '(No winner)'
  end

  def highest_batting_average
    year = years.max_by{|player| player.batting_average }
    year &&= year.player
  end

  def most_home_runs
    year = years.max_by{|player| player.hr }
    year &&= year.player
  end

  def most_rbis
    year = years.max_by{|player| player.rbi }
    year &&= year.player
  end
end
