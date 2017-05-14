class Showcal_service
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
      },
      menu_type: {
        line_reply_message: {
          type: 'template',
          altText: 'どのセットメニューですか？',
          template: {
            type: 'buttons',
            text: 'どのセットメニューですか？',
            actions: [
              {type: 'postback', label: 'Aランチ', data: 'Aランチ'},
              {type: 'postback', label: 'Bランチ', data: 'Bランチ'},
              {type: 'postback', label: 'Cランチ', data: 'Cランチ'},
              {type: 'postback', label: '八分ランチ', data: '八分ランチ'}
            ]
          }
        }
      }
    }

    # @option = {
    #   menutype: {
    #     alunch: 'Aランチ',
    #     blunch: 'Bランチ',
    #     clunch: 'Cランチ',
    #     hatilunch: '八分ランチ',
    #     curry: 'カレー',
    #     pickycurry: 'こだわりのカレー',
    #     halfandhalfcurry: 'ハーフ&ハーフカレー',
    #     ramen: 'ラーメン'
    #   }
    # }
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

  def parser_menu_type(value)
    if value.include?("A") then
      parse_val = 1
    elsif value.include?("B") then
      parse_val = 2
    elsif value.include?("C") then
      parse_val = 3
    elsif value.include?("八分") || value.include?("8分")
      parse_val = 4
    else
      parse_val = false
      # raise '指定のメニューは見つかりません。'
    end
  end

  def create_message(memory)
    messages = [{type: 'text', text: ''}]
    val = Menu.find_by(date: memory[:confirmed][:date], menutype: memory[:confirmed][:menu_type])

    if val.blank?
      messages[0][:text] = DateTime.parse(memory[:confirmed][:date]).strftime('%-m/%-d(%a)') << 'は休みでして… ^ ^;'
    else
      messages[0][:text] = "#{val.menutype.menutypename}\n「#{val.name}」のカロリーは、#{val.kcal.to_s} です。"
    end
    messages
  end
end
