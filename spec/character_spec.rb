require 'character'
require 'characters/bandit'

describe BanditMayhem::Character do
  subject { BanditMayhem::Character.new({health: 100, max_health: 100, level: 1}) }

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

    it '#dead? actor is dead when health is like 0' do
      subject.set_av('health', 0)
      expect(subject).to be_dead

      subject.set_av('health', 3)
      expect(subject).not_to be_dead

      subject.set_av('health', -47)
      expect(subject).to be_dead
    end
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
      # gold = level * 15 (attacks * 3)
      at_level_1 = 1
      number_of_attacks = 0
      gold_should_be = at_level_1 * 15 + (number_of_attacks * 3)

      expect(character_level_1.get_av('level')).to eq(at_level_1)
      expect(subject.loot(character_level_1)).to include({ gold: gold_should_be })
    end

    it 'doesnt override players existing gold. it adds it' do
      subject.set_av('gold', 10)
      character_level_1.set_av('health', 0) # has to be dead
      character_level_1.set_av('gold', 5) # has to be dead

      expect(subject.get_av('gold')).to eq(10)
      subject.loot(character_level_1)
      expect(subject.get_av('gold')).to eq(15)
    end
  end

  context 'battle' do
    let(:adversary) { BanditMayhem::Character.new({health: 100}) }

    context '#calculate_attack_damage' do
      # this test is in here in case the formula for attack damage ever gets changed (for scaling)
      # dmg = str + weapon.str + (level * 5) + (luck / 3)
      let(:str) { subject.get_av('str') }
      let(:level) { 1 }
      let(:weapon_str) { 0 } # no weapon = zero weapon.str
      let(:luck) { 0 }
      let(:dmg) { str + weapon_str + (level * 5) + (luck / 3) }

      it 'follows  dmg = str + weapon.str + (level * 5) + (luck / 3)' do
        expect(subject.attack(adversary)).to include({damage_dealt: dmg})
      end
    end

    context 'attacking' do
      it 'can attack another character with base strength' do
        expect(subject.get_av('str')).to eq(10)
        expect(subject.get_av('attacks')).to be_nil

        expect(subject.attack(adversary)).to include({target_health_before: 100, damage_dealt: 15})
        expect(subject.get_av('attacks')).to eq(1)
      end
    end

    context 'defending' do
      let(:health) { subject.get_av('health') }

      it 'can be attacked and lose health' do
        expect(health).to eq(100)

        adversary.attack(subject)

        expect(subject.get_av('health')).to be < health
      end
    end
  end

  context 'items' do
    let(:weapon) { BanditMayhem::Weapon.new }
    let(:consumable) { Class.new(BanditMayhem::Item) do
      def use_on!(actor)
        actor.set_av('health',
          actor.get_av('health') + 25)
      end
    end}

    context 'weapons' do
      it '#equip! equips a weapon' do
        expect(subject.weapon).to be_nil
        subject.equip!(weapon)

        expect(subject.weapon).to be(weapon)
      end

    end

    it 'cant #equip! items or consumables' do
      expect(subject.weapon).to be_nil
      subject.equip!(consumable)

      expect(subject.weapon).to be_nil
    end
  end

  describe 'movement' do
    let(:map) { BanditMayhem::Map.new(width: 5, height: 5) }

    context 'warping' do
      it 'saves the last location' do
        expect(subject.location).to include({x: -1, y: -1})
        expect(subject.location[:last]).to be_nil

        subject.warp(x: 1, y: 1)
        expect(subject.location).to include({x: 1, y: 1})
        expect(subject.location[:last]).to include({x: 1, y: 1})
      end
    end

    context '[wasd]' do
      before(:each) do
        subject.location[:map] = map
        subject.warp(x: 2, y: 2)
      end


      it '#warp takes us to 2,2' do
        expect(subject.location[:x]).to eq(2)
        expect(subject.location[:y]).to eq(2)
      end

      it 'w is y-1' do
        subject.move('w')

        expect(subject.location[:y]).to eq(1)
        expect(subject.location[:last][:y]).to eq(2)
      end

      it 'a is x-1' do
        subject.move('a')

        expect(subject.location[:x]).to eq(1)
        expect(subject.location[:last][:x]).to eq(2)
      end

      it 's is y+1' do
        subject.move('s')

        expect(subject.location[:y]).to eq(3)
        expect(subject.location[:last][:y]).to eq(2)
      end

      it 'd is x+1' do
        subject.move('d')

        expect(subject.location[:x]).to eq(3)
        expect(subject.location[:last][:x]).to eq(2)
      end

      context 'boundaries' do
        context 'world boundaries' do
          context 'no adjacent world' do
            let(:map) { BanditMayhem::Map.new(height: 1, width: 1) }

            before(:each) { subject.warp(x: 1, y: 1) }

            it 'cant go left past boundary' do
              puts map.build!(subject)
              subject.move('a')

              expect(subject.location[:x]).to eq(subject.location[:last][:x])
            end

            it 'cant go right past boundary' do
              subject.move('d')

              expect(subject.location[:x]).to eq(subject.location[:last][:x])
            end

            it 'cant go up past boundary' do
              subject.move('w')

              expect(subject.location[:y]).to eq(subject.location[:last][:y])
            end

            it 'cant go down past boundary' do
              subject.move('s')

              expect(subject.location[:y]).to eq(subject.location[:last][:y])
            end
          end

          context 'adjacent world' do
            let(:map) { BanditMayhem::Map.new(name: 'map', file: File.absolute_path(File.join('spec', 'fixtures', 'map_with_borders.yml'))) }

            before(:each) { subject.warp(x: 1, y: 1) }

            it 'can go north' do
              subject.move('w') # hit the north border

              expect(subject.location[:map].to_s).to eq('north_map')
            end

            it 'can go south' do
              subject.move('s')

              expect(subject.location[:map].to_s).to eq('south_map')
            end

            it 'can go east' do
              subject.move('d')

              expect(subject.location[:map].to_s).to eq('east_map')
            end

            it 'can go west' do
              subject.move('a')

              expect(subject.location[:map].to_s).to eq('west_map')
            end
          end
        end

        context 'walls' do
          let(:map) { BanditMayhem::Map.new(file: File.absolute_path(File.join('spec', 'fixtures', 'map_jail.yml'))) }

          before(:each) do
            subject.warp(x: 2, y: 2)
            puts map.build!(subject)
          end

          it 'cant go through a vert wall using a/d' do
            subject.move('a')
            expect(subject.location[:x]).to eq(subject.location[:last][:x])
          end

          it 'cant go through a horiz wall using w/s' do
            subject.move('w')
            expect(subject.location[:y]).to eq(subject.location[:last][:y])
          end
        end
      end
    end
  end
end
