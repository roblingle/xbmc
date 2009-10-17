require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'cgi'

def returning(value)
  yield(value)
  value
end

class XBMC
  # Creates a new instance using the hostname or IP address, port, and  
  def initialize(host,port = 80, playlist = 0)
    @host     = host
    @port     = port
    @paused   = false
    @playlist = playlist
    
    set_playlist
  end
  
  # returns a hash with details on the currently_playing track
  # xbox.currently_playing[:Title] #=> "La Vida Loca"
  def currently_playing
    returning(Hash.new) do |result|
      send_command('getCurrentlyPlaying').search("//li").each do |item|
        key,*value = item.inner_html.split(':')
        result[key.downcase.to_sym] = value.join(':').chomp
      end
    end
  end
  
  # Whether or not a track is in progress
  def playing?
    currently_playing[:filename] == "[Nothing Playing]" ? false : (true && !paused?)
  end
  
  # Whether or not xbmc is paused
  def paused?
    @paused
  end
  
  # An array of the currently loaded tracks
  def playlist
    send_command('getPlaylistContents',0).search("//li").map{|i| i.inner_html.chomp}.reject{|i| i == "[Empty]"}
  end
  
  # Add a file to the queue. Specify the path to the file as xbmc would access it.
  def queue(song)
    send_command('addToPlaylist',song,0)
  end
  
  # Play the next track
  def play_next
    send_command('PlayNext')
  end
  
  # Pause or unpause the player.
  # This is a simple toggle, it doesn't check current state.
  def pause
    send_command('Pause')
    @paused = !@paused
  end
  alias :unpause :pause
  
  def clear_playlist
    send_command('ClearPlaylist',0)
  end
  
  # 0 = Music
  # 1 = Video
  def set_playlist(type=@playlist)
    send_command('SetCurrentPlaylist',type)
  end
    
  private
  
  def send_command(command,*args)
    args = '(' + args.join(';') + ')'
    Nokogiri::HTML(open(url_for(command + args)))
  end

  def url_for(command)
    "http://#{@host}:#{@port}/xbmcCmds/xbmcHttp?command=" + CGI.escape(command)
  end

end