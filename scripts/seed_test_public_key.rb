require 'openssl'
require 'base64'

puts 'Generating test private key'
private_key = OpenSSL::PKey::RSA.generate(2048)
File.open('./spec/fixtures/private.pem', 'w') { |file| file.write(private_key.to_pem) }

puts 'Writing public key'
public_key = private_key.public_key.to_pem
File.open('./spec/fixtures/public.pem', 'w') { |file| file.write(public_key) }

puts 'Putting public key in Redis'
encoded_public_key = Base64.strict_encode64(public_key)
`docker exec metadata-app-service-token-cache-redis redis-cli set 'encoded-public-key-integration-tests' #{encoded_public_key}`
