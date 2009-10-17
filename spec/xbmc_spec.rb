require 'lib/xbmc'

describe XBMC do
  
  before do
    @xbox = XBMC.new('myxbox')
  end
  
  describe "when a song is playing" do
    
    describe "and the user needs detials about what's currently playing" do
      before do
        @xbox.should_receive(:open).at_least(:once).and_return(fixture('currently_playing'))
      end
    
      it "should detect that a song is playing" do
        @xbox.playing?.should be_true
      end
    
      it "should get currently playing song" do
        @xbox.currently_playing[:title].should == 'Ambivalence Avenue'
      end
  
      it "should know the path to the current song" do
        @xbox.currently_playing[:filename].should == "smb://luna/music/Bibio/Ambivalence Avenue/01 Ambivalence Avenue.mp3"
      end
      
    end
    
    describe "and the users asks about the playlist" do
      
      before do
        @xbox.should_receive(:open).at_least(:once).and_return(fixture('current_playlist'))
      end
      
      it "should return the playlist" do
        @xbox.playlist.size.should == 2
        @xbox.playlist.first.should == "smb://luna/music/Bibio/Ambivalence Avenue/01 Ambivalence Avenue.mp3"
      end
      
    end
    
  end
  
  describe "when nothing is playing" do
    
    it "should detect that nothing is playing" do
      @xbox.should_receive(:open).at_least(:once).and_return(fixture('nothing_playing'))
      @xbox.playing?.should  be_false
    end
    
    describe "and the users asks about the playlist" do

      it "should return an empty list" do
        @xbox.should_receive(:open).at_least(:once).and_return(fixture('empty_playlist'))
        @xbox.playlist.size.should == 0
      end
      
    end
        
  end
  
  describe "when queueing a song" do
    it "should send a request with the file path" do
      filepath = "smb://path/to/file.mp3"
      @xbox.should_receive(:open).with("http://myxbox:80/xbmcCmds/xbmcHttp?command=addToPlaylist" + CGI.escape("(#{filepath};0)"))
      @xbox.queue(filepath)
    end
  end 
    
end

def fixture(name)
  IO.readlines("spec/fixtures/#{name}.xml").to_s
end