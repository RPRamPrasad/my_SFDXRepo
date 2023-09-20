/**
 * @Name AP_TranscriptProcess
 * @Author ITIC
 * @description Helper class for AP_CaptureTranscriptProcessor
 *
 * */
 public with sharing class AP_TranscriptProcess {

	/**
	 * @description method to username getters and setters
	 */
	public String userName {get;set;}

	/**
	 * @description method to email getters and setters
	 */
	public String email {get;set;}

	/**
	 * @description method to name getters and setters
	 */
	public String name {get;set;}

	/**
	 * @description method to alias getters and setters
	 */
	public String alias {get;set;}

	/**
	 * @description method to title getters and setters
	 */
	public String title {get;set;}

	/**
	 * @description method to id getters and setters
	 */
	public String id {get;set;}

	/**
	 * @description method to transcript process
	 * @param processUserWrapper
	 */
	public AP_TranscriptProcess(TranscriptUserDataWrapperList processUserWrapper){
	String uniqueKey = processUserWrapper.uniqueKey;
	String pEmail = processUserWrapper.pEmail;
	String pName = processUserWrapper.pName;
	String pAlias = processUserWrapper.pAlias;
	String pTitle = processUserWrapper.pTitle;
	String pId = processUserWrapper.pId;
		userName = uniqueKey;
		email = pEmail;
		name = pName;
		alias = pAlias;
		title = pTitle;
		id =  pId;
	}

	/**
	 * @description Transcript process User Data Wrapper List
	 */
	public class TranscriptUserDataWrapperList{
		public String uniqueKey;
		public String pEmail;
		public String pName;
		public String pAlias;
		public String pTitle;
		public String pId;
	}

	/**
	 * @description method to check username and email are equal
	 * @param obj
	 * @return  `Boolean`
	 */
	public Boolean equals(Object obj){
		if (obj instanceof AP_TranscriptProcess){
			AP_TranscriptProcess p = (AP_TranscriptProcess)obj;
			return (userName.equals(p.userName) && (email.equals(p.email)));
		}
		return false;
	}

	/**
	 * @description method to hashcode
	 * @return  `Integer`
	 */
	public Integer hashcode(){
		return (31 * userName.hashCode()) ^ email.hashCode();
	}

}