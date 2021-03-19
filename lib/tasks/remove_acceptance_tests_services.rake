desc "
Remove the services created by acceptance tests
Usage
rake remove_acceptance_tests_services
"
task :remove_acceptance_tests_services => :environment do |_t, args|
  if ENV['PLATFORM_ENV'] == test
    # acceptance tests services are created by the same user during each run
    services = Service.where(created_by: 'a5833e7a-a210-4447-904c-df050d198e33')
    if services.empty?
      puts 'No services to destroy'
    else
      puts "About to destroy #{services.count} services"
      services.destroy_all
      puts "Done"
    end
  end
end
