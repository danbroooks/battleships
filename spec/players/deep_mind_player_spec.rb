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
      [0, 1, :unknown],
      [1, 0, :miss],
      [2, 1, :miss],
      [1, 2, :hit],
    ])
  end
end
