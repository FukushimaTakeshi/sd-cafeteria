class Bot_Service
  attr_accessor :line_event, :memory

  def initialize(line_event, memory)
    @line_event = line_event
    @memory = memory

    @bot_plugin = get_bot_plugin(@memory.dig(:intent, :action))
    if @memory[:to_confirme].values[0].blank?
      @memory[:to_confirme] = confirm_slot(@memory[:confirmed])
    end
  end

  def get_bot_plugin(action)
    p "get_bot_plugin action : #{action}"
    return false unless action

    action = 'other_service' if action == 'input.unknown'
    require action
    classname = "#{action}"
    Object.const_get(classname.capitalize!).new
  end

  def confirm_slot(confirmed)
    to_confirme = {}
    return to_confirme unless @bot_plugin.instance_variable_defined?(:@required_slot)

    @bot_plugin.required_slot.each_key do |param_key|
      if confirmed.blank? || !confirmed.has_key?(param_key)
        to_confirme[param_key] = @bot_plugin.required_slot[param_key]
      end
    end
    to_confirme
  end

    def self.parse_intent(userid,event)
    return false unless event['type'] == 'message' && event['message']['type'] == 'text' || event['type'] == 'postback'

    if event['type'] == 'message'
      text = event['message']['text']
    elsif event['type'] == 'postback'
      text = event['postback']['data']
    end

    aiInstance = ApiAiRuby::Client.new(
        client_access_token: ENV["APIAI_CLIENT_ACCESS_TOKEN"],
        api_lang: 'ja'
        # api_session_id: userid
    )
    airet = aiInstance.text_request(text)
    # p airet
  end

  def slot_filtering(key, value, change_intent = false)
    p "key:#{key} value:#{value}"
    if @bot_plugin.required_slot.has_key?(key.to_sym)
      if @bot_plugin.respond_to?("parser_#{key}")
        p 'メソッドあり'
        parsed_value = @bot_plugin.send("parser_#{key}", value)
      else
        p 'メソッドなし'
        parsed_value = value
      end
      return false unless parsed_value

      p 'slot filtering'
      param = {}
      param[key.to_sym] = parsed_value
      @memory[:confirmed].merge!(param)
      @memory[:verified][:confirmed] << key unless change_intent
      @memory[:to_confirme].delete(key.to_sym)
      @memory[:confirming] = nil if @memory[:confirming] == key

      true
    end
  end

  def collect_slot
    message = @memory.dig(:to_confirme, @memory[:to_confirme].keys[0], :line_reply_message)
    @memory[:confirming] = @memory[:to_confirme].keys[0]
    message
  end

  def create_message
    return collect_slot() if @memory[:to_confirme].values[0].present?
    @bot_plugin.create_message(@memory)
  end
end
