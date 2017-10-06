class DeepMindPlayer

  attr_accessor :smallest_ship, :previous_remaining, :history

  def self.slot(x, y, val, nb = [])
    Coordinate.new(x, y, val, nb)
  end

  class Coordinate
    attr_accessor :state
    attr_reader :x, :y, :neighbors

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

    def sunk?
      state == :sunk
    end

    def occupied?
      state == :occupied
    end

    def to_a
      [x,y]
    end
  end

  class ShipPlacer
    def self.place_ships(ships, state)
      self.new.generate_ships(ships, state)
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
          ship = [ x, y, size, direction ]
          [ship] + generate_ships(ships.drop(1), update_state(x, y, size, direction, state))
        else
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
  end

  def name
    "Deep Mind (╯°□°）╯︵ ┻━┻"
  end

  def new_game
    @history = []
    @sunk = []
    ShipPlacer.place_ships([5, 4, 3, 3, 2], board(10, 10))
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

  def take_turn(state, ships_remaining)
    @smallest_ship = ships_remaining.min

    if @previous_remaining == nil
      @previous_remaining = [] + ships_remaining
    end

    state = zip_coordinates(state)
    @history = sync_history(@history, state, ships_remaining)
    sunk_ship = diff(@previous_remaining, ships_remaining).first

    if sunk_ship != nil
      @sunk = @sunk + @history.select(&:hit?).last(sunk_ship)
    end

    state = update_state(state, @sunk)

    @previous_remaining = [] + ships_remaining

    guess(consider_options(state).first)
  end

  def sync_history(history, state, ships_remaining)
    history.map do |slot|
      slot.state = state.find { |_| _.x == slot.x && _.y == slot.y }.state
      slot
    end
  end

  def diff(a = [], b = [])
    if a.empty?
      b
    elsif b.empty?
      a
    elsif a.include?(b.first)
      a.delete_at(a.index(b.first))
      diff(a, b.drop(1))
    elsif b.include?(a.first)
      b.delete_at(b.index(a.first))
      diff(a.drop(1), b)
    else
      [a.first, b.first] + diff(a.drop(1), b.drop(1))
    end
  end

  def update_state(state, sunk)
    state.map do |slot|
      if sunk.map(&:to_a).include?(slot.to_a)
        slot.state = :sunk
      end

      slot
    end
  end

  def consider_options(state)
    if hit_pairs(state).size > 0
      hit_pairs(state)
    elsif hit_neighbors(state).size > 0
      hit_neighbors(state)
    else
      pick_random(state)
    end
  end

  def guess(move)
    @history = @history + [ move ]

    if @history.uniq.size != @history.size
      puts "WARNING duplicate turns made"
    end

    move.to_a
  end

  def hit_pairs(state)
    r = state.group_by(&:y).map do |_, row|
      hits = row.select(&:hit?)
      if hits.size > 1
        min = hits.min_by(&:x)
        max = hits.max_by(&:x)
       [
          state.find { |slot| slot.x == min.x - 1 && slot.y == min.y },
          state.find { |slot| slot.x == max.x + 1 && slot.y == max.y },
       ].compact.select(&:unknown?)
      end
    end.compact

    c = state.group_by(&:x).map do |_, col|
      hits = col.select(&:hit?)
      if hits.size > 1
        min = hits.min_by(&:y)
        max = hits.max_by(&:y)
        [
          state.find { |slot| slot.x == min.x && slot.y == min.y - 1 },
          state.find { |slot| slot.x == max.x && slot.y == max.y + 1 },
        ].compact.select(&:unknown?)
      end
    end.compact

    (r + c).flatten.shuffle
  end

  def hit_neighbors(state)
    state.select(&:hit?)
      .map { |_| _.neighbors.select(&:unknown?) }
      .flatten
  end

  def pick_random(state)
    available = state.select(&:unknown?)

    early_game = available.select do |_|
      [
        (_.x + (_.y % 4)) % 4 == 0,
        (_.y - 2) % 3 == 0,
      ].all?
    end

    unless early_game.empty?
      return early_game.shuffle
    end

    seek = available.select { |_| (_.x + _.y) % ((@smallest_ship / 2).floor * 2) == 0 }.select(&:unknown?)

    unless seek.empty?
      return seek.shuffle
    end

    available.select(&:unknown?)
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
