class RandomPlayer < Player

  def make_move
    board = get_board
    
    if board[get_my_x][get_my_y] > 0
      return :take
    end

    return [:north, :south, :east, :west].sample
  end

end
