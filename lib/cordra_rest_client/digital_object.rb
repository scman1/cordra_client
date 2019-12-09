#lib/cordra_rest_cliet/digital_object.rb
require 'faraday'
require 'json'

API_URL = "http://nsidr.org:8080/"
API_HANDLE = "http://hdl.handle.net/"

module CordraRestClient
	class DigitalObject
		# digital object attributes 
		attr_reader :id, :type, :content, :metadata
			
		#initialize the digital object
		def initialize(digital_object)
			@id = digital_object["id"]
			@type = digital_object["type"]
			@content = digital_object["content"]
			@metadata = digital_object["metadata"]
		end
		
		# retrieves an object by ID
		# id: id of the object to retrieve 
		def self.find(id)
			response = Faraday.get("#{API_URL}objects/#{id}?full=true")
			digital_object = JSON.parse(response.body)
			DigitalObject.new(digital_object )
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
		def self.search(do_type, pageNum = 0, pageSize =5)
			s_uri="#{API_URL}objects/?query=type:\"#{do_type}\"&pageNum=#{pageNum}&pageSize=#{pageSize}"
			response = Faraday.get(s_uri)
			results = JSON.parse(response.body)	  
		end
		
		# retrieves an object via the Handle System web proxy
	        # id: full id (prefix and suffix) of the object to look-up 	
		def self.handle_find(id)
			response = Faraday.get("#{API_HANDLE}#{id}")
			#the body contains the re-direction
		       response.body
		end
		
		# modify object ACL
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
		
		# get object ACL
		# allows modifying the read/write persmissions of a specific object
		# id: id of the object to set persmissions on
		# rw_data: two arrays containing ids of users getting r/w persmissions
		def self.get_acl(id, rw_data, credentials)
			conn= Faraday.new(:url => API_URL)
			conn.basic_auth(credentials["username"], credentials["password"])
			response = conn.get do |req|
				req.url "/acls/#{id}"
				req.headers['Content-Type'] = 'text/json'
				#~ req.body = rw_data.to_json
			end
			out = JSON.parse(response.body)
			return out
		end
		
		# retrieve a schema
		# schema_type: the schema to retrieve, if empty returns all schemas
		def self.get_schema(schema_type="")
			conn= Faraday.get("#{API_URL}schemas/#{schema_type}")
		end

		# retrieve the results of calling an instance method of the object ID
		# id: id of the object to call one of its instance method
		# method_name: name of the instance method to run
		# data: data of the event to process (not all methods required it)
		# credentials: username and password for authentication (not all methods require it)
		def self.call_instance_method(id, method_name, data, credentials)
			conn = Faraday.new(:url => API_URL)

			unless credentials.nil?
				conn.basic_auth(credentials["username"], credentials["password"])
			end

			response = conn.post do |req|
				req.url "/call/?objectId=#{id}&method=#{method_name}"
				unless data.nil?
					req.headers['Content-Type'] = 'application/json'
					req.body = data.to_json
				end
			end
			out = JSON.parse(response.body)
			if out.nil?
				out = {}
			end
			out [:code] = response.status
			if response.status == 200
				out["message"] = "OK"
			end
			return out
		end
	end
	#create objects dinamically
	class DigitalObjectFactory
		def self.create_class(new_class, *fields)
			c = Class.new do
				fields.flatten.each do |field|
					#replace backslashes and space in names with underscores
					field = field.gsub('/','_')
					field = field.gsub(' ','_')
					define_method field.intern do
						instance_variable_get("@#{field}")
					end
					define_method "#{field}=".intern do |arg|
						instance_variable_set("@#{field}", arg)
					end
				end
			end
			CordraRestClient.const_set new_class, c
			return c
		end
		
		def self.assing_attributes(instance, values)
			values.each do |field, arg|
				#replace backslashes and space in names with underscores
				field = field.gsub('/','_')
				field = field.gsub(' ','_')				
				instance.instance_variable_set("@#{field}", arg)
			end
		end
	end
end

