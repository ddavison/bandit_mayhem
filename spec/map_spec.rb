require 'map'
require 'character'
require 'colorize'

describe BanditMayhem::Map do
  subject { BanditMayhem::Map.new(name: 'qasmoke', file: File.absolute_path(File.join('spec', 'fixtures', 'map_qasmoke.yml'))) }
  let(:character) { BanditMayhem::Character.new }

  context 'initialization' do
    context 'default load' do
      subject { BanditMayhem::Map.new('lynwood') }

      it 'loads a default named map' do
        expect(subject.attributes).to include({ type: 'town' })
      end
    end

    context '[attrs]' do
      subject { BanditMayhem::Map.new(name: 'qasmoke', attributes: {name: 'TestMap'}) }

      it 'loads when attributes are set' do
        expect(subject.attributes).to include({ name: 'TestMap' })
      end
    end

    context '[file]' do
      subject { BanditMayhem::Map.new(name: 'qasmoke', file: File.absolute_path(File.join('spec', 'fixtures', 'map_qasmoke.yml'))) }

      it 'loads a specific map' do
        expect(subject.attributes).to include({ name: 'QA Smoke' })
      end
    end
  end

  describe '#build!' do
    context '2x2 map' do
      subject { BanditMayhem::Map.new(name: 'qasmoke', attributes: {width: 2, height: 2}) }

      let(:map) { subject.build!(character) }

      it 'will render 4 characters total in width and height' do
        m = subject.build!(character).split("\n")

        expect(m.size).to eq(4) # total level
      end

      it 'has corner bends' do
        map_lines = map.split("\n")

        expect(map_lines.first[0]).to eq(BanditMayhem::Maps::CORNER_UPPER_LEFT)
        expect(map_lines.first[-1]).to eq(BanditMayhem::Maps::CORNER_UPPER_RIGHT)

        expect(map_lines.last[0]).to eq(BanditMayhem::Maps::CORNER_LOWER_LEFT)
        expect(map_lines.last[-1]).to eq(BanditMayhem::Maps::CORNER_LOWER_RIGHT)
      end

      it 'left and right boundaries have vert walls' do
        y = map.split("\n")

        y.size.times do |x|
          if x != 0 && x == y.size # if it's not the boundary corner walls
            expect(y[x][0]).to eq(BanditMayhem::Maps::WALL_VERT)
            expect(y[x][-1]).to eq(BanditMayhem::Maps::WALL_VERT)
          end
        end
      end

      it 'top and bottom boundaries are horiz walls' do
        y = map.split("\n")

        top_row = y[0].chars
        bottom_row = y[-1].chars

        top_row.size.times do |x|
          if x != 0 && x == top_row.size
            expect(top_row[x]).to eq(BanditMayhem::Maps::WALL_HORIZ)
          end
        end

        bottom_row.size.times do |x|
          if x != 0 && x == bottom_row.size
            expect(bottom_row[x]).to eq(BanditMayhem::Maps::WALL_HORIZ)
          end
        end
      end
    end

    context '4x4 smoke map fixture with pois' do
      it 'renders a door' do
        expect(subject.get_entity_at(x: 1, y: 1)).to include({ type: 'door' })
      end

      it 'renders a coinpurse' do
        expect(subject.get_entity_at(x: 2, y: 1)).to include({ type: 'coinpurse' })
      end

      it 'renders a shop' do
        expect(subject.get_entity_at(x: 3, y: 1)).to include({ type: 'shop' })
      end

      it 'renders an item' do
        expect(subject.get_entity_at(x: 4, y: 1)).to include({ type: 'item', item: 'SmokeItem' })
      end
    end

    context 'walls' do
      before(:each) do
        subject.build!(character)
      end

      it 'renders a vert wall' do
        expect(subject.get_entity_at(x: 1, y: 2)).to include({ type: 'wall', direction: 'vert'})
        expect(subject.get_char_at(x: 1, y: 2)).to eq(BanditMayhem::Maps::WALL_VERT)
      end

      it 'renders a horiz wall' do
        expect(subject.get_entity_at(x: 2, y: 2)).to include({ type: 'wall', direction: 'horiz'})
        expect(subject.get_char_at(x: 2, y: 2)).to eq(BanditMayhem::Maps::WALL_HORIZ)
      end
    end
  end
end
