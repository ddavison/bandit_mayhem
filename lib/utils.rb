module BanditMayhem
  module Utils
    extend self

    def shuffle_percent(percent)
      rand(100) <= percent
    end

    class Printer

      def info(msg)

      end

      def warn(msg)

      end

      def err(msg)
      end

      def line(line)
        print("\n#{line}")
      end

      private
      def print(line)
        puts line
      end
    end
  end
end
