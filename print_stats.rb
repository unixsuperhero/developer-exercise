require 'pp'

require './lib/batting_file'
require './lib/year_collection'
require './lib/year'
require './lib/stats'

years = BattingFile.new('./public/batting.csv').read
stats = Stats.new(years)
pp({
  most_improved_batting_average: stats.most_improved_batting_average(2009,2010),
  OAK_slugging_percentages: stats.slugging_percentages_by_team_and_year('OAK',2007),
  al_2011_triple_crown: stats.triple_crown_winner('AL', 2011),
  al_2012_triple_crown: stats.triple_crown_winner('AL', 2012),
  nl_2011_triple_crown: stats.triple_crown_winner('NL', 2011),
  nl_2012_triple_crown: stats.triple_crown_winner('NL', 2012),
})

