require 'item'

describe BanditMayhem::Item do
  it 'initializes' do
    expect(subject).to have_received(:initialize)
  end
end
