require 'character'

describe BanditMayhem::Character do
  subject { BanditMayhem::Characters::Player.new }
  let(:map) { BanditMayhem::Map.new('QA', {width: 2, height: 2})}

  context 'movement' do
    context '#move' do

    end

    context '#interact_with' do

    end
  end
end
