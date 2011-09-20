module MusicBrainz
  class ReleaseGroup
    attr_accessor :id, :type, :title, :disambiguation, :first_release_date
    @releases
  
    def releases
      if @releases.nil? and not self.id.nil?
        @releases = []
        Nokogiri::XML(MusicBrainz.load('http://musicbrainz.org/ws/2/release/?release-group=' + self.id + '&inc=media&limit=100')).css('release').each do |r|
          @releases << MusicBrainz::Release.parse_xml(r)
        end
      end
      @releases.sort{ |a, b| a.date <=> b.date }
    end
  
    def self.find mbid
      xml = Nokogiri::XML(MusicBrainz.load('http://musicbrainz.org/ws/2/release-group/' + mbid)).css('release-group').first
      self.parse_xml(xml) unless xml.nil?
    end
  
    def self.parse_xml xml
      @release_group = MusicBrainz::ReleaseGroup.new
      @release_group.id = xml.attr('id')
      @release_group.type = xml.attr('type')
      @release_group.title = xml.css('title').text
      @release_group.disambiguation = xml.css('disambiguation').empty? ? '' : xml.css('disambiguation').text
      date = xml.css('first-release-date').empty? ? '2030-12-31' : xml.css('first-release-date').text
      if date.length == 0
        date = '2030-12-31'
      elsif date.length == 4
        date += '-12-31'
      elsif date.length == 7
        date += '-31'
      end
      date = date.split('-')
      @release_group.first_release_date = Time.utc(date[0], date[1], date[2])
      @release_group
    end
  end
end
