/**
 * @description HLPR_AutoCompleteJsonController
 */
public with sharing class HLPR_AutoCompleteJsonController {

	private static final String SELECT_STATEMENT = 'Select ';
	private String searchTerm;
    private String objName;
    private String label;
    private String detail;
    private String lmt;
    private String value;
	private List<String> queryFields;
	private List<DataWrapper> wrappedData;
/**
 * @description HLPR_AutoCompleteJsonController
 */
	public HLPR_AutoCompleteJsonController() {
		AP_ClickJackPrevention.setRequiredHeaders();
		queryFields = new List<String>();
		wrappedData = new List<DataWrapper>();
	    searchTerm = getParameter(Apexpages.currentPage().getParameters().get('q').escapeHtml4());
	    objName = getParameter(Apexpages.currentPage().getParameters().get('obj').escapeHtml4());
	    label = getParameter(Apexpages.currentPage().getParameters().get('label').escapeHtml4());
	    detail = getParameter(Apexpages.currentPage().getParameters().get('detail').escapeHtml4());
	    lmt = getParameter(ApexPages.currentPage().getParameters().get('lm').escapeHtml4());
	    value = getParameter(Apexpages.currentPage().getParameters().get('value').escapeHtml4());
	}
/**
 * @description getJSON
 * @return  `String`
 */
	public String getJSON(){
        
        if(String.isBlank(lmt)){
            lmt = '10';
        }
        
        List<String> selectFields = new List<String>();
        selectFields.add(label);
        selectFields.add(value);
        
        //add comma-separated detail fields to query and store in separate list for retrieve
        List<String> detailsList = new List<String>();
        if(String.isNotBlank(detail)){
            detailsList = detail.split(',');
            selectFields.addAll(detailsList);
        }
        
        //filter out duplicates
        
        for(String field : selectFields){
            if(!queryFields.contains(field)) {
                queryFields.add(field);
            }
        }
        
        String query = buildQuery(searchTerm);
        
        //loop through records to get data
        executeQuery(query, detailsList);
        
        if(wrappedData.isEmpty()) {
            executeQuery(buildQuery(searchTerm.substring(0, 2)), detailsList);
            if(wrappedData.isEmpty()) {
                wrappedData.add(new DataWrapper('No results found for ' + searchTerm , '', searchTerm));
            } else {
                wrappedData.add(0, new DataWrapper('No results found for ' + searchTerm , 'Suggestions', searchTerm));
            }
        }
        return JSON.serialize(wrappedData);
    }

    private String buildQuery(String searchValue) {
        String query = String.escapeSingleQuotes(SELECT_STATEMENT);
        query += String.escapeSingleQuotes(String.join(queryFields,','));
        query += ' from ' + String.escapeSingleQuotes(objName) + ' where ' + String.escapeSingleQuotes(label) + ' like \'%' +String.escapeSingleQuotes(searchValue) + '%\'';
        query += ' Limit ' + String.escapeSingleQuotes(lmt);
        return query;

    }
    
    private void executeQuery(String query, List<String> detailsList) {
        for(SObject o : Database.query(query)){
            String thisdetail = '';
            
            //since multiple details fields can exist, loop through and store data in list
            //then convert list to comma-separated string for display
            if(String.isNotBlank(detail)){
                if(detailsList.size() > 1){
                    List<String> dlist = new List<String>();
                    executeQueryMethod(detailsList, dlist, o);
                    thisdetail = String.join(dlist,', ');
                } else {
                    thisdetail = (String) o.get(detailsList[0]);
                }
            }
            wrappedData.add(new DataWrapper(((String)o.get(label)), thisdetail, ((String)o.get(value))));
        }
    }
    
    private void executeQueryMethod(List<String> detailsList, List<String> dlist, SObject o){
        for(String d :detailsList){
            if(!dlist.contains(d)) {
                dlist.add((String)o.get(d));
            }
        }
    }

    private String getParameter(String s) {
        if(String.isNotBlank(s)) {
            return String.escapeSingleQuotes(s);
        } else {
            return '';
        }
    }
    /**
     * @description DataWrapper
     */
	public with sharing class DataWrapper {
		String dataWrapperLabel;
        String dataWrapperDetail;
        String dataWrapperValue;

        /**
         * @description DataWrapper 
         * @param l 
         * @param d 
         * @param v 
         */
		public DataWrapper(String l, String d, String v) {
			dataWrapperLabel = l; // label of suggestion
			dataWrapperDetail = d; // detail of suggestion
			dataWrapperValue = v; // the value of what is stored in the input tag. Commonly the Id of the record
		}
	}
}