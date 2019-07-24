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
	  def test_retrieve_objects_via_handle
	    VCR.use_cassette('get_object_hanlde') do
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
end

