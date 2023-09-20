public with sharing class DVPremiumChangeResponse {
    
    @TestVisible private List<Object> discRemoved ;
    @TestVisible private List<Object> discChanged ;
    @TestVisible private Boolean dss1;
    @TestVisible private Boolean dss2 ;
    @TestVisible private Boolean dss3 ;
    @TestVisible private Boolean isWA ;
    @TestVisible private Boolean isNY ;
    @TestVisible private Boolean isOther ;

    public List<Object> vehicleName {get; set;}
    public List<Object> ratingChanges {get; set;}
    public List<Object> mileageChanged {get; set;}
    public List<Object> premiumChangeStatement {get; set;}
    //String premiumChangeStatement;
    public Boolean noPremiumChange {get; set;}

    @TestVisible
    public void setDiscRemoved(List<Object> arrDiscRemoved){
        if (arrDiscRemoved.size() > 0){
            discRemoved = arrDiscRemoved;
        } else {
            discRemoved = null;
        }
    }

    @TestVisible
    public void setDiscChanged(List<Object> arrDiscChanged){
        if (arrDiscChanged.size() > 0){
            discChanged = arrDiscChanged;
        } else {
            discChanged = null;
        }
    }


    @TestVisible
    public void setDSS(String dssiValue){
        if (dssiValue == 'DSS1'){
            dss1 = true;
        } else if (dssiValue == 'DSS2'){
            dss2 = true;
        } else if (dssiValue == 'DSS3'){
            dss3 = true;
        }
    }

    @TestVisible
    public void setStateDSSMessage(String stateCode){
        if (stateCode == '47') {
            isWA = true; 
        } else if (stateCode == '32' || stateCode == '52'  ) {
            isNY = true; 
        } else {
            isOther = true;
        }
    }
}