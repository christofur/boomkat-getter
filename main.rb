require 'nokogiri'
require 'restclient'
require 'open-uri'

def get_starting_page url
  return Nokogiri::HTML(RestClient.get(url))
end

def get_products_from_page page
  spans = page.css('span').select{|span| span['data-product-id'] != nil}
  ids = []
  spans.each{|span| ids.push(span['data-product-id']) }
  return ids
end

def get_tracks id
  tracklist = Nokogiri::HTML(RestClient.get('https://boomkat.com/tracklist/' + id))
  links = tracklist.css('a').select{|a| a['data-audio-url'] != nil}
  links.each{|link| save_track(link) }
end

def save_track track

    url = track['data-audio-url']
    artist = track['data-artist']
    name = track['data-name']

    puts 'Saving ' + artist + ' : ' + name
    open(artist + ' - ' + name + '.mp3', 'wb') do |file|
      file << open(url).read
    end

end

page = get_starting_page('https://boomkat.com/t/genre/electronic')
ids = get_products_from_page(page)
ids.each{|id| get_tracks(id)}
