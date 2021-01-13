require 'openssl'
require 'base64'

private_key_file = './spec/fixtures/private.pem'
public_key_file = './spec/fixtures/public.pem'

def add_public_key_to_redis(public_key_file)
  public_key = File.read(public_key_file)
  encoded_public_key = Base64.strict_encode64(public_key)

  puts "Adding the key 'encoded-public-key-fb-integration-tests' in Redis."
  `docker-compose exec metadata-app-service-token-cache-redis redis-cli set 'encoded-public-key-integration-tests' #{encoded_public_key}`

  puts "======= encoded-public-key-integration-tests ======"
  puts `docker-compose exec metadata-app-service-token-cache-redis redis-cli get 'encoded-public-key-integration-tests'`
  puts

  puts "Adding the key 'encoded-public-key-editor' in Redis."
  `docker-compose exec metadata-app-service-token-cache-redis redis-cli set 'encoded-public-key-editor' #{encoded_public_key}`

  puts "======= Value in Redis of the key encoded-public-key-editor ========"
  puts `docker-compose exec metadata-app-service-token-cache-redis redis-cli get 'encoded-public-key-editor'`
  puts
end


if File.exist?(private_key_file) && File.exist?(public_key_file)
  add_public_key_to_redis(public_key_file)
  exit(0)
else
  puts 'Generating test private key'
  private_key = OpenSSL::PKey::RSA.generate(2048)
  File.open(private_key_file, 'w') { |file| file.write(private_key.to_pem) }

  puts 'Writing public key'
  public_key = private_key.public_key.to_pem
  File.open(public_key_file, 'w') { |file| file.write(public_key) }
  add_public_key_to_redis(public_key_file)
end
