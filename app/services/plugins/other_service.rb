class Other_service

  def create_message(memory)
    messages = {
      type: 'text',
      text: memory[:intent][:fulfillment][:speech]
    }
    messages
  end
end
