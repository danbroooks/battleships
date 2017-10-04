class DeepMindPlayer

  def self.slot(x, y, val, nb = [])
    Coordinate.new(x, y, val, nb)
  end

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

    def occupied?
      state == :occupied
    end

    def to_a
      [x,y]
    end
  end

  def name
    "Deep Mind"
  end

  def new_game
    s = generate_ships([5, 4, 3, 3, 2], board(10, 10))
    p s
  end

  def board(height, width)
    zip_coordinates(
      (0...height).map do |x|
        (0...width).map do |y|
          :unknown
        end
      end
    )
  end

  def generate_ships(ships, state)
    if ships.empty?
      []
    else
      size = ships.first
      position_x = rand(9 - size)
      position_y = rand(9 - size)
      direction = rand(2) == 1 ? :down : :across

      if check_squares_unoccupied(position_x, position_y, size, direction, state)
        ship = [ position_x, position_y, size, direction ]
        [ship] + generate_ships(ships.drop(1), update_state(position_x, position_y, size, direction, state))
      else
        puts "Squares occupied between #{position_x}, #{position_y}, retrying... (#{size})"
        generate_ships(ships, state)
      end
    end
  end

  def check_squares_unoccupied(x, y, size, direction, state)
    area = state.select do |slot|
      if direction == :down
        slot_is_contained_in([x, y], [x, y + size], slot)
      else
        slot_is_contained_in([x, y], [x + size, y], slot)
      end
    end

    area.select(&:occupied?).size == 0
  end

  def slot_is_contained_in(from, to, slot)
    from_x, from_y = from
    to_x, to_y = to

    [
      slot.x >= from_x,
      slot.x <= to_x,
      slot.y >= from_y,
      slot.y <= to_y,
    ].all?
  end

  def update_state(x, y, size, direction, state)
    state.map do |slot|
      if direction == :down   && slot.x == x && slot.y >= y && slot.y < y + size ||
         direction == :across && slot.y == y && slot.x >= x && slot.x < x + size
        Coordinate.new(slot.x, slot.y, :occupied)
      else
        slot
      end
    end
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
    move
  end

  def pick_random(state)
    zip_coordinates(state)
      .select(&:unknown?)
      .shuffle
      .first
      .to_a
  end

  def zip_coordinates(state)
    state.map.with_index do |col, y|
      col.map.with_index do |value, x|
       Coordinate.new(x, y, value, neighbors(state, x, y))
      end
    end.flatten(1)
  end

  def create_slot(state, x, y)
    if pick(state, y) != nil && pick(state[y], x) != nil
      Coordinate.new(x, y, state[y][x])
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
