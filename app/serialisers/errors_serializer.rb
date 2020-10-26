class ErrorsSerializer
  attr_reader :object, :message

  def initialize(object, message:)
    @object = object
    @message = message
  end

  def attributes
    {
      message: [message].flatten
    }
  end
end
