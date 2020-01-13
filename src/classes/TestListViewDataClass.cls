/**
* Created By      : Mirketa Inc.
* Created Date    : 11/05/2019
* Created Purpose : This Class is main Test Class in which we are doing testing of all methods of the main class. 
*					To know more about Salesforce Test class, Browse link :
*					https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_qs_test.htm
**/
@isTest
Public class TestListViewDataClass {
    
	/**
	 * List of objects Method testing.
	**/
    
    Public Static testmethod void retriveObjectsList(){
        
        List<String> listOfObjectsTest = ListViewDataClass.ObjectList();
        system.assertNotEquals(0, ListOfObjectsTest.size(),'Success');
        
    }
    
    /**
     * List of ListViews Method testing.
	**/
    public Static testmethod void retriveListView(){
         List<String> listOfListViewsTest = ListViewDataClass.ListViewData('Account');
        system.assertNotEquals(0, ListOfListViewsTest.size(),'SUCCESS');
    }
    
    /**
     * Data of List-View with HttpCallOutMock case 1.
	**/
    Public Static testmethod void retriveDataOfListView(){
        Test.setMock(HttpCalloutMock.class, new QueryAPITestClass());
        HttpResponse mockquery = QueryListViewUsingServiceUtility.getInfoFromExternalService();
        Map<String,Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(Mockquery.getBody());
        Object dataset=tokenResponse.get('query');
        string query = (String) dataset;
        
        System.assertEquals('SELECT Name, Site, BillingState, Phone, toLabel(Type), Owner.Alias, Id, CreatedDate, LastModifiedDate, SystemModstamp, Owner.Id, OwnerId FROM Account ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST', query,'SUCCESS');
        test.startTest();
        ListViewDataClass.getFilteredRecord('Account', 'All Accounts');
        test.StopTest();
    }
      	/**
       	* Data of List-View with HttpCallOutMock case 2.
		**/
    Public Static testmethod void retriveDataOfListViewTestCase2(){
        Test.setMock(HttpCalloutMock.class, new MockDataForTestClass());
        HttpResponse mockquery = QueryListViewUsingServiceUtility.getInfoFromExternalServiceDummy2ForTask();
        Map<String,Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(Mockquery.getBody());
        Object dataset=tokenResponse.get('query');
        string query = (String) dataset;
        system.assertEquals('SELECT toLabel(Subject), Who.Name, What.Name, ActivityDate, toLabel(Status), toLabel(Priority), Owner.Alias, LastModifiedDate, LastModifiedBy.Alias, Id, CreatedDate, SystemModstamp, Who.Id, WhoId, What.Id, WhatId, Owner.Id, OwnerId, LastModifiedBy.Id, LastModifiedById FROM Task USING SCOPE mine WHERE IsClosed = false AND IsRecurrence = false AND ActivityDate >= LAST_N_DAYS:30 ORDER BY ActivityDate ASC NULLS FIRST, Id ASC NULLS FIRST', query,'SUCCESS');
        test.startTest();
        ListViewDataClass.getFilteredRecord('Task', 'Open Tasks');
        test.StopTest();
    }
}