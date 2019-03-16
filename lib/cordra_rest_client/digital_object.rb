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
	  puts("#{API_URL}/#{id}")
      response = Faraday.get("#{API_URL}/#{id}")
	  puts(response.body)
	  puts(JSON.parse(response.body))
      attributes = JSON.parse(response.body)
	  DigitalObject.new(attributes)
    end
	
    # create an object by type
	# update an object by ID
	# delete an object
	# search for objects
	# retrieves an object via the Handle System web proxy
	# modify the ACLs for a specific object
  end
end

