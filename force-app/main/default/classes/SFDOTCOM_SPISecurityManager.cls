/**
* Author : Trailblazers/Dreambuilders
* Date Created : 5/24/2017
* @description : A cloned SPI Manager class to handle SPI Remarks as a special case for Release2.
* Version : 1.0
*/ 
public without sharing class SFDOTCOM_SPISecurityManager {
    
    private List<SPI_Security_Control__c> securityControls;
    public Static final String REGEX_TO_FILTER_HTML = '<[/a-zAZ0-9]*>';
    
    private String class_Name='SFDOTCOM_SPISecurityManager '; 
    private String execute_Method_Name='handle';
    private List<String> textAreaList = new List<String>();
    private Map<String,String> fieldLabelMap = new Map<String,String>();
    private Map<String,String> objectLabelMap = new Map<String,String>();
    private Map<String,Boolean> richTextMap = new Map<String,Boolean>();
    
    private static Integer chunkSize;
    private static Integer smallChunkSize;
    private static Integer edgeChunkSize;
    
    /**
* @description This method prevents SPI for free formed text data
* @param records List<SObject>
* @return String
*/
    public String handle(List<SObject> records) {
        String spiErrorMessage = null;
        String textBody;
        securityControls = [Select Name, Regex_Pattern__c,Description__c, Error_Message_Label__c, Active__c from SPI_Security_Control__c where Active__c = true ];    
        populateSobjectFieldDetails(records);
        
        if(!textAreaList.isEmpty() && securityControls!=null && !securityControls.isEmpty()) {

            chunkSize=Integer.valueOf(CS_SPI_Chunk_Text_Size__c.getInstance().SPI_Chunk_Size__c);
            smallChunkSize=Integer.valueOf(CS_SPI_Chunk_Text_Size__c.getInstance().SPI_Small_Chunk_Size__c);
            edgeChunkSize=chunkSize-smallChunkSize/2;            
            Map<Pattern,SPI_Security_Control__c> mapOfPatternControls=compileRegexPatterns();
            
            for(SObject record: records) {
                String errorMessage = '';
                try {
                        SObjFieldIsNullWrapper sobjWrap = new SObjFieldIsNullWrapper();
                        sobjWrap.errorMessage = errorMessage;
                        sobjWrap.textBody = textBody;
                        sobjWrap.spiErrorMessage = spiErrorMessage;
                        spiErrorMessage = sobjFieldIsNull(record, mapOfPatternControls, sobjWrap);
                } catch(Exception e) { 
                    LoggingService.logHandledException(e, class_Name, execute_Method_Name, LoggingLevel.ERROR);
                }
            }
        }
        return spiErrorMessage ;
    }

    private class SObjFieldIsNullWrapper{
        String errorMessage;
        String textBody;
        String spiErrorMessage;
    }
    /**
     * @description sobjFieldIsNull
     * @param record 
     * @param mapOfPatternControls 
     * @param sobjWrap 
     * @return String
     */
    private String sobjFieldIsNull(SObject record, Map<Pattern,SPI_Security_Control__c> mapOfPatternControls, SObjFieldIsNullWrapper sobjWrap){
        for(String textAreaField: textAreaList) {
                        Object sobjField = record.get(textAreaField);                                             
                        if(sobjField != null) {
                            sobjWrap.textBody = String.valueOf(sobjField);
                            if(!String.isBlank(sobjWrap.textBody)) { 
                                String lineOfFullText=transformAndReturnSObjectFeildValue(sobjWrap.textBody,textAreaField);
                                sobjWrap.errorMessage=handleSObjectFieldDataForSPI(lineOfFullText,textAreaField,sobjWrap.errorMessage,mapOfPatternControls);
                            }
                        }
                         }
                    if(String.isNotBlank(sobjWrap.errorMessage)) {
                        record.addError(sobjWrap.errorMessage.escapeHtml4(), false);
                        sobjWrap.spiErrorMessage = sobjWrap.errorMessage;
                    }
                    return sobjWrap.spiErrorMessage;
                }

    /**
* @description This method Handle SObject Fields for SPI Data consists with small or long text
* @param lineOfFullText String 
* @param textAreaField String 
* @param errorMessage String
* @param mapOfPatternControls Map<Pattern,SPI_Security_Control__c> 
* @return String
* @throws None
*/     
    private String handleSObjectFieldDataForSPI(String lineOfFullText,String textAreaField, String errorMessage,Map<Pattern,SPI_Security_Control__c> mapOfPatternControls){
        String tempErrorMessage='';
        if(lineOfFullText.length()>chunkSize){
            String lineOfPartialText=lineOfFullText.right(lineOfFullText.length()- edgeChunkSize);
            Integer numberOfChunk= determineNumberOfChunks(lineOfFullText);
            tempErrorMessage=traverseChunkDataAndValidateForSPI(lineOfFullText,textAreaField,numberOfChunk,mapOfPatternControls);
            if (String.isBlank(tempErrorMessage)){
                tempErrorMessage=traverseEdgeChunkDataAndValidateForSPI(lineOfPartialText,textAreaField,numberOfChunk,mapOfPatternControls);
            }
        }else{
            tempErrorMessage=validateTextForSPIData(textAreaField,lineOfFullText,mapOfPatternControls);
        }
        return errorMessage+tempErrorMessage;
    }
    
    /**
* @description compileRegexPatterns This method compile REGEX pattern according to Controls in Custom Setting
* @return Map<Pattern,SPI_Security_Control__c> - Map of Compiled Pattern and Control
* @throws None
*/    
    
    private Map<Pattern,SPI_Security_Control__c> compileRegexPatterns(){
        Map<Pattern,SPI_Security_Control__c> mapOfPatternControls=new Map<Pattern,SPI_Security_Control__c>();
        for(SPI_Security_Control__c control: securityControls) {
            String tempRegex = UTIL_Constants.REGEX_BEGIN_OF_LINE_WILD_CARD + control.Regex_Pattern__c + UTIL_Constants.REGEX_END_OF_LINE_WILD_CARD;                                                                                                   
            Pattern myPattern = Pattern.compile(tempRegex);   
            mapOfPatternControls.put(myPattern, control);
        }
        return mapOfPatternControls;
    }
    
    /**
* @description This method populate SObjects field details and configured SPI fields in Custom Settings
* @param records 
* @throws None
*/     
    private void populateSobjectFieldDetails(List<SObject> records){
        Map<string,CS_SPI_Data_Prevention_Fields__c> spiFieldsCS = CS_SPI_Data_Prevention_Fields__c.getAll(); 
        SObjectType objType = records.getSObjectType();
        if(spiFieldsCS != null) {
            for(CS_SPI_Data_Prevention_Fields__c spiField: spiFieldsCS.values()) {
                if(spiField.Object_Api_Name__c == objType.getDescribe().getName()) {
                    textAreaList.add(spiField.Field_Api_Name__c);
                    fieldLabelMap.put(spiField.Field_Api_Name__c,spiField.Field_Label__c);
                    objectLabelMap.put(spiField.Field_Api_Name__c,spiField.Object_Label__c);
                    richTextMap.put(spiField.Field_Api_Name__c,spiField.Is_Rich_Text__c);
                }
            }
        }
        
        //Commenting out below lines because OpportunityDetail__c field is no longer being used.
        //Add Remarkds/Opportunity Detail as a special case for SF.COM
        //Temporary fix for Release2: Critical Defect fix: 19157
        //textAreaList.add('OpportunityDetail__c');
        //fieldLabelMap.put('OpportunityDetail__c','Opportunity Detail');
        //objectLabelMap.put('OpportunityDetail__c','Opportunity');
        //richTextMap.put('OpportunityDetail__c',false);   
    }
    
    /**
* @description This method transform and Simplified SObject field values for REGEX Pattern 
* @param textBody String 
* @param textAreaField String
* @return String - transformed textBody
* @throws None
*/     
    private String transformAndReturnSObjectFeildValue(String textBody,String textAreaField){
        String text = textBody;
        if(richTextMap.get(textAreaField)) {
            text=handleRichText(textBody);
        }
        return mergeTextOnNewLineAndCarriageReturnWithaSpace(text);
    }
    
    /**
* @description This method validate textfield value for SPI data and provide error message depends on SPI value
* @param textAreaField String 
* @param lineOfText String 
* @param mapOfPatternControls
* @return String - display ErrorMessage if SPI data found
* @throws None
*/        
    private String validateTextForSPIData(String textAreaField,String lineOfText,Map<Pattern,SPI_Security_Control__c> mapOfPatternControls){
        Matcher myMatcher;
        String errorMessage='';
        for(Pattern myPattern: mapOfPatternControls.keySet()) {
            myMatcher = myPattern.matcher(lineOfText);                                                                                                
            if(myMatcher.matches()) { 
                errorMessage=getDisplayErrorMessage(textAreaField,mapOfPatternControls.get(myPattern));
                break;
            }    
        }
        return errorMessage;
    }
    
    /**
* @description This method split the Text by CarriageReturn and New Line
* @param textBody String  FreeForm Text
* @return String - List of FreeForm Text after split by CarriageReturn and New Line
* @throws None
*/
    private String mergeTextOnNewLineAndCarriageReturnWithaSpace(String textBody) {
        String formattedText = textBody;
        formattedText = formattedText.replaceAll(UTIL_Constants.CARRIAGE_RETURN_AND_NEW_LINE,' ');
        formattedText = formattedText.replaceAll(UTIL_Constants.CARRIAGE_RETURN,' ');
        formattedText = formattedText.replaceAll(UTIL_Constants.NEW_LINE,' ');
        formattedText = formattedText.replaceAll(REGEX_TO_FILTER_HTML,' '); 
        formattedText = formattedText.replaceAll(UTIL_Constants.RICH_TEXT_SPLIT,' ');
       
        return formattedText ;
    }   
    
    /**
* @description This method replace the error to display
* @param textAreaField string FreeForm Text
* @param control SPI_Security_Control__c
* @return String - string of FreeForm Text after replacing the error message to display
* @throws None
*/    
    private String getDisplayErrorMessage(String textAreaField,SPI_Security_Control__c control){
        String error = '';
        String displayMessage='';
        
        error = control.Error_Message_Label__c.replace(UTIL_Constants.KEY_IDENTIFIER_OBJECT,objectLabelMap.get(textAreaField));
        
        if(fieldLabelMap.get(textAreaField) != null) {
            error = error.replace(UTIL_Constants.KEY_IDENTIFIER_FIELD,fieldLabelMap.get(textAreaField)); 
        } else {
            error = error.replace(' '+UTIL_Constants.KEY_IDENTIFIER_FIELD,'');    
        }
        
        String errorSplitText=getErrorSplitTextForSObject(objectLabelMap.get(textAreaField));
        error = error.replace(UTIL_Constants.KEY_IDENTIFIER_NAME, control.Name);
        displayMessage = displayMessage+  errorSplitText +error;
        return displayMessage;
    }
    
    /**
* @description This method construct Error display format depends on SObject
* @param sObjectName String  Object Names
* @return String - Formatted SplitText for Error Messages
* @throws None
*/    
    private String getErrorSplitTextForSObject(String sObjectName){
        String errorSplitText=UTIL_Constants.RICH_TEXT_NEW_LINE;
        if((UTIL_Constants.SOBJECTS_WITHOUT_RICH_TEXT_NEW_LINE_ERROR).contains(sObjectName)){
            errorSplitText=UTIL_Constants.NEW_LINE;
        }
        return errorSplitText;
    }
    
    /**
* @description This method replace the Rich Text by space and </p>
* @param textRichBody string  FreeForm Text
* @return String - string of FreeForm Text after replacing the Rich text fields 
* @throws None
*/  
    
    private String handleRichText(String textRichBody){
        String textRichBodyFormatted = textRichBody;
        textRichBodyFormatted = textRichBodyFormatted.replaceAll(UTIL_Constants.RICH_TEXT_SPACE,' '); 
        textRichBodyFormatted = textRichBodyFormatted.replaceAll(UTIL_Constants.RICH_TEXT_LIST, UTIL_Constants.RICH_TEXT_SPLIT); 
        return textRichBodyFormatted;
    }
    
    /**
* @description This method calculate the Number of Chunks depending on character of input string for various fields
* @param lineOfFullText String  Full Text
* @return Integer - Number of Chunks
* @throws None
*/     
    private Integer determineNumberOfChunks(String lineOfFullText){
        Integer numberOfChunk;
        numberOfChunk=lineOfFullText.length()/chunkSize;
        Integer isRemainingText=Math.Mod(lineOfFullText.length(),chunkSize);
        
        if (isRemainingText!=0){
            numberOfChunk=numberOfChunk+1;
        }
        return numberOfChunk;
    }
    
    /**
* @description This method traverse through the chunk size text and validate SPI data available on that Chunk or not
* @param lineOfFullText String  Full Text
* @param textAreaField Name of TextArea field
* @param numberOfChunk Number of Chunk 
* @param mapOfPatternControls Map<Pattern,SPI_Security_Control__c> 
* @return String - ErrorMessage
* @throws None
*/     
    private String traverseChunkDataAndValidateForSPI(String lineOfFullText, String textAreaField,  Integer numberOfChunk,Map<Pattern,SPI_Security_Control__c> mapOfPatternControls){
        Integer currentChunk;
        String errorMessage='';
        String lineOfFullTxt = lineOfFullText;
        for (currentChunk=1; currentChunk<=numberOfChunk; currentChunk++){
            String currentChunkContent=lineOfFullTxt.left(chunkSize); 
            errorMessage=validateTextForSPIData(textAreaField,currentChunkContent,mapOfPatternControls);
            if(String.isNotBlank(errorMessage)){
                break;
            }
            lineOfFullTxt=lineOfFullTxt.right(lineOfFullTxt.length()-chunkSize);
        }
        return errorMessage;
    }
    
    /**
* @description This method traverse through the edge of chunk size text (Depending on Custom Settings) and validate SPI data available on that Chunk or not
* @param lineOfPartialText String  Partial Text
* @param textAreaField Name of TextArea field
* @param numberOfChunk Error Message, Number of Chunk 
* @param mapOfPatternControls Map<Pattern,SPI_Security_Control__c> 
* @return String - ErrorMessage
* @throws None
*/     
    private String traverseEdgeChunkDataAndValidateForSPI(String lineOfPartialText, String textAreaField, Integer numberOfChunk,Map<Pattern,SPI_Security_Control__c> mapOfPatternControls) {
        Integer currentSmallChunk;
        String errorMessage='';
        String lineOfPartialTxt = lineOfPartialText;
        for (currentSmallChunk=1;currentSmallChunk<numberOfChunk;currentSmallChunk++){
            String currentSmallChunkContent=lineOfPartialTxt.left(smallChunkSize);
            errorMessage=validateTextForSPIData(textAreaField,currentSmallChunkContent,mapOfPatternControls);
            if(String.isNotBlank(errorMessage)){
                break;
            }            
            lineOfPartialTxt=lineOfPartialTxt.right(lineOfPartialTxt.length()-chunkSize);
        }
        return errorMessage;
    }
}