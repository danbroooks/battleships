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
        }
      end
    end.flatten(1)
  end
end
