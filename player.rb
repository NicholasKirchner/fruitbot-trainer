class Player

  def initialize(board,number) #number is 1 or 2
    @game_board = board
    @number = number
  end

  def new_game
  end

  def height
    @game_board.height
  end

  def width
    @game_board.width
  end

  def has_item(i)
    return i > 0
  end

  def get_board
    return @game_board.board
  end

  def get_number_of_item_types
    return @game_board.number_fruit_types
  end

  def get_my_x
    @number == 1 ? @game_board.player1_x : @game_board.player2_x
  end

  def get_my_y
    @number == 1 ? @game_board.player1_y : @game_board.player2_y
  end

  def get_opponent_x
    @number == 2 ? @game_board.player1_x : @game_board.player2_x
  end

  def get_opponent_y
    @number == 2 ? @game_board.player1_y : @game_board.player2_y
  end

  def get_my_item_count(type)
    @number == 1 ? @game_board.player1_items[type-1] : @game_board.player2_items[type-1]
  end

  def get_opponent_item_count(type)
    @number == 2 ? @game_board.player1_items[type-1] : @game_board.player2_items[type-1]
  end

  def get_total_item_count(type)
    @game_board.total_items[type-1]
  end

end
