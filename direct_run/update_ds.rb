#update existing ds object
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
#url = URI.parse('http://131.251.172.30:8080/objects/20.5000.1025/B100003484')
url = URI.parse("http://nsidr.org:8080/objects/20.5000.1025/newspecimen02")
  ds={
	  "id":"",
      "identifier":"20.5000.1025/newspecimen02",
      "midslevel":2,
      "scientificName": "    Triturus helveticus (Razoumowsky, 1789)",
      "commonName": "palmated newt",
      "country": "France",
      "locality": "Jublains",
      "decimalLat/Long": [],
      "recordedBy": "",
      "collectionDate": "",
      "catalogNumber": "RMNH.RENA.44084",
      "otherCatalogNumbers": "",
      "collectionCode": "Amphibia and Reptilia",
      "institutionCode": "RMNH",
      "stableIdentifier": "http://data.biodiversitydata.nl/naturalis/specimen/RMNH.RENA.44084",
      "physicalSpecimenId": "RMNH.RENA.44084"
	}

header = {'Content-Type': 'text/json'}
req = Net::HTTP::Put.new(url, header)
req.basic_auth(v1, v2)
req.body = ds.to_json
puts(ds)
res= Net::HTTP.start(url.hostname, url.port){|http| http.request(req)}

puts(res)
puts(res.code)
jsonv = JSON.parse(res.body)