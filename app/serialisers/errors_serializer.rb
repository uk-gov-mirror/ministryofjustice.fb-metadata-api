class ErrorsSerializer
  attr_reader :object, :message

  def initialize(message:)
    @message = message
  end

  def attributes
    {
      message: [message].flatten
    }
  end
end
