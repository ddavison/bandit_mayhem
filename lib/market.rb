require 'colorize'
require './lib/commands'
require './lib/item'
require './lib/weapon'

module BanditMayhem
  class Market
    class Commands < BanditMayhem::Commands
      def initialize(rec)
        @rec = rec
        @descriptions = {
          '/exit' => 'Leave the shop',
          '/buy [item_number]' => 'Buy an item',
          '/sell [ItemName]' => 'Sell an item from your inventory'
        }
        @player = rec.player
        @market = rec.market
      end

      def exit(args)
        @rec.shopping = false
        @player.location[:map].exit_location(@player)
      end

      def buy(args)
        if Integer(args.first)
          item_index = args.first.to_i - 1
          begin
            itm = BanditMayhem::Item.by_name(@market['inventory'][item_index])
          rescue
            itm = BanditMayhem::Weapon.by_name(@market['inventory'][item_index])
          end

          buy_value = itm.get_property('buy_value')

          if @player.get_av('gold').to_i < buy_value
            puts 'You cant afford that!'.red
          else
            @player.give(itm)
            @player.set_av('gold',
              @player.get_av('gold').to_i - buy_value
            )
          end
        else
          puts "you can't buy #{args}. try again using the item code: /buy 1".red
        end
      end

      def sell(args)
        puts 'not implemented'.red
      end
    end

    attr_accessor :shopping,
                  :player,
                  :market

    def initialize(market, player)
      puts <<-END
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      END

      @market = market
      @player = player
      @shopping = true
      @command_proc = Commands.new(self)
    end

    def shop
      puts
      puts 'You have ' + '$'.yellow + @player.get_av('gold').to_s.yellow + ' - Buy an item using ' + '/buy'.magenta + '. Sell an item using ' + '/sell'.magenta + '. Leave using ' + '/exit'.magenta
      puts '------------Inventory-------------'
      print_inventory
      puts '----------------------------------'

      STDOUT.flush
      cmd = gets.chomp

      @command_proc.execute(cmd)
    end

    def print_inventory
      Dir['./lib/items/*'].each { |file| require file }
      Dir['./lib/weapons/*'].each { |file| require file }

      item_number = 1
      @market['inventory'].each do |item|
        begin
          itm = BanditMayhem::Item.by_name(item)
        rescue
          p item
          itm = BanditMayhem::Weapon.by_name(item)
        end
        puts item_number.to_s + '. ' + "[$#{itm.get_property('buy_value')}]".to_s.yellow + " #{itm.get_property('name')}".to_s.green + " (#{itm.get_property('description')})".to_s.blue
        item_number += 1
      end
    end
  end
end
