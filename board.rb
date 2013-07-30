class Board

  BOARD_MIN_SIZE = 5
  BOARD_MAX_SIZE = 15

  MIN_FRUIT_TYPES = 3
  MAX_FRUIT_TYPES = 5

  attr_reader :board, :number_fruit_types, :player1_x, :player2_x, :player1_y,
                :player2_y, :player1_items, :player2_items, :total_items,
                :height, :width

  def initialize
    @height = rand(BOARD_MIN_SIZE..BOARD_MAX_SIZE)
    @width = rand(BOARD_MIN_SIZE..BOARD_MAX_SIZE)

    @board = Array.new(@width)
    @width.times { |i| @board[i] = Array.new(@height, 0) }

    begin
      @number_fruit_types = rand(MIN_FRUIT_TYPES..MAX_FRUIT_TYPES)
    end while @number_fruit_types ** 2 >= @height * @width

    @total_items = Array.new(@number_fruit_types) { |i| i * 2 + 1 }
    @player1_items = Array.new(@number_fruit_types, 0)
    @player2_items = Array.new(@number_fruit_types, 0)

    @number_fruit_types.times do |i|
      @total_items[i].times do
        begin
          x = rand(@width)
          y = rand(@height)
        end while @board[x][y] != 0
        @board[x][y] = i + 1
      end
    end

    begin
      x = rand(@width)
      y = rand(@height)
    end while @board[x][y] != 0
    @player1_x = x
    @player2_x = x
    @player1_y = y
    @player2_y = y
  end

  def process_move(player1_move, player2_move)

    if @player1_x == @player2_x && @player1_y == @player2_y && player1_move == :take && player2_move == :take && @board[@player1_x][@player1_y] > 0
      @player1_items[@board[@player1_x][@player1_y] - 1] += Rational(1,2)
      @player2_items[@board[@player2_x][@player2_y] - 1] += Rational(1,2)
      @board[@player1_x][@player1_y] = 0
    else
      if player1_move == :take && @board[@player1_x][@player1_y] > 0
        @player1_items[@board[@player1_x][@player1_y] - 1] += 1
        @board[@player1_x][@player1_y] = 0
      end
      if player2_move == :take && @board[@player2_x][@player2_y] > 0
        @player2_items[@board[@player2_x][@player2_y] - 1] += 1
        @board[@player2_x][@player2_y] = 0
      end
    end

    if player1_move == :north && @player1_y - 1 >= 0
      @player1_y = @player1_y - 1
    end
    if player2_move == :north && @player2_y - 1 >= 0
      @player2_y = @player2_y - 1
    end
    if player1_move == :south && @player1_y + 1 < @height
      @player1_y = @player1_y + 1
    end
    if player2_move == :south && @player2_y + 1 < @height
      @player2_y = @player2_y + 1
    end
    if player1_move == :east && @player1_x + 1 < @width
      @player1_x = @player1_x + 1
    end
    if player2_move == :east && @player2_x + 1 < @width
      @player2_x = @player2_x + 1
    end
    if player1_move == :west && @player1_x - 1 >= 0
      @player1_x = @player1_x - 1
    end
    if player2_move == :west && @player2_x - 1 >= 0
      @player2_x = @player2_x - 1
    end
  end

  def finished?
    item_type_score_max = 0;
    item_type_score_min = 0;

    fruit_types_left = @number_fruit_types
    @number_fruit_types.times do |i|
      diff = @player1_items[i] - @player2_items[i]
      numleft = @total_items[i] - @player1_items[i] - @player2_items[i]
      fruit_score_min = diff - numleft
      fruit_score_max = diff + numleft
      if fruit_score_min == 0 && fruit_score_max == 0 #Tie
        fruit_types_left = fruit_types_left - 1
      elsif fruit_score_min >= 0 #player 1 has win or tie
        item_type_score_max += 1
        if fruit_score_min > 0 #player 1 has win
          item_type_score_min += 1
          fruit_types_left = fruit_types_left - 1
        end
      elsif fruit_score_max <= 0 #player 2 has win or tie
        item_type_score_min -= 1
        if fruit_score_max < 0 #player 2 has win
          item_type_score_max -= 1
          fruit_types_left = fruit_types_left - 1
        end
      elsif numleft != 0 #still undecided
        item_type_score_min -= 1
        item_type_score_max += 1
      end
    end

    if item_type_score_max < 0
      return item_type_score_max
    elsif item_type_score_min > 0
      return item_type_score_min
    elsif fruit_types_left == 0
      return 0
    end

    return nil
  end

end
