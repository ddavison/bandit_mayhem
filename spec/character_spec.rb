require 'character'
require 'characters/bandit'

describe BanditMayhem::Character do
  subject { BanditMayhem::Character.new({health: 100, max_health: 100}) }
  context 'actor values' do
    it '#set_av/#get_av can put/get with base' do
      subject.set_av('foo', 'bar')

      expect(subject.get_av('foo')).to eq('bar')
      expect(subject.get_av('base_foo')).to eq('bar')
    end

    it '#set_av can overwrite an actor value' do
      subject.set_av('foo', 'bar')
      expect(subject.get_av('foo')).to eq('bar')

      subject.set_av('foo', 'baz')
      expect(subject.get_av('foo')).to eq('baz')
    end

    it '#get_av sets default av when specified' do
      expect(subject.get_av('foo', 'baz')).to eq('baz')
    end

    it '#get_av with a default doesnt override something already there' do
      subject.set_av('foo', 'bar')
      expect(subject.get_av('foo', 'baz')).to eq('bar')
    end
  end

  it '#dead? actor is dead when health is like 0' do
    subject.set_av('health', 0)
    expect(subject).to be_dead

    subject.set_av('health', 3)
    expect(subject).not_to be_dead

    subject.set_av('health', -47)
    expect(subject).to be_dead
  end

  context 'looting' do
    subject { BanditMayhem::Character.new({health: 100, gold: 0})}
    let(:character_level_1) { BanditMayhem::Character.new({health: 0, gold: 10, level: 1}) }
    let(:character_level_5) { BanditMayhem::Character.new({health: 0, gold: 20, level: 5}) }

    it 'can loot another characters\' gold' do
      expect(subject.get_av('gold')).to eq(0) # starting with zero
      expect(character_level_1.get_av('gold')).to eq(10) # base gold starting at 0

      subject.loot(character_level_1)

      expect(subject.get_av('gold')).to eq(15)
      expect(character_level_1.get_av('gold')).to be_nil
    end

    it 'gold calculates (level*15+(attacks*3))' do
      at_level_1 = 1
      number_of_attacks = 0
      gold_should_be = at_level_1 * 15 + (number_of_attacks * 3)

      expect(character_level_1.get_av('level')).to eq(at_level_1)
      expect(subject.loot(character_level_1)).to include({gold: gold_should_be})
    end
  end

  context 'battle' do

  end
end
