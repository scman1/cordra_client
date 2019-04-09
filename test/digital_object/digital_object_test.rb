#test/digital_object/digital_object_test.rb
require './test/test_helper'

class CordraRestClientDigitalObjectTest < Minitest::Test
  # basic test 
  def test_exists
    assert CordraRestClient::DigitalObject
  end
  
  # test retrieve object by ID
  def test_retrieve_object_by_id
    VCR.use_cassette('retrieve_object_id') do
      cdo = CordraRestClient::DigitalObject.find("20.5000.1025/B100003484")
      assert_equal CordraRestClient::DigitalObject, cdo.class
	  
      # Check that fields are accessible
      assert_equal "20.5000.1025/B100003484", cdo.id
	  assert_nil   cdo.timestamp
	  assert_equal "20.5000.1025/60c6d277a8bd81de7fdd", cdo.creator
      assert_equal "Agathis palmerstonii (F.Muell.) F.M.Bailey", cdo.scientificName
      assert_equal "Australia", cdo.country
      assert_equal "Queensland", cdo.locality
      assert_nil   cdo.decimalLatLong
	  assert_equal "L. J. Brass 2421", cdo.recordedBy
      assert_equal "1932-04-08", cdo.collectionDate
      assert_equal "B 10 0003484", cdo.catalogNumber
      assert_equal "2421", cdo.otherCatalogNumbers
      assert_equal "Australia: Queensland", cdo.collectionCode
      assert_equal "B", cdo.institutionCode
      assert_equal "http://herbarium.bgbm.org/object/B100003484", cdo.stableIdentifier
      assert_equal "B 10 0003484", cdo.physicalSpecimenId
      assert_equal "Yes", cdo.determinations
    end
  end
  # test retrieve object creator, variant of  retrieve object by ID
  def test_retrieve_object_creator
    VCR.use_cassette('retrieve_object_attribute') do
	do_creator = CordraRestClient::DigitalObject.get_do_field("20.5000.1025/B100003484","creator")
        # Check object creator
        assert_equal "20.5000.1025/60c6d277a8bd81de7fdd", do_creator
    end
  end
  # pending testing of get payload, other attributes
  
  # test create an object by type
  def test_create_object_by_type
    VCR.use_cassette('create_object') do
	  cred=JSON.parse(YAML::load_file('test/fixtures/credential.yml').to_json)
      json = JSON.parse(File.read("test/fixtures/new_specimen.json"))

	  result=CordraRestClient::DigitalObject.create("RMNH.RENA.38646","Digital Specimen",json, cred["uc_1"])
      
	  #check that the result is saved
	  assert_equal 200, result[:code]
	  assert_equal "OK", result["message"]
	end
  end
  
  # test create an object by type, FAIL
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
  
  # test update an object by ID
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
  
  # test delete an object by ID
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
  
  # test search for objects
  def test_search_for_objects
    VCR.use_cassette('search_objects') do
      list_cdo = CordraRestClient::DigitalObject.search("Digital Specimen")
      assert_equal Hash, list_cdo.class
	  
      # Check that fields are accessible
      assert_equal 1, list_cdo["pageNum"]
	  assert_equal 10, list_cdo["pageSize"]
	  assert_equal 24, list_cdo["size"]
	  assert_equal Array, list_cdo["results"].class
    end
  end
  # test retrieves an object via the Handle System web proxy
  def test_retrieve_objects_via_handle
    VCR.use_cassette('get_object_hanlde') do
      redirection = CordraRestClient::DigitalObject.handle_find("20.5000.1025/B100003484")
      assert_equal String, redirection.class
	  
      # Check that fields are accessible
	  assert_match /Handle Redirect/, redirection
	  assert_match /B100003484/, redirection
    end
  end  
  # test modify the ACLs (permissions) for a specific object 
  # Not working, could be because of limits of test user credentials
  def test_modify_object_permissions
    VCR.use_cassette('modify_permissions') do
	  cred=JSON.parse(YAML::load_file('test/fixtures/credential.yml').to_json)
	  json = JSON.parse(File.read("test/fixtures/acl_list.json"))
	  id = "20.5000.1025/RMNH.RENA.44084" 
	  result=CordraRestClient::DigitalObject.set_premissions(id, json, cred["uc_1"])

	  #check that the result is saved
	  assert_equal 200, result[:code]
	  assert_equal "OK", result["message"]
	end
  end
end

