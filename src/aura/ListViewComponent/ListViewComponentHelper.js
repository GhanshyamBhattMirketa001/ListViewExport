({ 
    /**
     * In this method, An Apex method is called (objectList) and List of objects is returned by Apex Controller. 
    **/
    objectlist : function(component,event){
        
        var action=component.get('c.objectList');
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set('v.objects',allValues);
                var spinner = component.find("mySpinner2");
                $A.util.removeClass(spinner, "slds-show");
                $A.util.addClass(spinner, "slds-hide");
            }
        })
        $A.enqueueAction(action);
    },
    
    /**
     * listViewData() method calling Apex method 'listViewData()' and retrieve the List of objects.
    **/
    
    listViewData : function(component,event){
        component.set('v.selectedListView',null);
        var strValue=component.get("v.selected");
        var action=component.get('c.listViewData');
        
        action.setParams({ selectedObject : ''+strValue});
        action.setCallback(this, function(response){
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set('v.filteredData',allValues);
                var spinner = component.find("mySpinner");
                $A.util.removeClass(spinner, "slds-show");
                $A.util.addClass(spinner, "slds-hide");
            }
        })
        $A.enqueueAction(action);
     
    },
    
    /**
     *  Fetch the Records from the Apex controller
    **/
    
    convertArrayOfObjectsToCSV : function(component,objectRecords,recordsOfDot,fieldsVal){
        
       
        var csvStringResult, counter, columnDivider, lineDivider;
        var keys=[];
        if (objectRecords == null || !objectRecords.length) {
            return null;   // check if "objectRecords" parameter is null, then return from function
        }        
        
        
        columnDivider = ',';
        lineDivider =  '\n';
        for(var i=0;i<fieldsVal.length;i++){
            keys.push(fieldsVal[i]);
        }
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        /**
         * Arranging data in CSV format.
        **/
        
        for(var j=0; j < objectRecords.length; j++){   
            counter = 0;
            for(var sTempkey in keys) { 
                var skey = keys[sTempkey] ; 
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }
                
                
                /**
                 * If the fields contain . (Dot) Exmaple: Account.Name etc.
                 * Such type of fields data cannot arranged in CSV format directly.
                **/
                
                if(skey.includes('.') && objectRecords[j][skey]===undefined && !skey.includes('LastModifiedBy')){
                    
                    var beforeDots = skey.split('.');
                    if(beforeDots[1]==='NameOrAlias' && beforeDots[0]==='Owner'){
                        beforeDots[0]='Owner';
                        beforeDots[1]='Alias';
                    }
                    else if(beforeDots[1]==='NameOrAlias'){
                        beforeDots[1]='Alias';
                    }
                    
                    
                    /**
                     * To get the Custom Objects data.-->
                    **/
                    if(beforeDots[0].endsWith('__r') && beforeDots[0] !=='LastModifiedBy'){
                        var tempString=beforeDots[0];
                        tempString=tempString.replace('__r','__c');
                        var valueOfDotFieldOfCustomObject=objectRecords[j][tempString];
                        if(valueOfDotFieldOfCustomObject !== undefined){
                            var mapOfIdAndsObjectWithCustomObject=recordsOfDot[tempString];
                            var idWithsObjectOfCustomObject=mapOfIdAndsObjectWithCustomObject[valueOfDotFieldOfCustomObject];
                            if(idWithsObjectOfCustomObject[''+beforeDots[1]]!==undefined && idWithsObjectOfCustomObject !== undefined){
                                csvStringResult += '"'+ idWithsObjectOfCustomObject[''+beforeDots[1]]+'"';
                            }
                            else{
                                csvStringResult += '"'+' '+'"';  
                            }
                        }
                        else{
                            csvStringResult += '"'+' '+'"';  
                        }
                        
                    }
						/**
						 * 	Who object refers to contact object.
                        **/                    
                    else if(beforeDots[0] ==='Who' && beforeDots[0] !=='LastModifiedBy')  
                    {
                        var valueOfDotFieldForWho=objectRecords[j][beforeDots[0]+'Id'];
                        if(valueOfDotFieldForWho !==undefined){
                            var mapOfIdAndsObjectForWho=recordsOfDot['Contact'];
                            var idWithsObjectOfWho=mapOfIdAndsObjectForWho[valueOfDotFieldForWho];
                            if(idWithsObjectOfWho[''+beforeDots[1]]!==undefined && idWithsObjectOfWho !== undefined){
                                csvStringResult += '"'+ idWithsObjectOfWho[''+beforeDots[1]]+'"';
                            }
                            else{
                                csvStringResult += '"'+' '+'"';  
                            }
                        }
                        else{
                            csvStringResult += '"'+' '+'"';  
                        }
                        
                    }
                    	/**
						 * 	What object refers to Account object.
                        **/ 
                        else if(beforeDots[0] ==='What' && beforeDots[0] !=='LastModifiedBy')
                        {
                            var valueOfDotFieldForAccount=objectRecords[j][beforeDots[0]+'Id'];
                            if(valueOfDotFieldForAccount !=undefined){
                                var mapOfIdAndsObjectForAccount=recordsOfDot['Account'];
                                var idWithsObjectForAccount=mapOfIdAndsObjectForAccount[valueOfDotFieldForAccount];
                                if(idWithsObjectForAccount[''+beforeDots[1]]!==undefined && idWithsObjectForAccount !== undefined){
                                    csvStringResult += '"'+ idWithsObjectForAccount[''+beforeDots[1]]+'"';
                                }
                                else{
                                    csvStringResult += '"'+' '+'"';  
                                }
                            }
                            else{
                                csvStringResult += '"'+' '+'"';  
                            }
                            
                        }
                    
                    	/**
						 * 	Manager object refers to user object.
                        **/ 
                    else if(beforeDots[0] ==='Manager' && beforeDots[0] !=='LastModifiedBy') 
                        {
                            var valueOfDotFieldForManager=objectRecords[j][beforeDots[0]+'Id'];
                            if(valueOfDotFieldForManager !==undefined){
                                var mapOfIdAndsObjectOfMManager=recordsOfDot['Manager'];
                                var idWithsObjectOfManager=mapOfIdAndsObjectOfMManager[valueOfDotFieldForManager];
                                if(idWithsObjectOfManager[''+beforeDots[1]]!==undefined && idWithsObjectOfManager !== undefined){
                                    csvStringResult += '"'+ idWithsObjectOfManager[''+beforeDots[1]]+'"';
                                }
                                else{
                                    csvStringResult += '"'+' '+'"';  
                                }
                            }
                            else{
                                csvStringResult += '"'+' '+'"';  
                            }
                            
                        }
                    	
                            else if(beforeDots[0] !=='Owner' && beforeDots[0] !=='LastModifiedBy') 
                            {
                                var valueOfDotFieldForOwner=objectRecords[j][beforeDots[0]+'Id'];
                                if(valueOfDotFieldForOwner !==undefined){
                                    var mapOfIdAndsObjectWithOwner=recordsOfDot[beforeDots[0]];
                                    var idWithsObjectOfOwner=mapOfIdAndsObjectWithOwner[valueOfDotFieldForOwner];
                                    if(idWithsObjectOfOwner===undefined){
                                        csvStringResult += '"'+' '+'"';  
                                    }
                                    else if(idWithsObjectOfOwner[''+beforeDots[1]]!==undefined && idWithsObjectOfOwner !== undefined){
                                        csvStringResult += '"'+ idWithsObjectOfOwner[''+beforeDots[1]]+'"';
                                    }
                                    else{
                                        csvStringResult += '"'+' '+'"';  
                                    }
                                }
                                else{
                                    csvStringResult += '"'+' '+'"';  
                                }
                                
                            }
                    	
                    	/**
						 * 	Owner object also refers to user object.
                        **/ 
                                else														
                                {
                                    var valueOfDotField=objectRecords[j][beforeDots[0]+'Id'];
                                    if(valueOfDotField !==undefined){
                                        var mapOfIdAndsObject=recordsOfDot['user'];
                                        var idWithsObject=mapOfIdAndsObject[valueOfDotField];
                                        if(idWithsObject===undefined){
                                            csvStringResult += '"'+' '+'"';  
                                        }
                                        else if(idWithsObject[''+beforeDots[1]]!==undefined && idWithsObject !== undefined){
                                            csvStringResult += '"'+ idWithsObject[''+beforeDots[1]]+'"';
                                        }
                                        else{
                                            csvStringResult += '"'+' '+'"';  
                                        }
                                    }
                                    else{
                                        csvStringResult += '"'+' '+'"';  
                                    }
                                    
                                }
                }
                
                else if(objectRecords[j][skey]===undefined && !skey.includes('.') || skey.includes('LastModifiedBy')){
                    csvStringResult += '"'+' '+'"';
                }
                    else{
                        csvStringResult += '"'+ objectRecords[j][skey]+'"'; 
                    }
                counter++;
                 
            } // inner for loop close 
            
            csvStringResult += lineDivider;
            
        }	// outer main for loop close 
        
        // return the CSV format String 
        return csvStringResult;  
        
    },
    
})