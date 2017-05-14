require 'open-uri'
require 'nokogiri'

namespace :imageparser do
  desc "おすすめ画像URL取得"
  task :generate => :environment do
    page = Nokogiri::HTML(open('http://www.sd-cafeteria.com/event.html'))

    array = []
    array = page.xpath("//*[@id='main']").css('img').map { |img| "http://www.sd-cafeteria.com/" << img.attr('src') }

    array.each do |url|
      image = Image.find_or_create_by(imageurl: url)
      image.save
    end
  end
end
