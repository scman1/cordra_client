#test/digital_object/digital_object_test.rb
require './test/test_helper'

class CordraRestClientDigitalObjectTest < Minitest::Test

	# 0 basic test
	def test_exists
		assert CordraRestClient::DigitalObject
	end

	# 1 test retrieve object by ID
	def test_retrieve_object_by_id
		VCR.use_cassette('retrieve_object_id') do
			cdo = CordraRestClient::DigitalObject.find("20.5000.1025/B100003484")
			assert_equal CordraRestClient::DigitalObject, cdo.class

			# Check that fields are accessible
			assert_equal "20.5000.1025/B100003484", cdo.id
			assert_equal "Digital Specimen", cdo.type
		end
	  end
	# 2 test retrieve object creator, variant of  retrieve object by ID
	def test_retrieve_object_creator
		VCR.use_cassette('retrieve_object_attribute') do
			do_creator = CordraRestClient::DigitalObject.get_do_field("20.5000.1025/B100003484","creator")
			# Check object creator
		 	assert_equal "20.5000.1025/60c6d277a8bd81de7fdd", do_creator
		end
	 end
	# pending testing of get payload, other attributes
	# 2.1 test retrieve object annotations, variant of  retrieve object by ID
	def test_retrieve_object_annotations
		VCR.use_cassette('retrieve_object_annotations') do
			do_annotations = CordraRestClient::DigitalObject.get_do_field("20.5000.1025/B100003484","Annotations")
			# Check object creator
		 	assert_equal "preservation=\"dry specimen\" sampletype=\"leaves and stem nodes\" storage =\"mounted\" collectiongroup=\"herbarium sheet\"", do_annotations
			puts do_annotations
		end
	 end

	# 2.2 test retrieve object images, variant of  retrieve object by ID
	def test_retrieve_object_images
		VCR.use_cassette('retrieve_object_images') do
			do_images = CordraRestClient::DigitalObject.get_do_field("20.5000.1025/B100003484","availableImages")
			# Check object creator
		 	assert_equal "BGBM", do_images[0][0]
		end
	 end

	  # 3 test create an object by type
	  def test_create_object_by_type
	    VCR.use_cassette('create_object') do
		  cred=JSON.parse(YAML::load_file('test/fixtures/credential.yml').to_json)
	          json = JSON.parse(File.read("test/fixtures/new_specimen.json"))
		  result=CordraRestClient::DigitalObject.create(json["identifier"],"Digital Specimen",json, cred["uc_1"])

		  #check that the result is saved
		  assert_equal 200, result[:code]
		  assert_equal "OK", result["message"]
		end
	  end

	  # 4 test create an object by type, FAIL
	  def test_create_object_by_type_fail
	    VCR.use_cassette('create_object_fail') do
		  cred=JSON.parse(YAML::load_file('test/fixtures/credential.yml').to_json)

	      json = JSON.parse(File.read("test/fixtures/new_specimen.json"))

		  result=CordraRestClient::DigitalObject.create("1a0beb212baaede1c10c","Digital Specimen",json, cred["uc_1"])
		  #check that the duplicate is rejected
		  assert_equal 409, result[:code]
		  assert_equal "Object already exists: 20.5000.1025/1a0beb212baaede1c10c", result["message"]
		end
	  end

	  # 5 test update an object by ID
	  def test_update_object_by_id
	    VCR.use_cassette('edit_object') do
		  cred=JSON.parse(YAML::load_file('test/fixtures/credential.yml').to_json)
		  json = JSON.parse(File.read("test/fixtures/edit_specimen.json"))
		  id = json["id"]
		  json["id"] = "" #id cannot be updated
		  result=CordraRestClient::DigitalObject.update(id, json, cred["uc_1"])

		  #check that the result is saved
		  assert_equal 200, result[:code]
		  assert_equal "OK", result["message"]
		end
	  end

	  # 6 test delete an object by ID
	  def test_delete_object_by_id
	    VCR.use_cassette('delete_object') do
		  cred=JSON.parse(YAML::load_file('test/fixtures/credential.yml').to_json)
		  id = "20.5000.1025/newspecimen03"
		  result=CordraRestClient::DigitalObject.delete(id, cred["uc_1"])

		  #check that the result is saved
		  assert_equal 200, result[:code]
		  assert_equal "OK", result["message"]
		end
	  end

	  # 7 test search for objects
	  def test_search_for_objects
	    VCR.use_cassette('search_objects') do
	      list_cdo = CordraRestClient::DigitalObject.search("Digital Specimen")
	      assert_equal Hash, list_cdo.class

	      # Check that fields are accessible
	      assert_equal 0, list_cdo["pageNum"]
	      assert_equal 5, list_cdo["pageSize"]
	      assert_equal 7, list_cdo["size"]
	      assert_equal Array, list_cdo["results"].class
	      puts  list_cdo["results"]
	    end
	  end
	  # 8 test retrieves an object via the Handle System web proxy
	  def test_retrieve_object_via_handle
	    VCR.use_cassette('get_object_handle') do
	      redirection = CordraRestClient::DigitalObject.handle_find("20.5000.1025/B100003484")
	      assert_equal String, redirection.class

	      # Check that fields are accessible
		  assert_match /Handle Redirect/, redirection
		  assert_match /B100003484/, redirection
	    end
	end

	# 9 test modify object ACL

	def test_object_acl_set
		VCR.use_cassette('object_acl_set') do
			cred=JSON.parse(YAML::load_file('test/fixtures/credential.yml').to_json)
			json = JSON.parse(File.read("test/fixtures/acl_list.json"))
			id = "20.5000.1025/RMNH.RENA.44084"
			result=CordraRestClient::DigitalObject.set_premissions(id, json, cred["uc_1"])
			#check that the result is saved
			assert_equal 200, result[:code]
			assert_equal "OK", result["message"]
			assert_equal 4, result.length
			assert_equal 1, result["readers"].length
			assert_equal '20.5000.1025/1517d545cc11283e2360', result["readers"][0]
		end
	end
        # 10 test get object ACL
	def test_object_acl_get
		VCR.use_cassette('object_acl_get') do
			cred=JSON.parse(YAML::load_file('test/fixtures/credential.yml').to_json)
			json = JSON.parse(File.read("test/fixtures/acl_list.json"))
			id = "20.5000.1025/RMNH.RENA.38646"
			result=CordraRestClient::DigitalObject.get_acl(id, json, cred["uc_1"])

			#check result returned
			assert_equal 2, result.length
			assert_equal 2, result["readers"].length
			assert_equal '20.5000.1025/1517d545cc11283e2360', result["readers"][0]
			assert_equal '20.5000.1025/1517d545cc11283e2360', result["writers"][0]
		end
	end

	# 11. test get object schema
	def test_modify_object_permissions
		VCR.use_cassette('get_schema') do
			schema_type="Digital%20Specimen"
			result=CordraRestClient::DigitalObject.get_schema(schema_type)
			do_schema = JSON.parse(result.body)
			# check that the right schema was delivered
			assert_equal "object", do_schema["type"]
			assert_equal "Digital Specimen", do_schema["title"]
		end
	end
        #12. prepare dynamic creation of DO
	def test_dynamic_build_prepare
		VCR.use_cassette('dynamic_do_prepare') do
			# A. get object type
			cdo = CordraRestClient::DigitalObject.find("20.5000.1025/B100003484")
			# Check object type and fields are accessible
			assert_equal "20.5000.1025/B100003484", cdo.id
		 	assert_equal "Digital Specimen", cdo.type
			# B. get schema
			#     The schema will be used to build a DO class dinamically
			result=CordraRestClient::DigitalObject.get_schema(cdo.type.gsub(" ","%20"))
			do_schema = JSON.parse(result.body)
			# check that the result is saved
			assert_equal "object", do_schema["type"]
			assert_equal "Digital Specimen", do_schema["title"]
			# build new class using schema
			# the DO contents are a hash
			assert_equal Hash,  cdo.content.class
			# assing object values in content to class
		end
	end
	#13. dynamic creation of DO
	# this code uses the Cordra Rest Client methods that return a new digital object and assing the retrived values to it
        def test_dynamic_do_build
		VCR.use_cassette('dynamic_do_build') do
			# A. get digital object
			cdo = CordraRestClient::DigitalObject.find("20.5000.1025/B100003484")
			# Check object id and type
			assert_equal "20.5000.1025/B100003484", cdo.id
		 	assert_equal "Digital Specimen", cdo.type
			# B. get schema
			#     The schema will be used to build a DO class dinamically
			result=CordraRestClient::DigitalObject.get_schema(cdo.type.gsub(" ","%20"))
			do_schema = JSON.parse(result.body)
			# check that the result is saved
			assert_equal "object", do_schema["type"]
			assert_equal "Digital Specimen", do_schema["title"]
			# C. build new class using schema
			do_properties = do_schema["properties"].keys
			do_c = CordraRestClient::DigitalObjectFactory.create_class cdo.type.gsub(" ",""), do_properties
			new_ds = do_c.new
			# the DO contents are a hash
			assert_equal Hash,  cdo.content.class
			# assing object values in content to class
			CordraRestClient::DigitalObjectFactory.assing_attributes new_ds, cdo.content
			cdo.content.each do |field, arg|
				instance_var = field.gsub('/','_')
				instance_var = instance_var.gsub(' ','_')
				assert_equal arg, new_ds.instance_variable_get("@#{instance_var}")
			end
		end
	end
	#14
	def test_retrieve_objects_via_handle
	    VCR.use_cassette('get_objects_handle') do
	      list_cdo = CordraRestClient::DigitalObject.search("Digital Specimen",0,20)
	      puts list_cdo["results"].length
	      list_cdo["results"].each do |res|
	        puts res["id"]
		test_this_id= res["id"]
		redirection = CordraRestClient::DigitalObject.handle_find(test_this_id)
	        assert_equal String, redirection.class
		if redirection.match(/Handle Redirect/)
		  assert true
		else
		   false
		   puts "fail"
		end
	      end
	      #redirection = CordraRestClient::DigitalObject.handle_find("20.5000.1025/BMNHE1613533")
	      #assert_equal String, redirection.class

	      # Check that fields are accessible
		  #assert_match /Handle Redirect/, redirection
		  #assert_match /BMNHE1613533/, redirection
	    end
	end

	# 15 test call instance method to retrieve provenance records (it doesn't required authentication nor data)
	def test_call_instance_method_get_provenance_records
		VCR.use_cassette('get_provenance_records') do
			cdo = CordraRestClient::DigitalObject.call_instance_method("20.5000.1025/82752031921751eb6ab9","getProvenanceRecords",nil,nil)

			# Check that its has at least one provenance record and the first one was for a create event

			assert_equal "20.5000.1025/82752031921751eb6ab9", cdo["content"]["id"]
			assert_equal true, cdo["provenanceRecords"].length()>1
			assert_equal "prov.994/6e157c5da4410b7e9de8", cdo["provenanceRecords"][0]["attributes"]["content"]["eventTypeId"]
		end
	end

	# 16 test call instance method to get the version of digital object at a given time (it doesn't required authentication but it needs data)
	def test_call_instance_get_version_at_given_time
		VCR.use_cassette('get_version_at_given_time') do
			data = {'timestamp' => "2019-12-09T10:28:20.000Z"}
			cdo = CordraRestClient::DigitalObject.call_instance_method("20.5000.1025/82752031921751eb6ab9","getVersionAtGivenTime",data,nil)

			# Because we have requested the version before the object was modified, the response should contain the attribute "comparisonAgainstCurrentVersion"
			assert_equal "20.5000.1025/82752031921751eb6ab9", cdo["id"]
			assert_equal true, cdo["attributes"].key?("comparisonAgainstCurrentVersion")
		end
	end

	# 17 test call instance method to retrieve versions of digital object (it does required authentication and data)
	def test_call_instance_method_process_event
		VCR.use_cassette('process_event') do
			cred=JSON.parse(YAML::load_file('test/fixtures/credential.yml').to_json)
			data = {
								"eventTypeId":"prov.994/46b7c3b13faa76b5af0f",
								"agentId":"20.5000.1025/d298a8c18cb62ee602b8",
								"roleId":"20.5000.1025/808d7dca8a74d84af27a",
								"timestamp": DateTime.now.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
								"description":"Testing: Specimen deposit in museum for exhibition",
								"data":{
										"museumId":"20.5000.1025/2fd4b4e4525def2122bb"
								}
							}
			cdo = CordraRestClient::DigitalObject.call_instance_method("20.5000.1025/82752031921751eb6ab9","processEvent",data,cred)

			# Check that its has at least one provenance record and the first one was for a create event
			assert_equal "20.5000.1025/82752031921751eb6ab9", cdo["id"]
		end
	end

	# 18 test advanced search to retrieve list of digital objects
	def test_advanced_search
		VCR.use_cassette('advanced_search') do
			query = "type:DigitalSpecimen AND /scientificName:\"Profundiconus profundorum\""
			page = 0
			page_size = 50
			list_cdo = CordraRestClient::DigitalObject.advanced_search(query,page,page_size)

			# Check that its has at least one provenance record and the first one was for a create event
			assert_equal true, list_cdo["results"].length<=page_size
		end
	end

end

