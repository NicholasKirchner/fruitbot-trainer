require_relative "board.rb"
require_relative "game.rb"
require_relative "player.rb"
require_relative "players/random_player.rb"
require_relative "players/simple_player.rb"
require_relative "players/my_player.rb"
require_relative "players/julia.rb"
require 'csv'

BIG_MUTATION_PROB = 0.06
MEDIUM_MUTATION_PROB = 0.18
SMALL_MUTATION_PROB = 0.42

RUNTIME = 3_600 * 10 #ten hours
POOL_CAPACITY = 1_000

#Mutations happen by multiplying parameters by a log-normal random variate.
#if given a second argument >= 1, will make a huge mutation.
def mutate(player, a = rand)
  if a < BIG_MUTATION_PROB
    sigma = 0.8
  elsif a < MEDIUM_MUTATION_PROB
    sigma = 0.25
  elsif a < SMALL_MUTATION_PROB
    sigma = 0.07
  elsif a < 1
    sigma = 0
  else
    sigma = 1
  end
  new_player = player.clone
  params = new_player.params
  new_player.set_params(params.map { |i| i * Math.exp(sigma * gaussian) })
  return new_player
end

#box-muller transform.  Could get a small speed increase by putting this in a class and not discarding the second variate.
def gaussian
  theta = 2 * Math::PI * rand
  rho = Math.sqrt(-2 * Math.log(1 - rand))
  x = rho * Math.cos(theta)
  y = rho * Math.sin(theta)
  return x
end

#RandomPlayer is thrown in to ensure that not everyone gets killed off.
fixed_players = [RandomPlayer] + [SimplePlayer, Hallie, Julia] * 3
mutating_players = Array.new(100, mutate(Julia, 1)) + [Julia, Hallie] + Array.new(100, mutate(Hallie, 1))

start_time = Time.now

puts "Evolving"

#Plays games.  If mutating player loses, that player is killed.
#If mutating player wins, the player is kept and a mutated clone created if space permits.
#If mutating player ties, there's a 30% chance of death, a 30% chance of a mutated clone being created if space permits, and a 40% chance that player is simply kept.
while Time.now - start_time < RUNTIME && mutating_players.any?
  player1 = fixed_players.sample
  player2_index = rand(mutating_players.length)
  player2 = mutating_players[player2_index]
  game = Game.new(player1, player2)
  result = game.play
  if result == nil || result > 0
    mutating_players.delete_at(player2_index)
  elsif result < 0
    mutating_players << mutate(player2) if mutating_players.length < POOL_CAPACITY
  else
    a = rand
    mutating_players.delete_at(player2_index) if a < 0.3
    mutating_players << mutate(player2) if a > 0.3 && mutating_players.length < POOL_CAPACITY
  end
end

puts "Determining top 25 players."

#Now, have the remaining players play 100 games each and give them each a score
#A win is +1 and a loss is -1
#There's a little luck involved here, so I'll pick the winners here and play
#them off.
scores = []
mutating_players.each do |player1|
  score = 0
  [SimplePlayer, Hallie, Julia].each do |player2|
    50.times do
      game = Game.new(player1, player2)
      result = game.play
      if result == nil || result < 0
        score = score - 1
      elsif result > 0
        score += 1
      end
    end
  end
  scores << { :score => score, :player => player1 }
end

puts "ordering the top 25"

#Find the highest scores, and have them compete
best = scores.sort_by { |i| -i[:score] }.first(25)

best.each do |candidate|
  playoff_score = 0
  player1 = candidate[:player]
  [SimplePlayer, Julia, Hallie].each do |player2|
    750.times do
      game = Game.new(player1, player2)
      result = game.play
      if result == nil || result < 0
        playoff_score = playoff_score - 1
      elsif result > 0
        playoff_score += 1
      end
    end
  end
  candidate[:playoff] = playoff_score
end

puts "writing to file"

CSV.open("players.csv", "wb") do |csv|
  best.sort_by { |i| -i[:playoff] }.each do |candidate|
    player = candidate[:player]
    csv << [candidate[:playoff], player.ancestor] + player.params
  end
end
