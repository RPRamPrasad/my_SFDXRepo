/** 
* @name TaskPremiumIncreaseHandler
* @description Intended to be called from Task Before Insert Trigger.
*/
public with sharing class TaskPremiumIncreaseHandler {
    /**
     * @name handlePremiumIncrease
     * @description Intended to be called from Before Insert trigger on the task object to flag tasks related to premium rate increases.
     * @param newTaskList
     */
    public static void handlePremiumIncrease(List<Task> newTaskList) {
        for(Task taskRecord : newTaskList) {
            // Check if AppCode__c meets criteria for task related to premium increase.
            if('BOD - Auto Extracts'.equals(taskRecord.AppCode__c) && 'BOD Premium Increase'.equals(taskRecord.Subject)) {
                // Build Regex to match $ amount and % rate change from Task 'Comments'
                String matchString = '\\$\\d+(?:\\.\\d+)?|\\b\\d+(?:%|percent\\b)';
                Pattern myPattern = Pattern.compile(matchString);
                Matcher myMatcher = myPattern.matcher(taskRecord.Description);

                // If there was no match, update only the subject and continue to the next Task.
                if(!myMatcher.find()) {
                    taskRecord.PremiumChangeDescription__c = taskRecord.Subject;
                    continue;
                }

                // If there was a match try to get both values and build copy original subject line.
                try {
                    String dollarAmount = myMatcher.group();
                    dollarAmount = dollarAmount.replace('$', '');

                    myMatcher.find();
                    String percentageAmount = myMatcher.group();
                    percentageAmount = percentageAmount.replace('%', '');

                    // Calculate original price from extracted data.
                    Decimal changeAmount = Decimal.valueOf(dollarAmount);
                    Decimal changeRate = Decimal.valueOf(percentageAmount);

                    taskRecord.PremiumChangeDescription__c = taskRecord.Subject;
                    taskRecord.PremiumChangeAmount__c = changeAmount;
                    taskRecord.PremiumChangeRate__c = changeRate;
                }
                // Exception is thrown when group() call fails, meaning partial match.
                catch(System.StringException e) {
                    taskRecord.PremiumChangeDescription__c = taskRecord.Subject;
                }
            }
        }
    }
}