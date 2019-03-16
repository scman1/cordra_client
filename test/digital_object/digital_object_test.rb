#test/digital_object/digital_object_test.rb
require './test/test_helper'

class CordraRestClientDigitalObjectTest < Minitest::Test
  # basic test 
  def test_exists
    assert CordraRestClient::DigitalObject
  end
  
  # test retrieve object by ID
  def test_retrieve_object_by_id
    VCR.use_cassette('one_object') do
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
    VCR.use_cassette('new_object_success') do
      json = JSON.parse(File.read("test/fixtures/new_specimen.json"))
	
	  result=CordraRestClient::DigitalObject.create("new_ds_test_01","Digital Specimen",json,{"username":"xxxxx", "password":"xxxxx"})

	  #check that the result is saved
	  assert_equal 200, result[:code]
	  assert_equal "OK", result["message"]
	end
  end
  
  # test create an object by type, FAIL
  def test_create_object_by_type_fails
    VCR.use_cassette('new_object_fail') do
      json = JSON.parse(File.read("test/fixtures/new_specimen.json"))
	
	  result=CordraRestClient::DigitalObject.create("new_ds_test","Digital Specimen",json,{"username":"xxxxx", "password":"xxxxx"})
	  #check that the duplicate is rejected
	  assert_equal 409, result[:code]
	  assert_equal "Object already exists: 20.5000.1025/new_ds_test", result["message"]
	end
  end
  
  # test update an object by ID
  # test delete an object
  # test search for objects
  def test_search_for_objects
    VCR.use_cassette('paged_objects_list') do
      list_cdo = CordraRestClient::DigitalObject.search("Digital Specimen")
      assert_equal Hash, list_cdo.class
	  
      # Check that fields are accessible
      assert_equal list_cdo["pageNum"], 1
	  assert_equal list_cdo["pageSize"], 10
	  assert_equal list_cdo["size"], 24
	  assert_equal list_cdo["results"].class, Array
    end
  end
  # test retrieves an object via the Handle System web proxy
  # test modify the ACLs for a specific object  
  
end

