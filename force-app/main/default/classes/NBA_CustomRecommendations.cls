/**
* @name NBA_CustomRecommendations
* @author Team Skynet
* @createDate 03/24/2022
* @description This Apex class is invoked by NBA Recommendation Strategy flow to retrieve recommendations
*/
public with sharing class NBA_CustomRecommendations {

    private static final String STATUS_NEW = 'New';

    @TestVisible private NBA_CustomRecommendations(){}

    /**
    * @name: FlowInputs
    * @description Input class for the getSFCustomRecommendations method
    */
    public with sharing class FlowInputs{

        @InvocableVariable (label='Record ID' description='Record Id')
        public String recordId;

    }


    /**
    * @name: getSFCustomRecommendations
    * @description Get Custom Recommendations, map it and send it back to flow
    * @param flowInputs
    * @return recommendation List
    */
    @InvocableMethod(label ='NBA Custom Recommendations' description='NBA Custom Recommendations')
    public static List<List<Recommendation>> getSFCustomRecommendations(List<FlowInputs> flowInputs){

        List<List<Recommendation>> outputs = new List<List<Recommendation>>();
        String recordId = flowInputs.get(0).recordId;

        List<SFCustomRecommendation__c> sfCustomRecommendations =
            Security.stripInaccessible(AccessType.READABLE,[SELECT Id, Action_ID__c,
                                        Recommendation__r.id, Recommendation__r.Name, Recommendation__r.Description, Recommendation__r.Action_Description__c,
                                        Recommendation__r.ActionReference, Recommendation__r.AcceptanceLabel, Recommendation__r.RejectionLabel,
                                        Recommendation__r.Action_ID__c, Recommendation__r.ImageId, Recommendation__r.LineOfBusiness__c,
                                        Recommendation__r.Group__c, Recommendation__r.Issue__c
                                        FROM SFCustomRecommendation__c
                                        WHERE Status__c = :STATUS_NEW
                                        AND Account__c = :recordId
                                        ORDER BY Rank__c]).getRecords();


        List<Recommendation> recs = new List<Recommendation>();
        for (SFCustomRecommendation__c sfRec:sfCustomRecommendations) {
            Recommendation rec = new Recommendation();
            rec.id = sfRec.Recommendation__r.id;
            rec.Name = sfRec.Recommendation__r.Name;
            rec.Description = sfRec.Recommendation__r.Description;
            rec.Action_Description__c =  sfRec.Recommendation__r.Action_Description__c;
            rec.ActionReference = sfRec.Recommendation__r.ActionReference;
            rec.AcceptanceLabel = sfRec.Recommendation__r.AcceptanceLabel;
            rec.RejectionLabel = sfRec.Recommendation__r.RejectionLabel;
            rec.Action_ID__c = sfRec.Recommendation__r.Action_ID__c;
            rec.LineOfBusiness__c = sfRec.Recommendation__r.LineOfBusiness__c;
            rec.Group__c =  sfRec.Recommendation__r.Group__c;
            rec.Issue__c =  sfRec.Recommendation__r.Issue__c;
            rec.Source_Record_Id__c = sfRec.Id;
            recs.add(rec);
        }

        outputs.add(recs);
        return outputs;
    }

}