/**
* Author : Team Astro
* Date Created : 08/2022
* @description : Class for toggling the load history button in Activity Outline
* Version : 1.0
*/
public with sharing class UTIL_AOArchiveToggleStrategy implements UTIL_ToggleStrategy {
    /**
     * @description - Returns true if load history button should be enabled, false otherwise
     * @param toggle
     * @param runtimeContext
     * @return Boolean
     */   
    public boolean isActive(CM_Toggle__mdt toggle, String runtimeContext) {
        if(toggle == null) {
            return false;
        }
        return toggle.Enabled__c;
    }
}
