require 'characters/player'
require 'weapons/stick'

describe BanditMayhem::Characters::Player do
  subject { BanditMayhem::Characters::Player.new({}) }
  it 'defaults the name to nigel' do
    expect(subject.get_av('name')).to eq('Nigel')
  end

  it 'starts in Lynwood' do
    expect(subject.location[:map].to_s).to eq('Lynwood')
  end

  it 'starts at a health of 100' do
    expect(subject.get_av('health')).to eq(100)
    expect(subject.get_av('base_health')).to eq(100)
    expect(subject).not_to be_dead
  end

  it 'starts at level 1' do
    expect(subject.get_av('level')).to eq(1)
  end

  it 'has an empty inventory' do
    expect(subject.items).to eq([])
  end

  it 'has literally no luck on start' do
    expect(subject.get_av('luck')).to be_nil
  end
end
