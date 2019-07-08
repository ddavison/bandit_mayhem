require 'shop'
require 'character'

describe BanditMayhem::Shop do
  subject { BanditMayhem::Shop.new({inventory: ['HealthPotion']}, character) }

  let(:character) { BanditMayhem::Character.new }

  it 'has HealthPotion in stock' do
    expect(subject.inventory).to include('HealthPotion')
  end

  context '#buy!' do
    before(:each) do
      character.set_av('gold', 100)
    end

    xit 'can buy an item' do
      expect(subject.inventory.size).to eq(1)

      subject.buy!('HealthPotion')

      expect(subject.inventory.size).to eq(0)
    end
  end
end
