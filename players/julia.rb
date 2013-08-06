class Julia < Player

  def self.ancestor
    "Julia"
  end

  @@c1 = 0.757 #importance of fruit based on how close you are to clinching
  @@c2 = 0.0107 #ditto, but based on opponent closeness to clinching
  @@c3 = 2.10 #importance of fruits with many options available
  @@c4 = 0.252 #value fall-off from distance
  @@c5 = 2.07 #propensity to pick up

  def self.set_params(array)
    class_variable_set(:@@c1, array[0])
    class_variable_set(:@@c2, array[1])
    class_variable_set(:@@c3, array[2])
    class_variable_set(:@@c4, array[3])
    class_variable_set(:@@c5, array[4])
  end

  def self.params
    c1 = class_variable_get(:@@c1)
    c2 = class_variable_get(:@@c2)
    c3 = class_variable_get(:@@c3)
    c4 = class_variable_get(:@@c4)
    c5 = class_variable_get(:@@c5)
    [c1, c2, c3, c4, c5]
  end

  def new_game
    @numFruits = get_number_of_item_types
    @totalFruits = (0..@numFruits).map { |i| i != 0 ? get_total_item_count(i) : nil }
    @myFruits = Array.new(@numFruits+1)
    @opFruits = Array.new(@numFruits+1)
    @availFruits = Array.new(@numFruits+1)
  end

  def make_move
    @board = get_board

    @myPos = [get_my_x, get_my_y]
    @opPos = [get_opponent_x, get_opponent_y]

    (1..@numFruits).each do |i|
      @myFruits[i] = get_my_item_count(i)
      @opFruits[i] = get_opponent_item_count(i)
      @availFruits[i] = @totalFruits[i] - @myFruits[i] - @opFruits[i]
    end

    @boardValues = Array.new(width)
    width.times { |i| @boardValues[i] = Array.new(height,0) }
    valueBoard

    x = @myPos[0]
    y = @myPos[1]

    choices = { :take  => @board[x][y] > 0 ? @boardValues[x][y]   : -10,
                :north => y > 0            ? @boardValues[x][y-1] : -10,
                :east  => x < width - 1    ? @boardValues[x+1][y] : -10,
                :south => y < height - 1   ? @boardValues[x][y+1] : -10,
                :west  => x > 0            ? @boardValues[x-1][y] : -10 }

    return choices.max_by { |k,v| v }[0]
  end

  def valueBoard
    width.times do |i|
      height.times do |j|
        if @board[i][j] > 0 && (dist(@opPos, [i,j]) != 0 || dist(@myPos, [i,j]) == 0)
          addToBoardValues(fruitValue(@board[i][j]), [i,j])
        end
      end
    end
  end

  def fruitValue(fruitIndex)
    p = @totalFruits[fruitIndex] / 2 + 1 - @myFruits[fruitIndex]
    n = @totalFruits[fruitIndex] / 2 + 1 - @opFruits[fruitIndex]
    r = @availFruits[fruitIndex]

    p*n*r > 0 ? p ** (-@@c1) * n ** (-@@c2) * r ** (-@@c3) : 0
  end

  def addToBoardValues(value, point)
    width.times do |i|
      height.times do |j|
        distance = dist(point, [i,j])
        adjustment = distance == 0 ? @@c5 : distance ** -@@c4
        @boardValues[i][j] += value * adjustment
      end
    end
  end

  def dist(a,b)
    return (a[0] - b[0]).abs + (a[1] - b[1]).abs
  end

end
