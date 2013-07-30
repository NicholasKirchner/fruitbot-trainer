require "timeout"

class Game
  
  def initialize(player1, player2)
    @board = Board.new
    @player1 = player1.new(@board,1)
    @player2 = player2.new(@board,2)
    @player1.new_game
    @player2.new_game
  end

  # Returns nil if the game takes over 250 moves, positive if player 1 wins,
  # negative if player 2 wins, and 0 if a tie.
  def play
    moves = 0
    begin
      moves +=1
      begin
        p1 = nil
        p1 = Timeout::timeout(5) { @player1.make_move }
        p2 = Timeout::timeout(5) { @player2.make_move }
        @board.process_move(p1, p2)
      rescue Timeout::Error
        puts "move timeout"
        return p1 ? 1 : -1
      end
    end until @board.finished? || moves == 250
    return @board.finished?
  end
  
end
