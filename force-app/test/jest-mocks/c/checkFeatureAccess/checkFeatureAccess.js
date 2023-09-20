import 'c/checkBrowser';
import getFeatureAccessMetadataForUserType from '@salesforce/apex/AP_FeatureAccess.getFeatureAccessMetadataForUserType';
import getFeatureAccessMetadataForSubuserType from '@salesforce/apex/AP_FeatureAccess.getFeatureAccessMetadataForSubuserType';
import getFeatureAccessMetadataForUserCriteria from '@salesforce/apex/AP_FeatureAccess.getFeatureAccessMetadataForUserCriteria';

export const getFeatureAccessMetadataByUserType = (featureName) =>{
    return getFeatureAccessMetadataForUserType({featureName: featureName}).then(
        (data) => {
            if (data != null) {
                return JSON.parse(data);
            }
            return null;
        }
    );
    
}

export const getFeatureAccessMetadataBySubuserType = (featureName) => {
    return getFeatureAccessMetadataForSubuserType({featureName: featureName}).then(
        (data) => {
            if (data != null) {
                return JSON.parse(data);
            }
            return null;
        }
    );
    
}

export const getFeatureAccessMetadataByUserCriteria = (featureName) =>{
    return getFeatureAccessMetadataForUserCriteria({featureName: featureName}).then(
        (data) => {
            if (data != null) {
                let permissions = {};
                data.forEach(element => {
                    permissions = {...permissions, ...JSON.parse(element)};
                });
                return permissions;
            }
            return null;
        }
    );
    
}