/** @description ActivityOutlineTypeOption will provide required properties for Activity Type filter in ActivityOutline component. */
public with sharing class ActivityOutlineTypeOption {

    /** @description Activity Type label */
    @AuraEnabled
    public String label{get;set;}
	
    /** @description Activity Type value */
    @AuraEnabled
    public String value{get;set;}
    
    /** @description Activity Type isDefault - only default activity types get displayed as filter options */
    @AuraEnabled
    public Boolean isDefault{get;set;}
    
    /**
     * @description Constructor class for setting the ActivityOutlineTypeOption values 
     * @param optionLabel
     * @param optionValue
     * @param optionDefault
     */
    public ActivityOutlineTypeOption(String optionLabel, String optionValue, Boolean optionDefault){
        label = optionLabel;
        value = optionValue;
        isDefault = optionDefault;
    }
}
