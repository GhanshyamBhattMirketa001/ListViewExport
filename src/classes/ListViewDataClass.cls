/**
* Created By      : Mirketa Inc.
* Created Date    : 11/05/2019
* Created Purpose : This is the main class of ListView Exporter in which we are retrieving the records corresponding to listview
                    Selection.
                    To know more about listView, Browse link ::
*                   https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_listview.htm
**/

public with sharing class ListViewDataClass { 
    //Class is with sharing class for data security point of view.
    
    /**
    *This block of code is retriving the sObject Type 
    *list from listView its mean only those objects are retrieve which are supported to listview. 
    **/
    
    @auraenabled
    public static List<String> objectList(){
        List<String> objNameList=new List<String>();
        Set<String> objSet=new Set<String>();
        List<ListView> lstView=[Select Id,Name,sObjectType from ListView];
        for(ListView lst:lstView){
            objSet.add(''+lst.sObjectType );
        }
        
        for(String lst:objSet){
            objNameList.add(''+lst);
        }
        List<String> usedObjectList=QueryListViewUsingServiceUtility.removeUnusedObject(objNameList);
        List<String> objectsWithAllPermission;
        if(usedObjectList !=null){
            objectsWithAllPermission=QueryListViewUsingServiceUtility.objectsListWithPermission(usedObjectList);
        }
        objectsWithAllPermission.sort();
        return objectsWithAllPermission;
    }

    
    /**
     *  This method is taking a single parameter
     *  ie. selectedObject its mean I am retreiving the listViews corresponding to selectedObject.  
    **/

    @auraenabled
    public static List<String> listViewData(String selectedObject){
        if(!Test.isRunningTest()){
            String temp2=selectedObject.replace(selectedObject.subStringbefore('('),'');
            temp2=temp2.replace('(','');
            temp2=temp2.replace(')','');
            temp2=temp2.trim();
            selectedObject=temp2;
            
        }
        List<String> listViewName=new List<String>();
        List<String> listViewId=new List<String>();
        List<String> accessableListViewId=new List<String>();
        List<String> accessableListViewName=new List<String>();
        
        //IsSoqlCompatible is used for avoId the Recent viewed filter.
        List<ListView> lstView=[Select Id,Name from ListView where sObjectType=:selectedObject and IsSoqlCompatible=true WITH SECURITY_ENFORCED];
        for(listview lst:lstView){
            listViewName.add(lst.Name);
            listViewId.add(''+lst.Id);
        }

        List<UserRecordAccess> listViewWithAccess = [SELECT RecordId FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND HasReadAccess = true AND RecordId IN :listViewId];
        for(UserRecordAccess userRecordsId:listViewWithAccess){
            accessableListViewId.add(''+userRecordsId.RecordId);
        }

        List<ListView> AccessableRecordsLstView=[Select Id,Name from ListView where sObjectType=:selectedObject AND Id IN :accessableListViewId AND IsSoqlCompatible=true WITH SECURITY_ENFORCED];
        for(ListView accsListView:AccessableRecordsLstView){
            accessableListViewName.add(accsListView.Name);
        }
        return accessableListViewName;
    }

    /**
     *  The getFilteredRecord() function is taking two Argument objectName and filterLabel.
     *  Based on these two arguments we are retrieving a Query and also data of ListView.
     *  This Block of code is devided in to 6 parts.
     *  1- If both parameter is not null then we are retrieving a Query of ListView.
     *  2- In 3rd part retrieving fields from Query for making a CSV headers and,
     *     if any field contain Dot (.) and toLabel() like Account.Name and toLabel(Type) then,
           As user cannot arrange the Dot (.) and toLabel() fields data into CSV format directly.
     *  3- So for this scenerio, user needs to find how many fields contain dot.
     *  4- A ListView query may contain many Dot fields so for all Dot fields, making list of Queries for retrieving the data.
     *  5- In 5th phase wrapping the data and fields.
    **/
    
    @auraenabled
    public static WrapperClass getFilteredRecord(String objectName, String filterLabel){
        //Retrive fields of the object-->

        /** 
         *  get object API Name for retrive the data.  
        **/
        if(!Test.isRunningTest()){
            String temp2=objectName.replace(objectName.subStringbefore('('),'');
            temp2=temp2.replace('(','');
            temp2=temp2.replace(')','');
            temp2=temp2.trim();
            objectName=temp2;
        }
        WrapperClass wrapperObj=new WrapperClass();
        List<String> listOfAllFields=new List<String>();
        
        
        
        /** 
         * -----------------------------------------Part 1----------------------------------------*
        **/
         if(filterLabel!='Null' && objectName!=null)
        {
            String queryData ='';
            String sObjectApiName = ''+objectName;
            //Retrieve data/listview data from object-->
            ListView listViewFilter;
            
            
            /**
             *  Salesforce is not allow to retrive task with directly pass any listview name in where clause.
             *  Example: select Id from ListView where sObjectType='Task' AND Name='Open Task'.
             * 'Open Task'  is not a complete String in salesforce.
             *  Getting a query fro Task object with passing the name in where clause with Like operator for get the Id of
                particular listView.
            **/
            if(objectName=='Task' ){
                List<String> splitedFilter=filterLabel.split(' ');
                List<String> objectAndFieldsForQuery=new List<String>();
                for(String replaceCotes : splitedFilter){
                    if(replaceCotes.Contains('\'')){
                        String temp = replaceCotes.subStringBefore('\'');
                        objectAndFieldsForQuery.add(temp);
                    }
                    else{
                        objectAndFieldsForQuery.add(replaceCotes);
                    }
                }
                String queryForTaskObject='Select Id,name from listview where name  LIKE ';
                queryForTaskObject += '\''+'%'+objectAndFieldsForQuery[0]+'%'+''+objectAndFieldsForQuery[1]+'%'+'\'';
                queryForTaskObject += ' and sObjectType= '+'\''+objectName+'\'';
                Try
                {
                listViewFilter=Database.query(queryForTaskObject);
                }
                Catch(Exception e){
                    system.debug('Expected Exception in this line '+e.getMessage());
                }
                
            }
            
            else if(objectName!='' && filterLabel!=''){
                Try{
                    
                    listViewFilter=[Select Id,Name from ListView where Name=:filterLabel AND sObjectType=:objectName];
                }
                Catch(Exception e){
                    System.debug('Exception is --> '+e.getMessage());
                }
            }

            /**
            * Rest API call for retrieve the Query of ListView in next line.
            **/
            
            String query;
            if(listViewFilter!=null){
                query=QueryListViewUsingServiceUtility.queryOfListView(objectName,listViewFilter.Id); //List view Query.
            }
           
            /** -----------------------------------------Part 1---------------------------------------- **/

            
            
            
            /** -----------------------------------------Part 2---------------------------------------- **/
            List<sObject> listViewRecords;
            try{
                listViewRecords=Database.query(query);   //Retrieve data of ListView.
            }
            Catch(Exception e){
                System.debug('Exception is --> '+e.getMessage());
            }
            
            List<String> listData = new List<String>();
            for(String s : query.split(',\\s*'))
            {
                listData.add(s);
            }
            
            List<String> fieldsValue=new List<String>();  //All the fields of ListView Query for making CSV header.
            for(Integer i=0;i<listData.size()-2;i++){
                if(listData[i].subStringBefore(' ')=='SELECT'){
                    fieldsValue.add(listData[i].subStringAfter(' '));
                }
                else{
                    fieldsValue.add(listData[i]); 
                }
            }
            /** -----------------------------------------Part 2---------------------------------------- **/
            

            /** ------------------------------------Part 3----------------------------------------**/

            Map<String,Set<String>> objectWithIdsOfDotFields=new Map<String,Set<String>>(); //{Account,<Id1,Id2,Id3> : Owner,<Id1,Id2,Id3>}
            Map<String,Set<String>> objectWithFieldsOfDotFields=new Map<String,Set<String>>(); //{Account,<Name,Id>}
            
            for(Integer i=0;i<fieldsValue.size();i++){
                // Here we are handle the Exception which is occured by toLabel('') type field; 
                if(fieldsValue[i].Contains('(')){
                    fieldsValue[i]=fieldsValue[i].replace(fieldsValue[i].subStringbefore('('),'');
                    fieldsValue[i]=fieldsValue[i].replace('(','');
                    fieldsValue[i]=fieldsValue[i].replace(')','');
                } 
                
                // Here we are handling the Exception which is occured by Related Field type field like Account.Name; 
                if(fieldsValue[i].Contains('.')){
                    String query2='';
                    String objectType=fieldsValue[i].subStringBefore('.');
                    String fieldName=fieldsValue[i].subStringAfter('.');
                    List<String> valueOfMap;
                    if(objectType.endsWith('__r')){
                        String tempString=objectType.subStringBefore('__r');
                        tempString=tempString+'__c';
                        objectType=tempString;
                    }
                    
                    // Owner can be queried by User.
                    if(objectType=='Owner'){
                        Set<String> fieldSet = objectWithFieldsOfDotFields.get('user') ;
                        if(fieldSet == null) {
                            Set<String> tempFieldSet = new Set<String>();
                            tempFieldSet.add(''+fieldName);
                            objectWithFieldsOfDotFields.put('user',tempFieldSet);
                        }
                        else{
                            objectWithFieldsOfDotFields.put('user',fieldSet);
                        }
                        
                    }
                    
                    // Manager is also a User.
                    if(objectType=='Manager'){
                        Set<String> fieldSet = objectWithFieldsOfDotFields.get('Manager') ;
                        if(fieldSet == null) {
                            Set<String> tempFieldSet = new Set<String>();
                            tempFieldSet.add(''+fieldName);
                            objectWithFieldsOfDotFields.put('Manager',tempFieldSet);
                        }
                        else{
                            objectWithFieldsOfDotFields.put('Manager',fieldSet);
                        }
                        
                    }
                    
                    //objectype = Who, that means it is a contact object.
                    else if(objectType=='Who'){
                        Set<String> fieldSet = objectWithFieldsOfDotFields.get('Contact') ;
                        if(fieldSet == null) {
                            Set<String> tempFieldSet = new Set<String>();
                            tempFieldSet.add(''+fieldName);
                            objectWithFieldsOfDotFields.put('Contact',tempFieldSet);
                        }
                        else{
                            objectWithFieldsOfDotFields.put('Contact',fieldSet);
                        }
                        
                    }
                    
                    //objectype = What, that means it is a Account object.
                    else if(objectType=='What'){
                        Set<String> fieldSet = objectWithFieldsOfDotFields.get('Account') ;
                        if(fieldSet == null) {
                            Set<String> tempFieldSet = new Set<String>();
                            tempFieldSet.add(''+fieldName);
                            objectWithFieldsOfDotFields.put('Account',tempFieldSet);
                        }
                        else{
                            objectWithFieldsOfDotFields.put('Account',fieldSet);
                        }
                        
                    }
                    
                    //LastModifiedBy is not a object.
                    else{
                        if(objectType != 'LastModifiedBy'){
                            Set<String> fieldSet = objectWithFieldsOfDotFields.get(''+objectType) ;
                            if(fieldSet == null) {
                                Set<String> tempFieldSet = new Set<String>();
                                tempFieldSet.add(''+fieldName);
                                objectWithFieldsOfDotFields.put(''+objectType,tempFieldSet);
                            }
                            else{
                                objectWithFieldsOfDotFields.put(''+objectType,fieldSet);
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            /**
            *   After finish this loop we get one maps objectWithFieldsOfDotFields in which data is look like in this way
            *   {Account=<Id,Name>,User=<Id,Name>}
            **/
            
            
            /**------------------------------------Part 3----------------------------------------**/
         
            for(String dotFieldsMap:objectWithFieldsOfDotFields.keySet()){ //Account,
                Set<String> tempIdSet = new Set<String>();
                for(sObject sb:listViewRecords){ 
                    if(dotFieldsMap=='User'){
                        tempIdSet.add((String)sb.get('OwnerId'));        
                    }
                    else if(dotFieldsMap=='Manager'){
                        tempIdSet.add((String)sb.get('ManagerId'));        
                    }
                    else if(dotFieldsMap=='Contact' && objectName=='Task'){
                        tempIdSet.add((String)sb.get('WhoId'));        
                    }
                    else if(dotFieldsMap=='Account'  && objectName=='Task'){
                        tempIdSet.add((String)sb.get('WhatId'));        
                    }
                    else if(dotFieldsMap.endsWith('__c')){
                        tempIdSet.add((String)sb.get(''+dotFieldsMap));        
                    }
                    else{
                        tempIdSet.add((String)sb.get(''+dotFieldsMap+'Id')); 
                    }
                }
                objectWithIdsOfDotFields.put(dotFieldsMap,tempIdSet);
                
            }
            
            
            /**
            *   After finish this loop we get one maps objectWithIdsOfDotFields in which data is look like in this way
            *   {Account=<Id1,Id2,Id3,Id4>,User=<Id1,Id2>}
            **/
            
            
            /**------------------------------------Part 5----------------------------------------**/
            
            
            /**
            *   In this block we are making a list or queries from fields and object which is retrived in objectWithFieldsOfDotFields map
            *   the number of Queries depend on the number of objects or keySet of objectWithFieldsOfDotFields
            **/
            
            List<String> queriesOfDotFields=new List<String>();
            for(String str:objectWithIdsOfDotFields.keyset()){
                String dotFieldQuery='';
                List<String> idConvertedInToList=new List<String>();
                
                for(String st:objectWithFieldsOfDotFields.get(''+Str)){
                    if(st=='NameOrAlias' && (Str=='User' || Str=='Owner')){
                        dotFieldQuery='Select Alias from User where Id in ';
                        dotFieldQuery +=' :objectWithIdsOfDotFields.get(';
                        
                        dotFieldQuery +='\''+Str+'\''+')';
                    }
                    else if(Str=='who'){
                        String temp='Contact';
                        dotFieldQuery='Select '+st+' from '+temp+' where Id in ';
                        dotFieldQuery +=' :objectWithIdsOfDotFields.get(';
                        
                        dotFieldQuery +='\''+'who'+'\''+')';
                    }
                    else if(Str=='what'){
                        String temp='Account';
                        dotFieldQuery='Select '+st+' from '+temp+' where Id in ';
                        dotFieldQuery +=' :objectWithIdsOfDotFields.get(';
                        
                        dotFieldQuery +='\''+'what'+'\''+')';
                    }
                    else{
                        dotFieldQuery='Select '+st+' from '+Str+' where Id in ';
                        dotFieldQuery +=' :objectWithIdsOfDotFields.get(';
                        
                        dotFieldQuery +='\''+Str+'\''+')';
                    }
                    
                }
                QueriesOfDotFields.add(dotFieldQuery); //Query for all dot fields.
            }
            
            
            /**------------------------------------Part 5----------------------------------------**/
            
            
            // In this block I am retrieving the data from list of queries and put it in a map.
            Map<String,Map<Id,sObject>> mapOfobjectNameWithItsRecords=new Map<String,Map<Id,sObject>>();
            
            for(String queries:QueriesOfDotFields){
                String temp = queries.subStringAfterLast(' ');
                temp=temp.replace(temp.subStringbefore('('),'');
                temp=temp.removeEnd(')').removeStart('(');
                temp=temp.removeEnd('\'').removeStart('\'');
                List<String> tempListOfIdsOfObject=new List<String>();
                for(String idsOfObject:objectWithIdsOfDotFields.get(''+temp)){
                    tempListOfIdsOfObject.add(IdsOfObject);
                }
                for(String idsOfObject:objectWithIdsOfDotFields.get(''+temp)){
                    tempListOfIdsOfObject.add(IdsOfObject);
                }
                queries=queries.replace(''+queries.subStringAfterLast(' '),':');
                queries+='tempListOfIdsOfObject';
                Map<Id, sObject> mapOfData;
                if(queries.Contains('Manager')){
                    String tempVar=queries;
                    tempVar=tempVar.replace('Manager', 'User');
                    queries=tempVar;
                    try{
                        mapOfData= new Map<Id, sObject>(Database.query(queries));
                    }
                    catch(Exception e){
                        system.debug('Exception is '+e.getMessage());
                    }
                    mapOfobjectNameWithItsRecords.put(''+temp,mapOfData);
                }
                else{
                    Try{
                        mapOfData= new Map<Id, sObject>(Database.query(queries));
                    }
                    Catch(Exception e){
                        system.debug('Exception is '+e.getMessage());
                    }
                    mapOfobjectNameWithItsRecords.put(''+temp,mapOfData);
                }
            }
            
            /** 
            *   After complete Execution of this block we get a map mapOfobjectNameWithItsRecords in which data is look like in this way
            *   {Account={Id=<Id,Name>},User={Id=<Id,Name>}}
            **/
            
            /**------------------------------------Part 6-------------------------------------------**/
 
            wrapperObj.records=listViewRecords;
            wrapperObj.fieldsName=fieldsValue;
            wrapperObj.dataOfDotRecords=mapOfobjectNameWithItsRecords; //dot fields records.
            
            /**------------------------------------Part 6-------------------------------------------**/
        }
        return wrapperObj;
        
    }
    
    public class WrapperClass{
        @auraEnabled
        public List<String> fieldsName;
        @auraEnabled
        public list<sObject> records;
        @auraEnabled
        public Map<String,Map<Id,sObject>> dataOfDotRecords;
        
    }

}