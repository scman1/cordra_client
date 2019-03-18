#delete existing ds object
#!/usr/bin/env ruby

require "open-uri"
require "net/https"
require "json"

if __FILE__ == $0
  # Set your customer name, username, and password on the command line 
  v1 = ARGV[0]
  v2 = ARGV[1]
end
# need retries to make sure we get the right response from the server
url = URI.parse("http://nsidr.org:8080/objects/20.5000.1025/20.5000.1025/new_specimen")

req = Net::HTTP::Delete.new(url)
req.basic_auth(v1, v2)
res= Net::HTTP.start(url.hostname, url.port){|http| http.request(req)}

puts(res)
puts(res.code)