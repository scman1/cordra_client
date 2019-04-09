#lib/cordra_rest_cliet/digital_object.rb
require 'faraday'
require 'json'

API_URL = "http://nsidr.org:8080/"
API_HANDLE = "http://hdl.handle.net/"

module CordraRestClient
  class DigitalObject
    # some of the attributes for digital specimen objects
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
    # id: id of the object to retrieve 
    def self.find(id)
        response = Faraday.get("#{API_URL}objects/#{id}")
        attributes = JSON.parse(response.body)
	DigitalObject.new(attributes)
    end
  
    # retrieves an objects attribute by object ID
    # id: id of the object to retrieve 
    # field: name of attribute to retrieve
    def self.get_do_field(id, field)
	response = Faraday.get("#{API_URL}objects/#{id}?jsonPointer=/#{field}")
	attributes = JSON.parse(response.body)
    end

    # create an object by type
        # id: suffix of the object to create 
	# do_type: type of digital object
	# do_data: data of the digital object
	# credentials: username and password for authentication
    def self.create(id, do_type, do_data, credentials)
        conn = Faraday.new(:url => API_URL)
	conn.basic_auth(credentials["username"], credentials["password"])
	  
        response = conn.post do |req|
		req.url "/objects/?type=#{do_type}&suffix=#{id}"
	        req.headers['Content-Type'] = 'text/json'
	        req.body = do_data.to_json
	end
	out = JSON.parse(response.body)
	out [:code] = response.status
        if response.status == 200
                out["message"] = "OK"	  
	end
	return out
    end
	
	# update an object by ID
	# id: full id (prefix and suffix) of the object to update 
	# do_data: data of the digital object
	# credentials: username and password for authentication
	def self.update(id, do_data, credentials)
	  conn = Faraday.new(:url => API_URL)

	  conn.basic_auth(credentials["username"], credentials["password"])
	  response = conn.put do |req|
	    req.url "/objects/#{id}"
	    req.headers['Content-Type'] = 'text/json'
	    req.body = do_data.to_json
	  end
	  out = JSON.parse(response.body)
	  out [:code] = response.status
      if response.status == 200
        out["message"] = "OK"	  
	  end
	  return out  
	end
	
	# delete an object
	# id: full id (prefix and suffix) of the object to delete 
	# credentials: username and password for authentication
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
	# do_data: data of the digital object
	# pageNum: page number to retrieve
	# pageSize: number of records per page to retrieve
	def self.search(do_type, pageNum = 1, pageSize =10)
      response = Faraday.get("#{API_URL}objects/?query=type:\"#{do_type}\"&pageNum=#{pageNum}&pageSize=#{pageSize}")
      results = JSON.parse(response.body)	  
	end
	
	# retrieves an object via the Handle System web proxy
    # id: full id (prefix and suffix) of the object to look-up 	
	def self.handle_find(id)
      response = Faraday.get("#{API_HANDLE}#{id}")
	  #the body contains the re-direction
      response.body
    end
	
	# modify the ACLs for an object
	# allows modifying the read/write persmissions of a specific object
	# id: id of the object to set persmissions on
	# rw_data: two arrays containing ids of users getting r/w persmissions
	def self.set_premissions(id,rw_data, credentials)
	  conn = Faraday.new(:url => API_URL)

	  conn.basic_auth(credentials["username"], credentials["password"])
	  response = conn.put do |req|
	    req.url "/acls/#{id}"
	    req.headers['Content-Type'] = 'text/json'
	    req.body = rw_data.to_json
	  end
	  out = JSON.parse(response.body)
	  out [:code] = response.status
      if response.status == 200
        out["message"] = "OK"	  
	  end
	  return out
	end
  end
end

