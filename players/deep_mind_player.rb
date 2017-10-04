class DeepMindPlayer
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
    move = zip_coordinates(state).select do |square|
      square[:state] == :unknown
    end.shuffle.first

    [move[:x], move[:y]]
  end

  def zip_coordinates(state)
    state.map.with_index do |row, x| 
      row.map.with_index do |value, y| 
        {
          x: x,
          y: y,
          state: value,
          neighbors: neighbors(state, x, y)
        }
      end
    end.flatten(1)
  end

  def create_slot(state, x, y)
    if state[x] != nil && state[x][y] != nil
      {
        x: x,
        y: y,
        state: state[x][y]
      }
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
