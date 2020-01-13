/**
* Created By      : Mirketa Inc.
* Created Date    : 11/05/2019
* Created Purpose : This Class is generating the Mock Response for a LIST View Rest API Call out. 
*					To know more about Salesforce REST API Call, Browse link :
*					https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_listviewresults.htm
**/
public class QueryAPITestClass implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        
        /** 
         * Optionally, only send a mock response for a specific endpoint and method.
        **/
       
        System.assertEquals('GET', req.getMethod());
        
        /**
         *  Create a fake response --> 
        **/
        HttpResponse res = new HttpResponse();
        res.setHeader('Authorization', 'Bearer ' + 'SESSION_ID_REMOVED');
        res.setBody('{"query":"SELECT Name, Site, BillingState, Phone, toLabel(Type), Owner.Alias, Id, CreatedDate, LastModifiedDate, SystemModstamp, Owner.Id, OwnerId FROM Account ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST"}');
        return res;
    }
}