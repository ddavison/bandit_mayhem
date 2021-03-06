require 'map'
require 'character'
require 'colorize'

describe BanditMayhem::Map do
  subject { BanditMayhem::Map.new(file: File.absolute_path(File.join('spec', 'fixtures', 'maps', 'qasmoke.yml'))) }
  let(:character) { BanditMayhem::Character.new }

  context 'initialization' do
    context 'default load' do
      subject { BanditMayhem::Map.new('lynwood') }

      it 'loads a default named map' do
        expect(subject.attributes).to include({ type: 'town' })
      end
    end

    context 'a hash object' do
      subject { BanditMayhem::Map.new(name: 'TestMap') }

      it 'loads when a hash is passed' do
        expect(subject.attributes).to include({ name: 'TestMap' })
      end
    end

    context '[file]' do
      subject { BanditMayhem::Map.new(file: File.absolute_path(File.join('spec', 'fixtures', 'maps', 'qasmoke.yml'))) }

      it 'loads a specific map' do
        expect(subject.attributes).to include({ name: 'QA Smoke' })
      end
    end
  end

  describe '#build!' do
    before(:each) do
      subject.build!(character)
    end

    context '2x2 map' do
      subject { BanditMayhem::Map.new(width: 2, height: 2) }

      let(:map) { subject.matrix }

      it 'will render 4 characters total in width and height' do
        expect(map.size).to eq(4) # total level
      end

      it 'has corner bends' do
        expect(map.first[0]).to eq(BanditMayhem::Maps::CORNER_UPPER_LEFT)
        expect(map.first[-1]).to eq(BanditMayhem::Maps::CORNER_UPPER_RIGHT)

        expect(map.last[0]).to eq(BanditMayhem::Maps::CORNER_LOWER_LEFT)
        expect(map.last[-1]).to eq(BanditMayhem::Maps::CORNER_LOWER_RIGHT)
      end

      it 'left and right boundaries have vert walls' do
        map.size.times do |x|
          if x != 0 && x == map.size # if it's not the boundary corner walls
            expect(y[x][0]).to eq(BanditMayhem::Maps::WALL_VERT)
            expect(y[x][-1]).to eq(BanditMayhem::Maps::WALL_VERT)
          end
        end
      end

      it 'top and bottom boundaries are horiz walls' do
        top_row = map[0]
        bottom_row = map[-1]

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
      before(:each) do
        subject.build!(character)
      end

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
      after(:each) do
        puts subject.render(character)
      end

      it 'renders a vert wall' do
        expect(subject.get_entity_at(x: 1, y: 2)).to include({ type: 'wall', direction: 'vert'})
        expect(subject.get_char_at(x: 1, y: 2)).to eq(BanditMayhem::Maps::WALL_VERT)
      end

      it 'renders a horiz wall' do
        expect(subject.get_entity_at(x: 2, y: 2)).to include({ type: 'wall', direction: 'horiz'})
        expect(subject.get_char_at(x: 2, y: 2)).to eq(BanditMayhem::Maps::WALL_HORIZ)
      end

      context 'interiors' do
        let(:map) { subject.matrix }

        context 'boundaries' do
          it 'draws an interior' do
            expect(map[3][5]).to eq(BanditMayhem::Maps::INTERIOR_CORNER_UPPER_LEFT)
            expect(map[3][6]).to eq(BanditMayhem::Maps::INTERIOR_WALL_HORIZ)
          end
        end
        context 'door'
      end
    end

    context 'floor' do
      let(:default_map) { BanditMayhem::Map.new(width: 1, height: 1) }
      let(:town_map) { BanditMayhem::Map.new(width: 1, height: 1, type: :town) }
      let(:grass_map) { BanditMayhem::Map.new(width: 1, height: 1, type: :grass) }

      it 'by default, renders spaces' do
        default_map.build!(character)

        expect(default_map.get_char_at(x: 1, y: 1)).to eq(" ")
      end
    end
  end
end
