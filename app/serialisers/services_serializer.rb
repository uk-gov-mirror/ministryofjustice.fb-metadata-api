class ServicesSerializer
  attr_reader :services

  def initialize(services)
    @services = services
  end

  def attributes
    all_services = services.map do |service|
      {
        service_id: service.id,
        service_name: service.name
      }
    end

    { services: all_services }
  end
end
