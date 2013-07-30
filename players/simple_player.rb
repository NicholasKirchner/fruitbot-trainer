class SimplePlayer < Player

  def make_move
    @board = get_board();
    if has_item(@board[get_my_x][get_my_y])
      return :take
    end

    @to_consider = Array.new
    @considered = Array.new(width)
    width.times do |i|
      @considered[i] = Array.new(height)
      height.times do |j|
        @considered[i][j] = 0
      end
    end

    return findMove( node(get_my_x, get_my_y, -1) )

  end

  def findMove(n)
    if has_item(@board[n[:x]][n[:y]])
      return n[:move]
    end

    possibleMove = n[:move]

    #North
    if considerMove( n[:x], n[:y]-1 )
      possibleMove = :north if n[:move] == -1
      @to_consider.push( node( n[:x], n[:y]-1, possibleMove ) )
    end

    #South
    if considerMove( n[:x], n[:y]+1 )
      possibleMove = :south if n[:move] == -1
      @to_consider.push( node( n[:x], n[:y]+1, possibleMove ) )
    end

    #West
    if considerMove( n[:x]-1, n[:y] )
      possibleMove = :west if n[:move] == -1
      @to_consider.push( node( n[:x]-1, n[:y], possibleMove ) )
    end

    #East
    if considerMove( n[:x]+1, n[:y] )
      possibleMove = :east if n[:move] == -1
      @to_consider.push( node( n[:x]+1, n[:y], possibleMove ) )
    end

    unless @to_consider.empty?
      next_node = @to_consider.shift
      return findMove(next_node)
    end

    return -1
  end

  def considerMove(x,y)
    return false unless isValidMove(x,y)
    return false if @considered[x][y] > 0
    @considered[x][y] = 1;
    return true
  end

  def isValidMove(x,y)
    !( x < 0 || y < 0 || x >= width || y >= height )
  end

  def node(x, y, move)
    { x: x, y: y, move: move }
  end

end
