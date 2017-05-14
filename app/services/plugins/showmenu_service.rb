require_relative '../../models/menu'

class Showmenu_service
  attr_reader :required_slot
  def initialize
    @required_slot = {
      date: {
        line_reply_message: {
          type: 'template',
          altText: 'いつのメニューですか？',
          template: {
            type: 'buttons',
            text: 'いつのメニューですか？',
            actions: [
              {type: 'postback', label: '今日', data: '今日'},
              {type: 'postback', label: '明日', data: '明日'},
              {type: 'postback', label: '昨日', data: '昨日'}
            ]
          }
        }
      }
    }
  end

  def parser_date(value)
    if value.include?("今日") then
      parse_val = Date.today.strftime("%Y%m%d")
    elsif value.include?("昨日") then
      parse_val = Date.yesterday.strftime("%Y%m%d")
    elsif value.include?("明日") then
      parse_val = Date.tomorrow.strftime("%Y%m%d")
    else
      parse_val = false
      # raise '該当なし'
    end
  end

  def create_message(memory)
    messages = {type: 'text', text: ''}
    Menu.where(date: memory[:confirmed][:date], menutype: '1'..'4').find_each do |val|
      messages[:text] << "#{val.menutype.menutypename}(￥#{val.price})が\n「#{val.name}」、\n"
    end

    if messages[:text].blank?
      messages[:text] = "ごめんなさい。\n" << DateTime.parse(memory[:confirmed][:date]).strftime('%-m/%-d(%a)') << "は休みだよー！\nえっ、もしかして仕事？？"
    else
      messages[:text].insert(0, DateTime.parse(memory[:confirmed][:date]).strftime('%-m/%-d(%a)') << " のメニューは\n")
      messages[:text].chomp!.chop! << 'です。'
    end
    messages
  end
end
