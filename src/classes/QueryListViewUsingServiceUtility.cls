/**
* Created By      : Mirketa Inc.
* Created Date    : 11/05/2019
* Created Purpose : This is the Utility class of ListView Exporter in which we are removing the unused objects, retrieving the Query of
*					listview from REST API and creting a mock data for test class.
					To know more about listView REST API, Browse link :
*					https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_listview.htm
**/
public with sharing class QueryListViewUsingServiceUtility {
    
    /**
	*	This block of code is removing the list of objects which is not described in ListView's.
	**/
    public static List<String> removeUnusedObject(List<String> listOfObjects){
        
        String commaseperatedListofObjectsToRemove = 'null,Profile,PermissionSet,MatchingRule,ActionEmail,ActionPlan ,AuthorizationForm, AuthorizationFormText , AuthorizationFormDataUseFormConsent,AuthorizationFormDataUse,ActionTask,ActionFieldUpdate,ActiveScratchOrg,Activity,Asset,AppMenuItem,BadgeMissionRule,CleanRule,CollaborationGroup ,  ConsumptionSchedule , ContentDocument ,  ContactRequest ,  ContentNote ,  CustomReportType ,  DatedConversionRate ,  EmailRoutingAddress ,  InteractionLayoutDetail ,  Report ,  Territory';
        commaseperatedListofObjectsToRemove += 'Topic,WorkBadgeDefinition,WorkFeedbackRequest,WorkFeedbackTemplate ,  WorkflowRule ,  SocialPost ,  SocialPersona ,  MatchingRule ,  Scorecard ,  ProductCategory ,AssessmentIndicatorDefinition';
        commaseperatedListofObjectsToRemove +='AssessmentTask , AssessmentTaskOrder,Assortment,AuthorizationFormConsent,CollaborationGroup,ConsumptionSchedule,ContactPointConsent,ContactPointTypeConsent,ContactRequest,ContentDocument,ContentNote,Contract,CustomReportType,Dashboard,DataUseLegalBasis,DataUsePurpose ';
        commaseperatedListofObjectsToRemove +='DatedConversionRate,Permission Set, PricebookEntry,ProductCategory,DeleteEvent,EmailRoutingAddress,FlowDefinitionView,FlowInterview,Idea,InStoreLocation, DatedConversionRate  ,InteractionLayoutDetail,InteractionLayoutDetail,KeyPerformanceIndicator,MassMail,Note,ProcessInstanceWorkitem,ProductCatalog,Promotion,Recommendation,Report,RetailLocationGroup,RetailStore,RetailStoreKpi';
        commaseperatedListofObjectsToRemove += 'RetailVisitTemplate,RetailWorkTask,SalesAgreement,Scorecard,Solution,Survey,Territory,Topic,UserRole,Visit,WorkBadgeDefinition,WorkFeedbackRequest,WorkFeedbackTemplate,WorkflowRule';
        commaseperatedListofObjectsToRemove = commaseperatedListofObjectsToRemove.trim();
        List<String> listOfObjectsToRemove = commaseperatedListofObjectsToRemove.split(',');
        
        for(String str : listOfObjectsToRemove) {
            if(listOfObjects.IndexOf(Str) >=0) { 
                listOfObjects.remove(listOfObjects.IndexOf(Str));
            }
            
        }
        Try{
            listOfObjects.remove(listOfObjects.IndexOf('AuthorizationFormText'));
            listOfObjects.remove(listOfObjects.IndexOf('DataUsePurpose'));
            listOfObjects.remove(listOfObjects.IndexOf('DatedConversionRate'));
        }
        Catch(Exception e){
            System.debug('Exception is --> '+e.getMessage());
        }
        return listOfObjects;
        
    }
    
    
   	 	/**
		 *	This block of code is filtering the supported listview objects with security Access level,
    	 *	it means only accessible objects are showing in object list.
		**/
    
    public static List<String> objectsListWithPermission(List<String> objectsList){
        List<String> objectsWithPermission=new List<String>();
        
        for(String str:objectsList){
            Schema.DescribeSObjectResult[] descResult;
            Try{
                descResult = Schema.describeSObjects(new String[]{''+Str});
                if(descResult!=null && descResult[0].isAccessible()){
                    objectsWithPermission.add(''+descResult[0].getLabel() +'       ( '+descResult[0].getName()+' )');
                    
                }
            }
            Catch(Exception e){
                System.debug('Exception is -->'+e.getMessage());
            }
            
        }
        
        
        return objectsWithPermission;
    }
    
    /**
	 *	This block of code is retrived the Session Id for API call.
	**/
    
    public static String fetchUserSessionId(){
        String sessionId = '';
        
        /**
         *  Refer to the Page
        **/
        PageReference reportPage = Page.GetSessionIdVF;
        String vfContent='';
        // Get the content of the VF page
        if(!Test.isRunningTest()) { 
            vfContent = reportPage.getContent().toString();
        } 
        else {
            vfContent = '';
        }
        
        /**
         *  Find the position of Start_Of_Session_Id and End_Of_Session_Id
        **/
        Integer startP = vfContent.IndexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.IndexOf('End_Of_Session_Id');
        
        /**
         *  Get the Session Id
        **/
        if(Test.isRunningTest()){
            sessionId ='SESSION_ID_REMOVED';
        }
        else{
            sessionId = vfContent.subString(startP, endP);
        }
        
        // Return Session Id
        return sessionId;
    }
    
    /**
	 *	This method is creating a REST API Call for get the ListView Query from salesforce org.
	 *	Example : objectName=Account and listView ID is All Accounts ID-.
	**/
    
    public static String queryOfListView(String objectName,String listViewId){
        HttpRequest req = new HttpRequest();
        String query='';
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String sessionId = QueryListViewUsingServiceUtility.fetchUserSessionId();
        String endPoinURL = baseUrl+'/services/data/v46.0/sobjects/'+objectName+'/listviews/'+listViewId+'/describe';
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        Map<String,Object> tokenResponse;
        Try{
            tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        }
        Catch(Exception e){
            system.debug('Exception is --> '+e.getMessage());
        }
        
        Object dataSet=tokenResponse.get('query');
        query = (String) dataSet;
        //Return query of ListView.
        return query;
        
    }
    /**
     * This method is creating a REST API call mock data for test classes.	
``	**/
    public static HttpResponse getInfoFromExternalService() {
        HttpRequest req = new HttpRequest();
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        req.setEndpoint(baseUrl+'/services/data/v46.0/sobjects/Account/listviews/00B6g000001UYUrEAO/describe');
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }
    
    /**
     * This method is creating a REST API call mock data for test classes.	
``	**/
    public static HttpResponse getInfoFromExternalServiceDummy2ForTask() {
        HttpRequest req = new HttpRequest();
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        req.setEndpoint(baseUrl+'/services/data/v46.0/sobjects/Task/listviews/00B6g000001UYWWEA4/describe');
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }
    
}