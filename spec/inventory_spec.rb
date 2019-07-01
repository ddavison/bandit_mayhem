require 'inventory'

describe BanditMayhem::Inventory do
  it ' adds then removes an item' do
    subject.add_item('health_potion')
    expect(subject).to have_item('health_potion')
  end

  it 'is empty by default' do
    expect(subject).to eq([])
  end
end
