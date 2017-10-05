class NaiveDeepMindPlayer

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
    "Naive Deep Mind"
  end

  def new_game
    generate_ships([5, 4, 3, 3, 2], board(10, 10))
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

  def generate_ships(ships, state, buffer = 4.0)
    if ships.empty?
      []
    else
      size = ships.first

      free_down = state.select(&:unknown?).select do |sq|
        sq.y <= size && check_squares_unoccupied(sq.x, sq.y, size, :down, state, buffer.ceil)
      end.map do |sq|
        [:down, sq]
      end

      free_across = state.select(&:unknown?).select do |sq|
        sq.x <= size && check_squares_unoccupied(sq.x - size, sq.y, size, :across, state, buffer.ceil)
      end.map do |sq|
        [:across, sq]
      end

      available = free_down + free_across

      if available.size > 0
        direction, square = available.shuffle.first
        x = square.x
        y = square.y
        puts "Added ship of size #{size}, using buffer #{buffer.ceil}"
        ship = [ x, y, size, direction ]
        [ship] + generate_ships(ships.drop(1), update_state(x, y, size, direction, state))
      else
        puts "Squares occupied between #{x}, #{y}, retrying... (#{buffer.ceil})"
        generate_ships(ships, state, [0,buffer - 1].max)
      end
    end
  end

  def check_squares_unoccupied(x, y, size, direction, state, buffer)
    from = [ x - buffer, y - buffer ]
    to = direction == :down ? [ x + buffer, y + size + buffer ] : [ x + size + buffer, y + buffer ]

    area = state.select do |slot|
      slot_is_contained_in(from, to, slot)
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
      guess(priority.first.to_a)
    else
      guess(pick_random(state))
    end
  end

  def guess(move)
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
