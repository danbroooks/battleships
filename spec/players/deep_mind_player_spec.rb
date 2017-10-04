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
    expect(subject.neighbors(state, 1, 1)).to eq([
      { x: 0, y: 1, state: :unknown },
      { x: 1, y: 0, state: :miss },
      { x: 2, y: 1, state: :miss },
      { x: 1, y: 2, state: :hit},
    ])
  end
end
