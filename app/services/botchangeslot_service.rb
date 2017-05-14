class Botchangeslot_Service < Bot_Service
  def initialize(line_event, memory)
    super
  end

  def run
    p 'Change Slot START'
    return false unless @line_event['type'] == 'message' && @line_event['message']['type'] == 'text' || @line_event['type'] == 'postback'

    if @line_event['type'] == 'message'
      text = @line_event['message']['text']
    elsif @line_event['type'] == 'postback'
      text = @line_event['postback']['data']
    end

    for key in @memory[:verified][:confirmed] do
      break if ret = slot_filtering(key, text, true)
    end
    messages = [{type: 'text', text: 'わかりませんでした。もう一度お願いします。'}]
    return messages unless ret

    create_message()
  end
end
