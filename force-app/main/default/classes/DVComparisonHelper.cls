public class DVComparisonHelper {

    

    //Determines if the premium has increased or decreased
    //@param total - total premium change from the comparision
    //@param percent - percentage change from comparision
    //
    //@return a string stating whether the premium has increased or decreased
    public static String findPremChange(Double callOneTotal, Double  callTwoTotal, String lob){
        String response;
        Decimal totalPremiumChange;
        Decimal premPercent;
        if(callOneTotal != NULL && callTwoTotal != NULL){
            totalPremiumChange = callTwoTotal - callOneTotal;
            premPercent = Math.abs(totalPremiumChange/callOneTotal) * 100;
        }
        if(totalPremiumChange < 0){
            if (lob.toUpperCase() == 'A') {
                response = 'The premium for this vehicle decreased by $' + Math.abs(totalPremiumChange).setScale(2) + '.  This represents a premium decrease of ' + premPercent.round(System.RoundingMode.HALF_UP) + '%.  This review did not include accident surcharge or coverage changes.';
            } else {
                response = 'The premium for this policy decreased by $' + Math.abs(totalPremiumChange).setScale(2) + '.  This represents a premium decrease of ' + premPercent.round(System.RoundingMode.HALF_UP) + '%.  This review did not include discount or coverage changes.';
            }
            
        }else if(totalPremiumChange > 0){
            if (lob.toUpperCase() == 'A') { 
                response = 'The premium for this vehicle increased by $' + Math.abs(totalPremiumChange).setScale(2) + '.  This represents a premium increase of ' + premPercent.round(System.RoundingMode.HALF_UP) + '%.  This review did not include accident surcharge or coverage changes.';
            } else {
                response = 'The premium for this policy increased by $' + Math.abs(totalPremiumChange).setScale(2) + '.  This represents a premium increase of ' + premPercent.round(System.RoundingMode.HALF_UP) + '%.  This review did not include discount or coverage changes.';
            }
            
        }else{
            response = 'The premium did not change at renewal';
        }
        //response = response + ' *** callOneTotal=' + callOneTotal + ' *** callTwoTotal=' + callTwoTotal;
        return response;
    }

    //Determines if the policy had multiple vehicles and then finds the location of the matching vehicle
    //@param res1 - Vehicle we are looking for
    //@param res2 - Insurance policy we are looping through to find matching vehicle
    //
    //@return a string concatenation of both the location of the vehicle and the year/make/model of the matching vehicle 
    public static String findMatchingVehicle(ExternalService.PolicyRetrievalAPI_InsurableRisk res1, ExternalService.PolicyRetrievalAPI_TermVersion res2){
        String responseString = '';
        if(res1.vehicle.size()>1){
            for(Integer i = 0; i<res2.insurableRisk.size();i++){
                if(res1.vehicle[0] == res2.insurableRisk[i].vehicle[0]){
                    String yearMakeModel = res1.vehicle[0].modelYearNumber + res1.vehicle[0].makeName + res1.vehicle[0].modelName;
                    responseString = i + yearMakeModel;
                }
            }
        } 
        return responseString;
    }

    //Compares the vehicle stats to determine if there have been changes
    //@param initVehicle - vehicle stats we are comparing against
    //@param compVehicle - new vehicle that we are comparing
    //
    //@return a list of the vehicle stats that changed
    public static List<String> compareVehicles(ExternalService.PolicyRetrievalAPI_Vehicle initVehicle,ExternalService.PolicyRetrievalAPI_Vehicle compVehicle){
        List<String> responseList = new List<String>();
        List<String> tempList = new List<String>();
        
        tempList.add(policyCodeComparision(initVehicle.irgComprehensiveCode,compVehicle.irgComprehensiveCode,'DRG'));
        tempList.add(policyCodeComparision(initVehicle.irgCollisionCode,compVehicle.irgCollisionCode,'GRG'));
        tempList.add(policyCodeComparision(initVehicle.liabilityRatingGroupCode,compVehicle.liabilityRatingGroupCode,'LRG'));

       
        for(String str : tempList){
            if(str != ''){
                responseList.add(str);
            }
        }
        return responseList;
    }

    //Annual Mileage between estAnnualDistanceDrivenCount and telematicsDriveSafeAndSaveCalculatedAnnualMileageCount based on non-DSSI vs DSSI display
    //@param initVehicle - vehicle stats we are comparing against
    //@param compVehicle - new vehicle that we are comparing
    //
    //@return Annual Mileage Verbiage
    public static List<String> compareAnnualMileageOfVehicles(ExternalService.PolicyRetrievalAPI_Vehicle initVehicle,ExternalService.PolicyRetrievalAPI_Vehicle compVehicle){
        List<String> responseList = new List<String>();
        List<String> tempList = new List<String>();
        if (initVehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount != null && initVehicle.driveSafeAndSaveIndexScaleCount != null) {
            tempList.add(annualMileageComparision(Integer.valueOf(initVehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount.replaceAll(',','')),Integer.valueOf(compVehicle.telematicsDriveSafeAndSaveCalculatedAnnualMileageCount.replaceAll(',',''))));
        } else {
            tempList.add(annualMileageComparision(initVehicle.vehicleUsage.estAnnualDistanceDrivenCount,compVehicle.vehicleUsage.estAnnualDistanceDrivenCount));
        }
        
        for(String str : tempList){
            if(str != ''){
                responseList.add(str);
            }
        }
        return responseList;
    }



    public static String policyCodeComparision(String initCode,String compCode,String codeType){
        String policyCodeComp = '';
        

        if(initCode != NULL && compCode != NULL && initCode != compCode){
            policyCodeComp = 'The vehicle rating changed from ' + codeType + ' ' + String.valueOf(removeChar(initCode,0)).leftPad(3, '0') + ' to ' + codeType + ' ' + String.valueOf(removeChar(compCode,0)).leftPad(3, '0');
        }
        return policyCodeComp;
    }

    public static String annualMileageComparision(Integer initDistance,Integer compDistance){
        String distanceComp = '';
        if(initDistance != NULL && compDistance != NULL && initDistance != compDistance){
            distanceComp = 'Annual Mileage changed from ' + initDistance +' to ' + compDistance;
        }
        return distanceComp;
    }

  
    
    //Used to remove index charactors from source string
    //@param source - string that you are looking to remove charactors from
    //@param index - index that you are trying to remove charactors from
    //
    //@return original string without the characters that were removed
    public static string removeChar(String source, Integer index) {
        return source.left(index)+source.right(source.length()-index-1);
    }

    public static String compareCRI(Integer criOriginal,Integer criNew){
        String strCRIDesc = '';

        if (criOriginal != NULL && criNew != NULL && criOriginal != criNew && criOriginal < criNew) {
            strCRIDesc = 'CRI Increased';
        }
        if (criOriginal != NULL && criNew != NULL && criOriginal != criNew && criOriginal > criNew) {
            strCRIDesc = 'CRI Decreased';
        }
       
        return strCRIDesc;
    }

    
}