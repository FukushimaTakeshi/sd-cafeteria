require 'open-uri'
require 'nokogiri'

namespace :menuparser do
  desc "メニュー取得"
  task :generate => :environment do
    page = Nokogiri::HTML(open('http://www.sd-cafeteria.com/lunch.html'), nil, "Shift_JIS")

    # カフェテリアのwebサイトから月曜日の日付を取得
    node_date = page.xpath("//*/tr/th[2]").text
    # 文字列をmm/dd で整形、DataTime型にパース、yyyymmdd に整形
    node_date = node_date.tr('／', '/').slice(/\d{1,2}\/\d{1,2}/)
    first_date = DateTime.parse(node_date)  # テーブルinsert用
    node_date = DateTime.parse(node_date)   # 既存データ検索用
    node_date = node_date.strftime('%Y%m%d')

    # menusテーブルに同じ日付のデータが登録済みであれば、おわり
    next p 'あるよ' if Menu.exists?(date: node_date)

    # メニュー取得
    array_name = Array.new(5).map{Array.new(9)}
    page.xpath("//*[@class='row1']").each_with_index do |noderow, index|
      noderow.xpath("./td[@class='col2']").each_with_index do |nodecol, index2|
        array_name[index2][index] = nodecol.text
      end
    end
    p array_name

    # カロリー取得
    array_kcal = Array.new(5).map{Array.new(11)}
    page.xpath("//*[@class='row2']").each_with_index do |noderow, index|
      noderow.xpath("./td[@class='col3']").each_with_index do |nodecol, index2|
        array_kcal[index2][index] = nodecol.text
      end
    end
    # nil削除
    array_kcal.map!{|e|e.compact!}
    p array_kcal

    # メニューとカロリーの配列を結合
    array = []
    array = array_name.zip(array_kcal)
    p array

    # Cランチの価格を取得　TODO: うどんのカロリーも取得されてしまう。。
    c_price = []
    page.xpath("//*[@class='row2']/td[@class='col2']").each {|node|
      c_price.push node.text
    }

    # menusテーブルにinsert  TODO:priceをscrape
    array.each_with_index do |(val_name, val_kcal), index|
      val_name.each_with_index do |val, i|
        day = first_date + index
        menu = Menu.new(date: day.strftime("%Y%m%d"), menutype_id: i + 1, name: val, kcal: val_kcal[i])
        case i + 1
        when 1, 2
          price = 670
        when 3
          price = c_price[index][1, 3].to_i
        when 4
          price = 540
        when 5
          price = 450
        when 6
          price = 550
        when 7
          price = 600
        when 8
          price = 460
        else
          price = 0
        end
        menu.price = price
        menu.save
      end
    end
  end
end
