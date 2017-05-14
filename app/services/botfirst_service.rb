class Botfirst_Service < Bot_Service
  def initialize(line_event, memory)
    super
  end

  def run
    p 'First START'
    return false unless @line_event['type'] == 'message' && @line_event['message']['type'] == 'text' || @line_event['type'] == 'postback'

    if !@memory.dig(:intent, :parameters).nil? && @memory.dig(:intent, :parameters).values[0].present?
      @memory.dig(:intent, :parameters).each_key do |key|
        slot_filtering(key, @memory.dig(:intent, :parameters, key))
      end
    end
    
   create_message()
  end
end
