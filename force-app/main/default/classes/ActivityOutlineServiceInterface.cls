/**
* @author GrumpyCats
* @name ActivityOutlineServiceInterface
* @date Created 04/10/2020
* @description ActivityOutlineServiceInterface will provide 2 abstract methods for Activity timeline service.
*/
public interface ActivityOutlineServiceInterface {

    /** 
     * @description Gets a list of Activity types to be displayed for the object's Activity Outline
     * @param requestParams request parameters, if relevant to the object
     * @return List of ActivityOutlineTypeOptions for the object
     */
    List<ActivityOutlineTypeOption> getActivityTypes(ActivityOutlineParameters requestParams);
    
    /**
     * @description Gets the past activities for the record
     * @param requestParams request parameters, if relevant to the object
     * @return List of past activities
     */
	List<ActivityOutlineSObjectWrapper> getPastActivities(ActivityOutlineParameters requestParams);
    
    /**
     * @description gets the upcoming activities for the record
     * @param requestParams request parameters, if relevant to the object
     * @return List of upcoming activities
     */
    List<ActivityOutlineSObjectWrapper> getUpcomingActivities(ActivityOutlineParameters requestParams);
    
    /**
     * @description Determines if there are more records available
     * @param requestParams request parameters, if relevant to the object
     * @param records list of records already returned
     * @return true if more records are available, false if all records have already been retrieved
     */
    boolean hasMoreRecords(ActivityOutlineParameters requestParams, List<ActivityOutlineSObjectWrapper> records);
    
}