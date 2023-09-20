/** 
* @description case test data utility 
* @Owner: Grumpycats
*/
public virtual with sharing class TaskFactory {
    
    protected String subject;
    protected String description;
    protected String priority;
    protected Date activityDate;
    protected String appCode;
    protected String taskCategory;
    protected String taskSubCategory;
    protected String taskType;
    protected String whoId;
    protected String whatId;
    protected String lineOfBusiness;
    protected String assignedTo;
    protected String ownerId;
    protected String status;
    
    /**
     * @name setOwnerId
     * @description setOwnerId
     * @param ownerId
     * @return TaskFactory
     */
    public TaskFactory setOwnerId(String ownerId){
        this.ownerId = ownerId;
        return this;
    }
    /**
     * @name setSubject
     * @description setSubject
     * @param subject
     * @return TaskFactory
     */
    public TaskFactory setSubject(String subject){
        this.subject = subject;
        return this;
    }
    /**
     * @name setDescription
     * @description setDescription
     * @param description
     * @return TaskFactory
     */
    public TaskFactory setDescription(String description){
        this.description = description;
        return this;
    }
    /**
     * @name setPriority
     * @description setPriority
     * @param priority
     * @return TaskFactory
     */
    public TaskFactory setPriority(String priority){
        this.priority = priority;
        return this;
    }
    /**
     * @name setAppCode
     * @description setAppCode
     * @param appCode
     * @return TaskFactory
     */
    public TaskFactory setAppCode(String appCode){
        this.appCode = appCode;
        return this;
    }
    /**
     * @name setTaskCategory
     * @description setTaskCategory
     * @param taskCategory
     * @return TaskFactory
     */
    public TaskFactory setTaskCategory(String taskCategory){
        this.taskCategory = taskCategory;
        return this;
    }
    /**
     * @name setActivityDate
     * @description setActivityDate
     * @param activityDate
     * @return TaskFactory
     */
    public TaskFactory setActivityDate(Date activityDate){
        this.activityDate = activityDate;
        return this;
    }
    /**
     * @name setTaskSubCategory
     * @description setTaskSubCategory
     * @param taskSubCategory
     * @return TaskFactory
     */
    public TaskFactory setTaskSubCategory(String taskSubCategory){
        this.taskSubCategory = taskSubCategory;
        return this;
    }
    /**
     * @name setTaskType
     * @description setTaskType
     * @param taskType
     * @return TaskFactory
     */
    public TaskFactory setTaskType(String taskType){
        this.taskType = taskType;
        return this;
    }
    /**
     * @name setWhoId
     * @description setWhoId
     * @param whoId
     * @return TaskFactory
     */
    public TaskFactory setWhoId(String whoId){
        this.whoId = whoId;
        return this;
    }
    /**
     * @name setWhatId
     * @description setWhatId
     * @param whatId
     * @return TaskFactory
     */
    public TaskFactory setWhatId(String whatId){
        this.whatId = whatId;
        return this;
    }
    /**
     * @name setLineOfBusiness
     * @description setLineOfBusiness
     * @param lineOfBusiness
     * @return TaskFactory
     */
    public TaskFactory setLineOfBusiness(String lineOfBusiness){
        this.lineOfBusiness = lineOfBusiness;
        return this;
    }
    /**
     * @name setAssignedTo
     * @description setAssignedTo
     * @param assignedTo
     * @return TaskFactory
     */
    public TaskFactory setAssignedTo(String assignedTo){
        this.assignedTo = assignedTo;
        return this;
    }
    /**
     * @name setStatus
     * @description setStatus
     * @param status
     * @return TaskFactory
     */
    public TaskFactory setStatus(String status){
        this.status = status;
        return this;
    }

}