require_relative '../../players/deep_mind_player'

RSpec.describe DeepMindPlayer do
  it 'can transform all the coordinates and map them to an object' do
    expect(subject.zip_coordinates([[:unknown]]).size).to be(1)
  end

  it 'can work out the neighbors of a cell' do
    state = [
      [:unknown, :unknown, :unknown],
      [:miss, :unknown, :hit],
      [:unknown, :miss, :unknown]
    ]

    neighbors = subject.neighbors(state, 1, 1).map do |co|
      [co.x, co.y, co.state]
    end

    expect(neighbors).to eq([
      [0, 1, :miss],
      [1, 0, :unknown],
      [2, 1, :hit],
      [1, 2, :miss],
    ])
  end

  def slot(x, y)
    DeepMindPlayer.slot(x, y, :unknown)
  end

  it 'can determine if a slot is contained in a specified area' do
    expect(subject.slot_is_contained_in([1, 1], [1, 3], slot(1, 2))).to be(true)
    expect(subject.slot_is_contained_in([2, 3], [4, 5], slot(3, 4))).to be(true)
    expect(subject.slot_is_contained_in([1, 1], [1, 3], slot(5, 6))).to be(false)
    expect(subject.slot_is_contained_in([6, 8], [7, 9], slot(1, 2))).to be(false)
  end
end
