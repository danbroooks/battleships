class DeepMindPlayer

  class Coordinate
    attr_reader :x, :y, :state

    def initialize(x, y, state, neighbors = [])
      @x = x
      @y = y
      @state = state
      @neighbors = neighbors
    end

    def unknown?
      state == :unknown
    end

    def to_a
      [x,y]
    end
  end

  def name
    "Deep Mind"
  end

  def new_game
    [
      [5, 0, 5, :across],
      [5, 1, 4, :across],
      [5, 2, 3, :across],
      [5, 3, 3, :across],
      [5, 4, 2, :across]
    ]
  end

  def take_turn(state, ships_remaining)
    zip_coordinates(state)
      .select(&:unknown?)
      .shuffle
      .first
      .to_a
  end

  def zip_coordinates(state)
    state.map.with_index do |row, x| 
      row.map.with_index do |value, y|
       Coordinate.new(x, y, value, neighbors(state, x, y))
      end
    end.flatten(1)
  end

  def create_slot(state, x, y)
    if state[x] != nil && state[x][y] != nil
      Coordinate.new(x, y, state[x][y])
    else
      nil
    end
  end

  def neighbors(state, x, y)
    [
      create_slot(state, x - 1, y),
      create_slot(state, x, y - 1),
      create_slot(state, x + 1, y),
      create_slot(state, x, y + 1),
    ].compact
  end
end
