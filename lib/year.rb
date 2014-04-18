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
      'playerID' => :@player,    'yearID'   => :@year,      'league'   => :@league,   'teamID'   => :@team,
      'G'        => :@g,         'AB'       => :@ab,        'R'        => :@r,        'H'        => :@h,
      '2B'       => :@doubles,   '3B'       => :@triples,   'HR'       => :@hr,       'RBI'      => :@rbi,
      'SB'       => :@sb,        'CS'       => :@cs,
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
