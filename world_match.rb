require 'byebug'

class FalseClass; def to_i; 0 end end
class TrueClass; def to_i; 1 end end

class Team
  attr_accessor :name, :short, :total_wins, :total_loses , :team_records

  def initialize(name, short)
    self.name = name
    self.short = short
    self.total_wins = 0
    self.total_loses = 0
    self.team_records = {}
  end

  def match(team_against, win)
    record = self.team_records[team_against] || [0, 0]
    other_record = team_against.team_records[self] || [0, 0]
    if win
      record[0] += 1
      other_record[1] += 1
      self.total_wins += 1
      team_against.total_loses += 1
    else
      record[1] += 1
      other_record[0] += 1
      self.total_loses += 1
      team_against.total_wins += 1
    end
    self.team_records[team_against] = record
    team_against.team_records[self] = other_record
  end

  def total_matches
    self.total_loses + self.total_wins
  end

  def >(other_team)
    self.total_wins > other_team.total_wins ||
    (self.total_wins == other_team.total_wins && self.team_records[other_team][0] > self.team_records[other_team][1])
  end

  def <(other_team)
    self.total_wins < other_team.total_wins ||
      (self.total_wins == other_team.total_wins && self.team_records[other_team][0] < self.team_records[other_team][1])
  end

  def ==(other_team)
    self.total_wins == other_team.total_wins && self.team_records[other_team][0] == self.team_records[other_team][1]
  end

  def !=(other_team)
    !(self == other_team)
  end
  def >=(other_team)
    self > other_team || self == other_team
  end

  def <=(other_team)
    self < other_team || self == other_team
  end

  def <=>(other_team)
    self < other_team ? -1 : (self > other_team ? 1 : 0)
  end
end

POSSIBLE_OUTCOMES = [false, true].repeated_permutation(6).to_a

def self.reset_group_a
  #Group A
  anx = Team.new('Albus NoX Luna', 'ANX')
  rox = Team.new('ROX Tigers', 'ROX')
  clg = Team.new('Counter Logic Gaming', 'CLG')
  g2 = Team.new('G2 Esports', 'G2')

  #Week 1
  g2.match(clg, false)
  rox.match(anx, true)
  clg.match(anx, false)
  rox.match(g2, true)
  anx.match(g2, true)
  clg.match(rox, true)

  group_a = [anx, rox, clg, g2].sort.reverse
end

def self.reset_group_b
  c9 = Team.new('Cloud9', 'C9')
  skt = Team.new('SK Telecom T1', 'SKT')
  im = Team.new('I May', 'IM')
  fw = Team.new('Flash Wolves', 'FW')

  skt.match(c9, true)
  fw.match(im, false)
  fw.match(c9, false)
  im.match(skt, false)
  skt.match(fw, false)
  c9.match(im, true)

  group_b = [c9, skt, im, fw].sort.reverse
end

def self.reset_group_c
  edg = Team.new('Edward Gaming', 'EDG')
  ahq = Team.new('ahq e-Sports Club', 'AHQ')
  itz = Team.new('INTZ e-Sports', 'ITZ')
  h2k = Team.new('H2K', 'H2K')

  h2k.match(ahq, false)
  itz.match(edg, true)
  h2k.match(itz,  true)
  edg.match(ahq, true)
  ahq.match(itz, true)
  edg.match(h2k, true)

  group_c = [edg, ahq, itz, h2k].sort.reverse
end

def self.reset_group_d
  #Group D
  tsm = Team.new('Team Solomid', 'TSM')
  rng = Team.new('Royal Never Give up', 'RNG')
  ssg = Team.new('Samsung Galaxy', 'SSG')
  spy = Team.new('Splyce', 'SPY')

  #Week 1
  tsm.match(rng, false)
  tsm.match(ssg, true)
  tsm.match(spy, true)
  rng.match(spy, true)
  rng.match(ssg, false)
  ssg.match(spy, true)

  group_d = [tsm, rng, ssg, spy].sort.reverse
end

def self.print_table(group)
  puts '#### Group Table'
  puts '|%-5s|%4s|%4s|' % ['TEAM', 'W', 'L']
  puts '|-----|---:|---:|'
  group.sort.reverse.each do |team|
    puts '|%-5s|%4d|%4d|' % [team.short, team.total_wins, team.total_loses]
  end
  headers = group[1..-1].reverse
  puts '#### Head-to-head Record'
  puts "|   |#{headers.map(&:short).join('|')}|"
  puts "|:---:|:---:|:---:|:---:|"
  (0..2).each do |i|
    line = "|**#{group[i].short}**|"
    (0..(2 - i)).each do |j|
      line += "#{group[i].team_records[headers[j]].join('-')}|"
    end
    puts line
  end
  puts "*Legend: Left W - Top W*"
  puts ""
end

#We assume that group[1] and group[2] are equal in the group already passed
def fighting_for_seed(group)
  if(group[3] == group[2])
    #4-way tie
    return group if group[1] == group[0]
    #3-way tie for 2nd
    return group[1..3]
  end

  return group[0..2] if(group[1] == group[0])
    #3-way tie for 1st, one team gets out
  #2-way tie for second
  return group[1..2]
end

def print_outcome(outcome, group, results_text)
  puts "#### Final Table\n"
  print_table group
  puts "#### Week 2 Results\n"
  results_text[outcome].each do |match_result|
    puts "* #{match_result}"
  end
  puts ""
  puts "Go to [Top](#) | [Summary](#summary)"
  puts ""
  puts "---"
end

def generate_outcomes(group_letter)
  results_text = {}
  results = {}
  ties = {}
  POSSIBLE_OUTCOMES.each_with_index do |outcome, outcome_number|
    group = public_send("reset_group_#{group_letter}")
    results_text[outcome] = []
    group.each_with_index do |team, i|
      break if i == 3
      ((i + 1)..3).each do |j|
        group[i].match(group[j], outcome[i + j - 1])
        winner, looser = outcome[i + j - 1] ? [group[i], group[j]] : [group[j], group[i]]
        results_text[outcome] << "#{winner.short} WINS VS #{looser.short}"
      end
    end
    group.sort!.reverse!
    #Only ties that affects the teams that would pass to the next phase
    if group[1] != group[2] && group[0] != group[2]
      results[outcome] = group
    else
      ties[outcome] = group
    end
  end
  dummy_group = public_send("reset_group_#{group_letter}")

  puts "# Group #{group_letter.upcase} Week 1 Standings"
  print_table dummy_group
  puts "---"
  puts "# Week 2 Possible Outcomes"
  puts "## Summary"
  puts "### Good outcomes for teams"

  dummy_group.sort_by(&:name).each do |team|
    goods = results.select do |outcome, final_group|
      final_group[0].short.eql?(team.short) || final_group[1].short.eql?(team.short)
    end
    goods.merge!(ties.select do |outcome, final_group|
      final_group[0].short.eql?(team.short) && !fighting_for_seed(final_group).map(&:short).include?(team.short)
    end)
    team_ties = ties.select do |outcome, final_group|
      fighting_for_seed(final_group).map(&:short).include?(team.short)
    end
    puts "**#{team.name} (#{team.short}):** #{ goods.keys.map{ |o| "[#{o.map(&:to_i).join.to_i(2) + 1}](#outcome-no-#{o.map(&:to_i).join.to_i(2) + 1})" }.join(", ") }"
    puts ""
    puts "Ties: #{ team_ties.keys.map{ |o| "[#{o.map(&:to_i).join.to_i(2) + 1}](#outcome-no-#{o.map(&:to_i).join.to_i(2) + 1})" }.join(", ") }"
    puts ""
    puts "Opportunities: #{goods.count}/64 (#{goods.count/64.0 * 100}%) | with Ties #{team_ties.count + goods.count}/64 (#{(team_ties.count+goods.count)/64.0 * 100}%)"
    puts ""
  end
  puts "[Outcomes with ties](#outcomes-with-ties)"
  puts ""
  puts "To see an specific outcome [copy this url](#outcome-no-0) (Right click -> Copy link address) and replace the last number in the URL with the outcome number that you want to see."
  puts "## Outcomes with clear winners"
  puts "This includes 2-way ties for 1st seed. Given that no matter the outcomes both teams advance."
  puts ""
  puts "Totals: #{results.count}/64 (#{results.count/64.0 * 100}%)"
  results.each do |outcome, group|
    puts "### Outcome No. #{ outcome.map(&:to_i).join.to_i(2) + 1 }"
    puts "* #{group[0].short} advances as #1 SEED"
    puts "* #{group[1].short} advances as #2 SEED"
    puts ""
    print_outcome(outcome, group, results_text)
  end

  puts "## Outcomes with Ties"
  puts "This are only the ties when 1 or more team in the tie does not advance to the next phase."
  puts ""
  puts "Totals: #{ties.count}/64 (#{ties.count/64.0 * 100}%)"
  ties.each do |outcome , group|
    puts "### Outcome No. #{ outcome.map(&:to_i).join.to_i(2) + 1 }"
    print_outcome(outcome, group, results_text)
  end
end

generate_outcomes(ARGV[0])
