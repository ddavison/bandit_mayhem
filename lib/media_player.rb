require 'media/audite'

module BanditMayhem
  class MediaPlayer
    def initialize
      @mplayer = Audite.new
      play_song(File.expand_path("./lib/media/soundtrack.mp3"))
    end

    def stop
      @mplayer.stop_stream
    end

    def play_song(audio_file)
      @mplayer.load(audio_file)
      @mplayer.start_stream

      @mplayer.events.on(:complete) do
        play_song(audio_file) # loop song
      end
    end

    def play_level_song(map_name)
      begin
        play_song("./lib/media/maps/#{map_name}.mp3")
      rescue
        play_song("./lib/media/soundtrack.mp3")
      end
    end

    def playing_level?(map_name)
      if playing?
        # TODO: Fix me
        # puts @mplayer.current_song_name
        # puts File.expand_path("./lib/media/maps/#{map_name}.mp3")
        # return @mplayer.current_song_name == File.expand_path("./lib/media/maps/#{map_name}.mp3")
      end
      false
    end

    def playing?
      @mplayer.active
    end
  end
end
