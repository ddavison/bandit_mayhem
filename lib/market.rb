require 'colorize'

module BanditMayhem
  class Market
    attr_reader :shopping

    def initialize(market, player)
      puts "\t\t\t\tWelcome to the market!"
      puts <<-END
                                             ;;;;;:;:
                                            `;;;;;;;;
                                            `''''''''
                                            `''''''''
                                            `''''''''
                                      `,:;;;'''''''''';;:,.`
                                  `,:;;;;;;'''''''''''';;;;;;:.
                                .:;;;;;;;;;'''''''''''';;;;;;;;;:.
                              .;;;;;;''''''''''''''''''''''';;;;;;:`
                            `:;;;;'''''''''''''''''''''''''''''';;;;:
                           .;;;'''''''''''''''''''''''''''''''''''';;;`
                          ,;;'''''''''''''''''''''''''''''''''''''''';;`
                         ,;''''''''''''''''''''''''''''''''''''''''''';;`
                        .;'''''''''''''''''''''''''''''''''''''''''''''';`
                       `;'''''''''''''''''''''''''''''''''''''''''''''''';
                       ;'''''''''''''''''''''''''''''''''''''''''''''''''':
                      .''''''''''''''''''''''''''''''''''''''''''''''''''''`
                      ''''''''''''''''''''''''''''''''''''''''''''''''''''';
                     ,''''''''''''''''''''''''''''''''''''''''''''''''''''''.
                     ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                    ;'''''''''''''''''''''''''''''''''''''''''''''''''''''''',
                    ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                   :'''''''''''''''''''''''';''''''''''''''''''''''''''''''''',
                   ''''''''''''''''''''''':` ''''''''.'''''''''''''''''''''''''
                  `''''''''''''''''''''''`  `''''''''  :'''''''''''''''''''''''`
                  :'''''''''''''''''''''`    ''''''''   :'''''''''''''''''''''':
                  '''''''''''''''''''''.     ''''''''    ;''''''''''''''''''''''
                  '''''''''''''''''''''`     ''''''''    `''''''''''''''''''''''
                  ''''''''''''''''''''''     ''''''''     ;''''''''''''''''''';:`
                 `''''''''''''''''''''+#     ''''''''     `''''''''''''';:,``
                 .'''''''''''''''''''''@'    ''''''''      ''''''';:,`
                 .'''''''''''''''''''''@#;`  ''''''''      ,;:,.
                 .'''''''''''''''''''''###+, ''''''''
                 .'''''''''''''''''''''+####+''''''''
                 `''''''''''''''''''''''#####''''''''
                  '''''''''''''''''''''''####'''''''':`
                  ''''''''''''''''''''''''+##''''''''+++;.
                  ''''''''''''''''''''''''''+''''''''###++';.
                  ;''''''''''''''''''''''''''''''''''####+++'':`
                  ,''''''''''''''''''''''''''''''''''+++++++++'';.
                   '''''''''''''''''''''''''''''''''''''+++++++''';,
                   ''''''''''''''''''''''''''''''''''''''''+++++'''';.
                   .''''''''''''''''''''''''''''''''''''''''''''''''';:
                    '''''''''''''''''''''''''''''''''''''''''''''''''';;.
                    .'''''''''''''''''''''''''''''''''''''''''''''''''';;.
                     ;'''''''''''''''''''''''''''''''''''''''''''''''''';;.
                      '''''''''''''''''''''''''''''''''''''''''''''''''''';`
                      `''''''''''''''''''''''''''''''''''''''''''''''''''';;
                       .''''''''''''''''''''''''''''''''''''''''''''''''''';:
                        .''''''''''''''''''''''''''''''''''''''''''''''''''';`
                         .''''''''''''''''''''''''''''''''''''''''''''''''''':
                          `'''''''''''''''''''''''''''''''''''''''''''''''''''
                            .''''''''''''''''''''''''''''''''''''''''''''''''',
                              ,''''''''''''''''''''''''''''''''''''''''''''''';
                                `;'''''''''''''''''''''''''''''''''''''''''''''`
                                   .;'''''''''''''''''''''''''''''''''''''''''':
                                      .;''''''''''''''''''''''''''''''''''''''''
                                         `:'''''''''''''''''''''''''''''''''''''`
                                            `''''''''''''''''''''''''''''''''''';
                                    ``       ''''''''''''''''''''''''''''''''''''
                            ``,:;;;'''       ''''''''''''''''''''''''''''''''''''`
                    `.,:;;;;;;''''''+#       '''''''' .''''''''''''''''''''''''''.
                 :;;;;;;;;;'''''''+++#`      ''''''''   .'''''''''''''''''''''''':
                 ;;;;;;;;''''''''''++#;      ''''''''     :'''''''''''''''''''''';
                .;;;;;'''''''''''''''##      ''''''''      ,''''''''''''''''''''''
                ;';;'''''''''''''''''##`     ''''''''       ''''''''''''''''''''''
                ;;;;;''''''''''''''''##+     ''''''''      `#'''''''''''''''''''''
               .;;;;;;'''''''''''''''+##,    ''''''''      +#'''''''''''''''''''''
               ;'''''''''''''''''''''+##+,   ''''''''     ;#@'''''''''''''''''''''
               :''''''''''''''''''''''###+;  ''''''''    '+##+''''''''''''''''''';
               `''''''''''''''''''''''####++.''''''''  :+####'''''''''''''''''''',
                ''''''''''''''''''''''+#####+'''''''''++#####''''''''''''''''''''`
                '''''''''''''''''''''''######''''''''#######+''''''''''''''''''''
                ,''''''''''''''''''''''+#####''''''''######+'''''''''''''''''''''
                 '''''''''''''''''''''''+####''''''''######+'''''''''''''''''''',
                 ''''''''''''''''''''''''+###''''''''#####+'''''''''''''''''''''
                 `''''''''''''''''''''''''+##''''''''###++''''''''''''''''''''';
                  ''''''''''''''''''''''''''+''''''''#++'''''''''''''''''''''''`
                  .''''''''''''''''''''''''''''''''''''''''''''''''''''''''''':
                   ;''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''.
                    `''''''''''''''''''''''''''''''''''''''''''''''''''''''':
                     ,''''''''''''''''''''''''''''''''''''''''''''''''''''''
                      :''''''''''''''''''''''''''''''''''''''''''''''''''''
                       :''''''''''''''''''''''''''''''''''''''''''''''''''
                        ,''''''''''''''''''''''''''''''''''''''''''''''''`
                         `''''''''''''''''''''''''''''''''''''''''''''':
                          `;''''''''''''''''''''''''''''''''''''''''''.
                            `''''''''''''''''''''''''''''''''''''''';
                              `;'''''''''''''''''''''''''''''''''';`
                                `,'''''''''''''''''''''''''''''',`
                                    `,;''''''''''''''''''''';.`
                                         ``.,'''''''',,.```
      END

      @market = market
      @player = player
      @shopping = true
    end

    def shop
      puts "Enter a choice : ('leave' to exit)"
      puts '------------Inventory-------------'
      print_inventory
      puts '----------------------------------'

      STDOUT.flush
      cmd = gets.chomp

      if cmd == 'leave'
        @shopping = false
        @player.location[:y] += 1 # force them out of the market.
      else
        if Integer(cmd)
          choice = Integer(cmd)
          choice -= 1
          if @market['inventory'][choice]
            buy(choice)
          end
        else
          puts 'Invalid item number.'.red
        end
      end
    end

    def print_inventory
      item_number = 1
      @market['inventory'].each do |item|
        itm = BanditMayhem::Item.by_name(item)
        puts item_number.to_s + '. ' + "[$#{itm.get_property('buy_value')}]".to_s.yellow + " #{itm.get_property('name')}".to_s.green + " (#{itm.get_property('description')})".to_s.blue
        item_number += 1
      end
    end

    def buy(item_index)
      itm = BanditMayhem::Item.by_name(@market['inventory'][item_index])

      buy_value = itm.get_property('buy_value')

      if @player.get_av('gold').to_i < buy_value
        puts 'You cant afford that!'.red
      else
        @player.give(itm)
        @player.set_av('gold',
          @player.get_av('gold').to_i - buy_value
        )
        @market['inventory'].delete(item_index)
      end
    end
  end
end