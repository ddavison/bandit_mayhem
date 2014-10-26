module BanditMayhem
  class Helpers

    def self.shuffle_percent(percent)
      return true if rand(100) <= percent
      return false
    end

    def self.shuffle(num)

    end

    def self.calculate_attack_damage(char)
      # dmg = player str + player weapon str + level + (luck / 3)
      (char.get_av('str').to_i + char.weapon.get_property('str').to_i + char.get_av('level').to_i + (char.get_av('luck', 0).to_i / 3))
    end

    def self.calculate_defense(char)
      # def = player def + level + (luck / 5)
      (char.get_av('def').to_i + char.get_av('level').to_i + (char.get_av('luck', 0).to_i / 5))
    end
  end
end
