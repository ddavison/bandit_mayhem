require 'character'
require 'items/health_potion'

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
  end

  it '#dead? actor is dead when health is like 0' do
    subject.set_av('health', 0)
    expect(subject).to be_dead

    subject.set_av('health', 3)
    expect(subject).not_to be_dead

    subject.set_av('health', -47)
    expect(subject).to be_dead
  end

  context 'inventory' do
    it 'by default has no items' do
      expect(subject.inventory.all_items).to eq([])
    end

    it '#give gives an item' do
      subject.give(BanditMayhem::Items::HealthPotion)
      expect(subject.inventory).to have_item(BanditMayhem::Items::HealthPotion)
    end
  end

  context 'loot' do
    it 'can loot an enemy'
  end
end
