/**
 * @description AT_SpiFieldValidator
 */
public with sharing class AT_SpiFieldValidator {
    /**
* Author : Team Kraken
* Date Created : 9/5/2018
* Description : validates specific value for SPI
* Version : 1.12
*/
    
    public Static final String REGEX_TO_FILTER_HTML = '<[/a-zAZ0-9]*>';
    @TestVisible public static List<SPI_Security_Control__c> mocklist = new List<SPI_Security_Control__c>();
    
    private static final String CLASS_NAME='AT_SpiFieldValidator'; 
    
    private static Integer chunkSize;
    private static Integer smallChunkSize;
    private static Integer edgeChunkSize;
    
    /**
* @description This method prevents SPI for free formed text data
* @param fieldValue field value
* @return error message
*/
    @AuraEnabled
    public static String validate(String fieldValue) {
        String errorMessage = '';
        if (String.isBlank(fieldValue)) {
            return 'VALID';
        }
        
        List<SPI_Security_Control__c> securityControls = null;
        try {
            if (Test.isRunningTest()) {
                SPI_Security_Control__c spiControl = new SPI_Security_Control__c(
                    Active__c = true, 
                    Description__c = '', 
                    //Error_Message_Label__c ='Sensitive Personal Information (SPI) is not allowed to be entered in the {!object} {!field} field.',
                    Regex_Pattern__c = '^123-45-6789$',
                    //Regex_Pattern__c = '?\\:(?<!\\d)(?!000|666|9\\d{2})\\d{3}([-. ])(?!00)\\d{2}\\1(?!0000)\\d{4}(?![\\p{L}\\d-])',
                    //Regex_Pattern__c = '?:(?<!\d)(?!000|666|9\d{2})\d{3}([-. ])(?!00)\d{2}\1(?!0000)\d{4}(?![\p{L}\d-])', 
                    Name = 'US_SSN', 
                    Unique_Error_Message__c ='Sensitive Personal Information (SPI) is not allowed to be entered in the {!object} {!field} field.'
                );                    
                mockList.add(spiControl);
                securityControls = mockList;                
            }
            else {
                securityControls = Security.stripInaccessible(AccessType.READABLE, [SELECT Name, Regex_Pattern__c, Description__c, Error_Message_Label__c, Active__c FROM SPI_Security_Control__c WHERE Active__c = true]).getRecords();
            }
        }
        catch(Exception e){
            LoggingService.logHandledException(e, CLASS_NAME, 'validate', System.LoggingLevel.ERROR);
        }
        
        if(fieldValue.length() > 0 && securityControls!=null && !securityControls.isEmpty()) {
            if (Test.isRunningTest()) {
                chunkSize=150;
                smallChunkSize=50;
            } 
            else {
                chunkSize=Integer.valueOf(CS_SPI_Chunk_Text_Size__c.getInstance().SPI_Chunk_Size__c);
                smallChunkSize=Integer.valueOf(CS_SPI_Chunk_Text_Size__c.getInstance().SPI_Small_Chunk_Size__c);
            }    
            edgeChunkSize=chunkSize-smallChunkSize/2;            
            Map<Pattern,SPI_Security_Control__c> mapOfPatternControls=compileRegexPatterns(securityControls);
            HandleSObjectFieldDataForSPIWrapper handleWrap = new HandleSObjectFieldDataForSPIWrapper();
            handleWrap.mapOfPatternControls = mapOfPatternControls; 
            handleWrap.chunk_Size = chunkSize; 
            handleWrap.small_ChunkSize = smallChunkSize;
            errorMessage=handleSObjectFieldDataForSPI(fieldValue,errorMessage,handleWrap);
        }
        if ('INVALID'.equals(errorMessage)) {
            return errorMessage;
        }
        else {
            return 'VALID';
        }
    }
    
    private class HandleSObjectFieldDataForSPIWrapper{
        Map<Pattern,SPI_Security_Control__c> mapOfPatternControls; 
        Integer chunk_Size; 
        Integer small_ChunkSize;
    }

    /**
* @description This method Handle SObject Fields for SPI Data consists with small or long text
* @param lineOfFullText lineOfFullText,String textAreaField, Map<Pattern,SPI_Security_Control__c> mapOfPatternControls
* @param errorMessage
* @param handleSObject
* @return errorMessage
* @throws None
*/     
    private static String handleSObjectFieldDataForSPI(String lineOfFullText,String errorMessage, HandleSObjectFieldDataForSPIWrapper handleSObject){
        String tempErrorMessage='';
        if(lineOfFullText.length()>handleSObject.chunk_Size){
            String lineOfPartialText=lineOfFullText.right(lineOfFullText.length()- edgeChunkSize);
            Integer numberOfChunk= determineNumberOfChunks(lineOfFullText);
            TraverseChunkDataAndValidateForSPIWrapper traverseChunkWrap = new TraverseChunkDataAndValidateForSPIWrapper();
            traverseChunkWrap.lineOfFullText = lineOfFullText;
            traverseChunkWrap.numberOfChunk = numberOfChunk;
            tempErrorMessage=traverseChunkDataAndValidateForSPI(traverseChunkWrap,handleSObject.mapOfPatternControls,handleSObject.chunk_Size);
            if (String.isBlank(tempErrorMessage)){
                TraverseEdgeChunkDataAndValidateForSPIWrapper traverseEdgeWrap = new TraverseEdgeChunkDataAndValidateForSPIWrapper();
                traverseEdgeWrap.lineOfPartialText = lineOfPartialText;
                traverseEdgeWrap.numberOfChunk = numberOfChunk;
                traverseEdgeWrap.mapOfPatternControls = handleSObject.mapOfPatternControls;
                traverseEdgeWrap.smallChunkSize = handleSObject.small_ChunkSize;
                tempErrorMessage=traverseEdgeChunkDataAndValidateForSPI(traverseEdgeWrap);
            }
        }else{
            tempErrorMessage=validateTextForSPIData(lineOfFullText,handleSObject.mapOfPatternControls);
        }
        return errorMessage+tempErrorMessage;
    }
    
    /**
* @description compileRegexPatterns This method compile REGEX pattern according to Controls in Custom Setting
* @param  securityControls
* @return Map<Pattern,SPI_Security_Control__c> Map of Compiled Pattern and Control
* @throws None
*/    
    
    private static Map<Pattern,SPI_Security_Control__c> compileRegexPatterns(List<SPI_Security_Control__c> securityControls){
        Map<Pattern,SPI_Security_Control__c> mapOfPatternControls=new Map<Pattern,SPI_Security_Control__c>();
        for(SPI_Security_Control__c control: securityControls) {
            String tempRegex = UTIL_Constants.REGEX_BEGIN_OF_LINE_WILD_CARD + control.Regex_Pattern__c + UTIL_Constants.REGEX_END_OF_LINE_WILD_CARD;                                                                                                   
            Pattern myPattern = Pattern.compile(tempRegex);   
            mapOfPatternControls.put(myPattern, control);
        }
        return mapOfPatternControls;
    }
    
    
    
    /**
* @description This method validate textfield value for SPI data and provide error message depends on SPI value
* @param lineOfText  textAreaField and String lineOfText
* @param mapOfPatternControls
* @return String display ErrorMessage if SPI data found
* @throws None
*/        
    private static String validateTextForSPIData(String lineOfText,Map<Pattern,SPI_Security_Control__c> mapOfPatternControls){
        Matcher myMatcher;
        String errorMessage='';
        for(Pattern myPattern: mapOfPatternControls.keySet()) {
            myMatcher = myPattern.matcher(lineOfText);                                                                                                
            if(myMatcher.matches()) { 
                errorMessage='INVALID';
                break;
            }    
        }
        return errorMessage;
    }
    
    
    
    /**
* @description This method calculate the Number of Chunks depending on character of input string for various fields
* @param lineOfFullText  Full Text
* @return Integer Number of Chunks
* @throws None
*/     
    private static Integer determineNumberOfChunks(String lineOfFullText){
        Integer numberOfChunk;
        numberOfChunk=lineOfFullText.length()/chunkSize;
        Integer isRemainingText=Math.Mod(lineOfFullText.length(),chunkSize);
        
        if (isRemainingText!=0){
            numberOfChunk=numberOfChunk+1;
        }
        return numberOfChunk;
    }
    
    private class TraverseChunkDataAndValidateForSPIWrapper{
        String lineOfFullText;  
        Integer numberOfChunk;
    }

    /**
* @description This method traverse through the chunk size text and validate SPI data available on that Chunk or not
* @param traverseChunk Full Text, Name of TextArea field, Error Message, Number of Chunk , Map<Pattern,SPI_Security_Control__c> mapOfPatternControls
* @param mapOfPatternControls
* @param chunkSize
* @return String ErrorMessage
* @throws None
*/     
    private static String traverseChunkDataAndValidateForSPI(TraverseChunkDataAndValidateForSPIWrapper traverseChunk,Map<Pattern,SPI_Security_Control__c> mapOfPatternControls,Integer chunkSize){
        Integer currentChunk;
        String errorMessage='';
        for (currentChunk=1; currentChunk<=traverseChunk.numberOfChunk; currentChunk++){
            String currentChunkContent=traverseChunk.lineOfFullText.left(chunkSize); 
            errorMessage=validateTextForSPIData(currentChunkContent,mapOfPatternControls);
            if(String.isNotBlank(errorMessage)){
                break;
            }
            traverseChunk.lineOfFullText=traverseChunk.lineOfFullText.right(traverseChunk.lineOfFullText.length()-chunkSize);
        }
        return errorMessage;
    }

    private class TraverseEdgeChunkDataAndValidateForSPIWrapper{
        String lineOfPartialText;
        Integer numberOfChunk;
        Map<Pattern,SPI_Security_Control__c> mapOfPatternControls;
        Integer smallChunkSize;
    }

    /**
* @description This method traverse through the edge of chunk size text (Depending on Custom Settings) and validate SPI data available on that Chunk or not
* @param traverseEdge  Partial Text, Name of TextArea field, Error Message, Number of Chunk , Map<Pattern,SPI_Security_Control__c> mapOfPatternControls
* @return String ErrorMessage
* @throws None
*/     
    private static String traverseEdgeChunkDataAndValidateForSPI(TraverseEdgeChunkDataAndValidateForSPIWrapper traverseEdge) {
        Integer currentSmallChunk;
        String errorMessage='';
        for (currentSmallChunk=1;currentSmallChunk<traverseEdge.numberOfChunk;currentSmallChunk++){
            String currentSmallChunkContent=traverseEdge.lineOfPartialText.left(traverseEdge.smallChunkSize);
            errorMessage=validateTextForSPIData(currentSmallChunkContent,traverseEdge.mapOfPatternControls);
            if(String.isNotBlank(errorMessage)){
                break;
            }
            traverseEdge.lineOfPartialText=traverseEdge.lineOfPartialText.right(traverseEdge.lineOfPartialText.length()-chunkSize);
        }
        return errorMessage;
    }
    
}