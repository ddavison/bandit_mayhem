require 'character'

module BanditMayhem
  module Characters
    module Npcs
      class Chezara < Character
        def initialize(add_stats={})
          stats = {
              name: 'Chezara',
              avatar: <<~AVATAR
            _
          //`\\
         (/a a\)
         (\_-_/) 
        .-~'='~-.
       /`~`"Y"`~`\
      / /(_ * _)\ \
     / /  )   (  \ \
     \ \_/\\_//\_/ / 
      \/_) '*' (_\/
        |       |
        |       |
        |       |
        |       |
        |       |
        |       |
        |       |
        |       |
        w*W*W*W*w
              AVATAR
          }.merge(add_stats)
          super(stats)
        end
      end
    end
  end
end
