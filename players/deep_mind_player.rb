class DeepMindPlayer

  class Coordinate
    attr_reader :x, :y, :state, :neighbors

    def initialize(x, y, state, neighbors = [])
      @x = x
      @y = y
      @state = state
      @neighbors = neighbors
    end

    def unknown?
      state == :unknown
    end

    def hit?
      state == :hit
    end

    def miss?
      state == :miss
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
    priority = zip_coordinates(state)
      .select(&:hit?)
      .map do |slot|
        same_row = slot.neighbors.select do |adj|
          adj.x == slot.x
        end
        same_col = slot.neighbors.select do |adj|
          adj.y == slot.y
        end

        [
          same_row.select(&:unknown?),
          same_col.select(&:unknown?),
        ]
      end
      .flatten

    if priority.size > 0
      p priority.map(&:to_a)
      guess(priority.first.to_a)
    else
      guess(pick_random(state))
    end
  end

  def guess(move)
    p ({ :move => move })
    move.reverse
  end

  def pick_random(state)
    zip_coordinates(state)
      .select(&:unknown?)
      .shuffle
      .first
      .to_a
  end

  def zip_coordinates(state)
    state.map.with_index do |col, x| 
      col.map.with_index do |value, y|
       Coordinate.new(x, y, value, neighbors(state, x, y))
      end
    end.flatten(1)
  end

  def create_slot(state, x, y)
    if pick(state, x) != nil && pick(state[x], y) != nil
      p state[x][y]
      Coordinate.new(x, y, state[x][y])
    else
      nil
    end
  end

  def pick(arr, i)
    if i < 0 || i > arr.size
      nil
    else
      arr[i]
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
