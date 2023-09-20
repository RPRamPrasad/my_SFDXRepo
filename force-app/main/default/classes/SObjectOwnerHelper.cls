/**
 * @name SObjectOwnerHelper
 * @description reuseable class to help assign sobject owner in insert or update triggers 
*/
public without sharing class SObjectOwnerHelper {

    @TestVisible private List<SObject> sobjectsWithOwnerChange = new List<SObject>();
    @TestVisible private Map<Id, SObject> oldsobjectsMap = new Map<Id, SObject>();
    @TestVisible private List<SObject> sobjects = new List<SObject>();
    @TestVisible private boolean isAfterTrigger = false;
    
    /**
     * @name SObjectOwnerHelper
     * @description OVERRIDE METHOD - set sobjects and isAfterTrigger variable values and initiate process
     * @param sobjects
     * @param isAfterTrigger
     */
    public SObjectOwnerHelper(List<SObject> sobjects, boolean isAfterTrigger){
        this.sobjects = sobjects;
        this.isAfterTrigger = isAfterTrigger;
        handleSObjectInsert();
    }
    
    /**
     * @name SObjectOwnerHelper
     * @description OVERRIDE METHOD - set sobjects, oldsobjectsMap, and isAfterTrigger variable values and initiate process
     * @param sobjects
     * @param oldsobjectsMap
     * @param isAfterTrigger
     */
    public SObjectOwnerHelper(List<SObject> sobjects, Map<Id, SObject> oldsobjectsMap, boolean isAfterTrigger){
        this.sobjects = sobjects;
        this.oldsobjectsMap = oldsobjectsMap;
        this.isAfterTrigger = isAfterTrigger;
        handleSObjectUpdate();
    }
    
    @TestVisible
    private void handleSObjectInsert(){
        setOwnerToProxy(this.sobjects);
    }
    
    @TestVisible
    private void handleSObjectUpdate(){
        for(SObject sobj : this.sobjects){
            SObject oldsobj = this.oldsobjectsMap.get(sobj.Id);
            handleOwnerChange(sobj, oldsobj);
        }
        setOwnerToProxy(this.sobjectsWithOwnerChange);  
    }
    
    @TestVisible
    private void handleOwnerChange(SObject sobj, SObject oldsobj){
        if(ownerHasChanged(sobj, oldsobj)){
            this.sobjectsWithOwnerChange.add(sobj);
        }
    }
    
    @TestVisible
    private void setOwnerToProxy(List<SObject> sobjects){
        if(!sobjects.isEmpty()){
            SObjectOwnershipUtility.setObjectOwnerToProxy(sobjects, this.isAfterTrigger);
        }
    }
    
    @TestVisible
    private boolean ownerHasChanged(SObject sobj, SObject oldsobj){
        return sobj.get('OwnerId') != oldsobj.get('OwnerId');
    }
    
}