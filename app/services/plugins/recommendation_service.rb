require 'httparty'

class Recommendation_service
  def create_message(memory)
    messages = [{
      type: 'text',
      text: ''
    },
    {
      type: "image",
      originalContentUrl: '',
      previewImageUrl: ''
    }]

    # 当月のみ取得　TODO:当月の終了分も含まれてしまう。。
    url_array = []
    url_array = Image.created_after(Time.current.strftime('%Y%m')).map { |img| img.imageurl }
    default_url = 'http://www.sd-cafeteria.com/images/ladyslunch.jpg'
    url_array.push default_url if url_array.present?

    # 画像URLを'http'から'https'に変換するため、URL Shortener にPOST
    res = HTTParty.post("https://www.googleapis.com/urlshortener/v1/url?key=#{ENV["GOOGLE_API_KEY"]}",
      :body => { :longUrl => url_array.sample.presence || default_url }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    url = JSON.parse(res.body)

    recommendmessage = ['おすすめはこれだ！！！', 'ほーらよっ！', 'これがおすすめだよー', 'あなたにはこれをオススメします！']
    messages[0][:text] = recommendmessage.sample
    messages[1][:originalContentUrl] = url['id']
    messages[1][:previewImageUrl] = url['id']
    messages
  end
end
