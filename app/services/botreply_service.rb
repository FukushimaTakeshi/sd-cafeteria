class Botreply_Service < Bot_Service
  def initialize(line_event, memory)
    super
  end

  def run
    p 'Reply START'
    return false unless @line_event['type'] == 'message' && @line_event['message']['type'] == 'text' || @line_event['type'] == 'postback'

    if @line_event['type'] == 'message'
      text = @line_event['message']['text']
    elsif @line_event['type'] == 'postback'
      text = @line_event['postback']['data']
    end
    p "Reply run LineData: #{text}"

    slot_filtering(@memory[:confirming], text)

    create_message()
  end
end
