desc "
Remove the services created by acceptance tests
Usage
rake remove_acceptance_tests_services
"
task :remove_acceptance_tests_services => :environment do |_t, args|
  services = Service.where(created_by: '1234')
  if services.empty?
    puts 'No services to destroy'
  else
    puts "About to destroy #{services.count} services"
    services.destroy_all
    puts "Done"
  end
end
