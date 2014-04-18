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
