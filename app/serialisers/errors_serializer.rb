class ErrorsSerializer
  attr_reader :object

  def initialize(object)
    @object = object
  end

  def attributes
    {
      message: message
    }
  end

  def message
    if object.respond_to? :errors
      object.errors.full_messages
    else
      ["Requested #{resource_name} not found"]
    end
  end

  def resource_name
    if /Metadata/.match(object.message)
      'Version'
    else
      'Service'
    end
  end
end
