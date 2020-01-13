({
   
    /**
     * Get list of Objects from 'getObjectList()' Method.
    **/
    
    getObjectList: function(component, event, helper) {
        
        helper.objectlist(component, event);
        
    },
    
    /**
     * Get list of ListView from 'Getlistview()' Method.
    **/
    
    getListView: function(component, event, helper) {
        
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
        helper.listViewData(component, event);
        
    },
    /**
     * After getting the object name and selected listview name downloadCSV() method retriving data
       on the basis of Particular selection.
     * And then arrange the data in CSV format.
    **/
    
    downloadCSV: function(component, event, helper) {

        if(component.get("v.selected")==='' && component.get("v.selectedListView")==='' ){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Object and ListView selection both are mandatory',
                duration:' 500',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else if(component.get("v.selectedListView")===null || component.get("v.selectedListView")===''){
            var toastEventForLisViewError = $A.get("e.force:showToast");
            toastEventForLisViewError.setParams({
                title : 'Error',
                message:'ListView selection is mandatory',
                duration:' 500',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEventForLisViewError.fire();
            
        }
        else if(component.get("v.selectedListView")==='Overdue Tasks' ||component.get("v.selectedListView")==='Delegated Tasks' || component.get("v.selectedlistview")==='Recently Completed Tasks'){
            var toastEventForTasksError = $A.get("e.force:showToast");
            toastEventForTasksError.setParams({
                title : 'Error',
                message:'This ListView selection is not a string in salesforce',
                duration:' 500',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEventForTasksError.fire();
        }
        else {
            
            var spinner = component.find("mySpinner");
            $A.util.removeClass(spinner, "slds-hide");
            $A.util.addClass(spinner, "slds-show");
            
            var DataRecord = component.get("c.getFilteredRecord");
            DataRecord.setParams({ objectName : component.get('v.selected'),filterLabel : (component.get('v.selectedListView')==='')?'Null':component.get('v.selectedListView')});
            DataRecord.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.listOfDotRecord',response.getReturnValue().dataOfDotRecords);
                    component.set('v.listOfRecord',response.getReturnValue().records);
                    component.set('v.fieldsVal',response.getReturnValue().fieldsName);
                    var records=component.get('v.listOfRecord');
                    var dotRecords=component.get('v.listOfDotRecord');
                    var fields=component.get('v.fieldsVal');
                    if(records.length>2500){
                        var toastEventForDataSizeError = $A.get("e.force:showToast");
                        toastEventForDataSizeError.setParams({
                            title : 'Information',
                            message:'Your data size is more than 2500 ',
                            duration:' 1000',
                            key: 'info_alt',
                            type: 'warning',
                            mode: 'dismissible'
                        });
                        toastEventForDataSizeError.fire();
                    }
                    else{
                        var csv = helper.convertArrayOfObjectsToCSV(component,records,dotRecords,fields); 
                        if (csv == null ){
                            var toastEventForEmptyCsvError = $A.get("e.force:showToast");
                            toastEventForEmptyCsvError.setParams({
                                title : 'Information',
                                message:'No records found to download',
                                duration:' 500',
                                key: 'info_alt',
                                type: 'warning',
                                mode: 'dismissible'
                            });
                            toastEventForEmptyCsvError.fire();
                            var waitSpinner = component.find("mySpinner");
                            $A.util.removeClass(waitSpinner, "slds-show");
                            $A.util.addClass(waitSpinner, "slds-hide");
                            
                            return;
                        }
                        else
                        {
                            
                            var toastEventForSuccessFullExport = $A.get("e.force:showToast");
                            toastEventForSuccessFullExport.setParams({
                                title : 'Success',
                                message:'Data is successfully export',
                                duration:' 500',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'dismissible'
                            });
                            toastEventForSuccessFullExport.fire();
                            
                        }
                        var waitSpinnerClose = component.find("mySpinner");
                        $A.util.removeClass(waitSpinnerClose, "slds-show");
                        $A.util.addClass(waitSpinnerClose, "slds-hide");
                        
                        var hiddenElement = document.createElement('a');
                        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
                        hiddenElement.target = '_self'; // 
                        hiddenElement.download = ''+component.get("v.selectedListView")+'.csv';  // CSV file Name you can change it.
                        document.body.appendChild(hiddenElement); // Required for FireFox browser
                        hiddenElement.click(); // using click() js function to download csv file
                        
                    }
                }
                
            });
            $A.enqueueAction(DataRecord);
        }
    }
    
})