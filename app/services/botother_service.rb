class Botother_Service < Bot_Service
  def initialize(line_event, memory)
    super
  end

  def run
    p 'Other START'
    return false unless @line_event['type'] == 'message' && @line_event['message']['type'] == 'text' || @line_event['type'] == 'postback'

    create_message()
  end
end
