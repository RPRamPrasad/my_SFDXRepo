/** 
* @name EventTriggerHandler
* @createdDate 11/04/2020
* @description handle event trigger logic
*/
public with sharing class EventTriggerHandler {
    /**
    * @name preventEventDelete
	* @param eventList
    * @description prevent deleting of any events except unarchived recurring events
	*/
    public static void preventEventDelete(List<Event> eventList) {
        for(Event deleteEvent : eventList) {
            if(!(deleteEvent.RecurrenceActivityId!=null && deleteEvent.IsArchived == false)){
                deleteEvent.addError(Label.CL_EventPreventDeleteMsg);
            }
        }
    }
    
}