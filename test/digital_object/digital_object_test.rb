#test/digital_object/digital_object_test.rb
require './test/test_helper'

class CordraRestClientDigitalObjectTest < Minitest::Test
  # basic test 
  def test_exists
    assert CordraRestClient::DigitalObject
  end
  
  # test retrieve object by ID
  def test_retrieve_object_by_id
    VCR.use_cassette('retrieve_object_id_success') do
      cdo = CordraRestClient::DigitalObject.find("20.5000.1025/1a0beb212baaede1c10c")
      assert_equal CordraRestClient::DigitalObject, cdo.class
	  
      # Check that fields are accessible
      assert_equal cdo.id,  "KS.191"
	  assert_equal cdo.timestamp, "2018-12-20T11:31:45.658Z"
	  assert_equal cdo.creator, "20.5000.1025/60c6d277a8bd81de7fdd"
      assert_equal cdo.scientificName, "Salmo trutta"
      assert_equal cdo.country, "Finland"
      assert_equal cdo.locality, "Uusimaa (U),Inkoo"
      assert_equal cdo.decimalLatLong, [59.746793,23.77987]
	  assert_equal cdo.recordedBy, "Nurminen, Katariina"
      assert_equal cdo.collectionDate, "2002-11-14"
      assert_equal cdo.catalogNumber, "2636"
      assert_equal cdo.otherCatalogNumbers, "KK2827"
      assert_equal cdo.collectionCode, "Luomus - Pisces"
      assert_equal cdo.institutionCode, "MZH"
      assert_equal cdo.stableIdentifier, "http://id.luomus.fi/KS.191"
      assert_equal cdo.physicalSpecimenId, "KS.191"
      assert_equal cdo.determinations, "Yes"
    end
  end
  # test create an object by type
  def test_create_object_by_type
    VCR.use_cassette('create_object_success') do
	  cred=JSON.parse(YAML::load_file('test/fixtures/credential.yml').to_json)
      json = JSON.parse(File.read("test/fixtures/new_specimen.json"))

	  result=CordraRestClient::DigitalObject.create("new_ds_test_03","Digital Specimen",json, cred["uc_1"])
      
	  #check that the result is saved
	  assert_equal 200, result[:code]
	  assert_equal "OK", result["message"]
	end
  end
  
  # test create an object by type, FAIL
  def test_create_object_by_type_fails
    VCR.use_cassette('create_object_fail') do
	  cred=JSON.parse(YAML::load_file('test/fixtures/credential.yml').to_json)

      json = JSON.parse(File.read("test/fixtures/new_specimen.json"))
	
	  result=CordraRestClient::DigitalObject.create("new_ds_test","Digital Specimen",json, cred["uc_1"])
	  #check that the duplicate is rejected
	  assert_equal 409, result[:code]
	  assert_equal "Object already exists: 20.5000.1025/new_ds_test", result["message"]
	end
  end
  
  # test update an object by ID
    def test_update_object_by_ID
    VCR.use_cassette('edit_object_success') do
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
  
  # test delete an object
  
  # test search for objects
  def test_search_for_objects
    VCR.use_cassette('search_objects_success') do
      list_cdo = CordraRestClient::DigitalObject.search("Digital Specimen")
      assert_equal Hash, list_cdo.class
	  
      # Check that fields are accessible
      assert_equal 1, list_cdo["pageNum"]
	  assert_equal 10, list_cdo["pageSize"]
	  assert_equal 30, list_cdo["size"]
	  assert_equal Array, list_cdo["results"].class
    end
  end
  # test retrieves an object via the Handle System web proxy
  # test modify the ACLs for a specific object  
  
end

