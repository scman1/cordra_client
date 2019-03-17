#lib/cordra_rest_cliet/digital_object.rb
require 'faraday'
require 'json'

API_URL = "http://nsidr.org:8080/objects"

module CordraRestClient
  class DigitalObject
    #attributes
    attr_reader :id, :timestamp, :creator, :scientificName, :country, :locality,
    	:decimalLatLong, :recordedBy, :collectionDate, :catalogNumber, 
		:otherCatalogNumbers, :collectionCode, :institutionCode, :stableIdentifier, 
		:physicalSpecimenId, :determinations
		
	#initialize the digital specimen
    def initialize(attributes)
      @id = attributes["id"]
      @timestamp = attributes["timestamp"]
      @creator = attributes["creator"]
      @scientificName = attributes["scientificName"]
      @country = attributes["country"]
      @locality = attributes["locality"]
      @decimalLatLong = attributes["decimalLat/Long"]
	  @recordedBy = attributes["recordedBy"]
	  @collectionDate = attributes["collectionDate"]
	  @catalogNumber = attributes["catalogNumber"]
	  @otherCatalogNumbers = attributes["otherCatalogNumbers"]
	  @collectionCode = attributes["collectionCode"]
	  @institutionCode = attributes["institutionCode"]
	  @stableIdentifier = attributes["stableIdentifier"]
	  @physicalSpecimenId = attributes["physicalSpecimenId"]
	  @determinations = attributes["Determinations"]
    end
	
	# retrieves an object by ID
    def self.find(id)
      response = Faraday.get("#{API_URL}/#{id}")
      attributes = JSON.parse(response.body)
	  DigitalObject.new(attributes)
    end
	
    # create an object by type
	def self.create(id, dso_type, dso_data, credentials)
	  conn = Faraday.new(:url => API_URL)
	  conn.basic_auth(credentials["username"], credentials["password"])
	  
      response = conn.post do |req|
	    req.url "/objects/?type=#{dso_type}&suffix=#{id}"
	    req.headers['Content-Type'] = 'text/json'
	    req.body = dso_data.to_json
	  end
	  out = JSON.parse(response.body)
	  out [:code] = response.status
      if response.status == 200
        out["message"] = "OK"	  
	  end
	  return out
	end
	
	# update an object by ID
	# ID must include prefix
	def self.update(id, dso_data, credentials)
	  conn = Faraday.new(:url => API_URL)

	  conn.basic_auth(credentials["username"], credentials["password"])
	  response = conn.put do |req|
	    req.url "/objects/#{id}"
	    req.headers['Content-Type'] = 'text/json'
	    req.body = dso_data.to_json
	  end
	  out = JSON.parse(response.body)
	  out [:code] = response.status
      if response.status == 200
        out["message"] = "OK"	  
	  end
	  return out  
	end
	
	# delete an object
	def self.delete(id, credentials)
	  conn = Faraday.new(:url => API_URL)

	  conn.basic_auth(credentials["username"], credentials["password"])
	  response = conn.delete do |req|
	    req.url "/objects/#{id}"
	  end
	  out = JSON.parse(response.body)
	  out [:code] = response.status
      if response.status == 200
        out["message"] = "OK"	  
	  end
	  return out  
	end
	# search for objects
	def self.search(dso_type, pageNum = 1, pageSize =10)
      response = Faraday.get("#{API_URL}/?query=type:\"#{dso_type}\"&pageNum=#{pageNum}&pageSize=#{pageSize}")
      results = JSON.parse(response.body)	  
	end
	# retrieves an object via the Handle System web proxy
	# modify the ACLs for a specific object
  end
end

