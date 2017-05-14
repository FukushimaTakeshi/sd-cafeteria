require 'line/bot'
require 'api-ai-ruby'
require 'redis'

class WebhookController < ApplicationController
  protect_from_forgery with: :null_session

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)
    p events

    @memory ||= JSON.parse(Redis.current.get(events[0]['source']['userId']), symbolize_names: true) rescue nil
    p @memory

    if @memory.blank?
      return unless events[0]['type'] == 'message' && events[0]['message']['type'] == 'text'

      apiAi = Bot_Service.parse_intent(events[0]['source']['userId'], events[0])
      @memory = {
        intent: apiAi[:result],
        confirmed: {},
        to_confirme: {},
        confirming: nil,
        verified: {
          confirmed: []
        }
      }
      # "First"
      botService = Botfirst_Service.new(events[0], @memory)
      messages = botService.run()
      res = client.reply_message(events[0]['replyToken'], messages)
    else  # "Reply"
      if @memory[:confirming].present?
        botService = Botreply_Service.new(events[0], @memory)
        messages = botService.run()
        res = client.reply_message(events[0]['replyToken'], messages)
      else
        apiAi = Bot_Service.parse_intent(events[0]['source']['userId'], events[0])
        if apiAi.dig(:result, :action) != 'input.unknown'
          @memory[:intent] = apiAi[:result]
          # "First"
          botService = Botfirst_Service.new(events[0], @memory)
          messages = botService.run()
          res = client.reply_message(events[0]['replyToken'], messages)
        else # "Change Slot"
          if @memory[:verified][:confirmed].present?
            botService = Botchangeslot_Service.new(events[0], @memory)
            messages = botService.run()
            res = client.reply_message(events[0]['replyToken'], messages)
          else # "Other"
            @memory = {
              intent: apiAi[:result],
              confirmed: {},
              to_confirme: {},
              confirming: nil,
              verified: {
                confirmed: []
              }
            }
            botService = Botother_Service.new(events[0], @memory)
            messages = botService.run()
            res = client.reply_message(events[0]['replyToken'], messages)
          end
        end
      end
    end
    # 'memory regist'
    Redis.current.setex(events[0]['source']['userId'], 30, @memory.to_json)
  end
end
