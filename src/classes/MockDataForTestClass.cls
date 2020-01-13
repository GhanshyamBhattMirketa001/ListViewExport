/**
* Created By      : Mirketa Inc.
* Created Date    : 11/05/2019
* Created Purpose : This Class is generating the Mock Response for a LIST View Rest API Call out. 
*                   To know more about Salesforce REST API Call, Browse link :
*                   https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_listviewresults.htm
**/

public class MockDataForTestClass implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        
        // Optionally, only send a mock response for a specific endpoint and method.
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Authorization', 'Bearer ' + 'SESSION_ID_REMOVED');
        res.setBody('{"query":"SELECT toLabel(Subject), Who.Name, What.Name, ActivityDate, toLabel(Status), toLabel(Priority), Owner.Alias, LastModifiedDate, LastModifiedBy.Alias, Id, CreatedDate, SystemModstamp, Who.Id, WhoId, What.Id, WhatId, Owner.Id, OwnerId, LastModifiedBy.Id, LastModifiedById FROM Task USING SCOPE mine WHERE IsClosed = false AND IsRecurrence = false AND ActivityDate >= LAST_N_DAYS:30 ORDER BY ActivityDate ASC NULLS FIRST, Id ASC NULLS FIRST"}');
        return res;
    }

}