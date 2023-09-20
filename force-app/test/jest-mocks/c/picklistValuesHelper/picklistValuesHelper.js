import  getpicklistValues  from '@salesforce/apex/PicklistController.getActivePicklistValues';

export default async function getPicklistValuesHelper(helperOptions) {

    const allPicklistValues = await getpicklistValues({objectName: helperOptions.objectName, 
                                                fieldName: helperOptions.fieldName});

    sortPicklistValues(allPicklistValues, helperOptions.sort);

    const filteredPicklistValues = filterPicklistValues(allPicklistValues, helperOptions.filterValues);

    return {
        helperOptions: helperOptions,
        allPicklistValues: allPicklistValues,
        filteredPicklistValues: filteredPicklistValues,
        filteredPicklistValuesAsOptionList: () => {
            return convertToOptionFormat(filteredPicklistValues); 
        }
    }
}

function sortPicklistValues(allPicklistValues, sort) {
    if(sort) {
        allPicklistValues.sort();
    }
}

function filterPicklistValues(allPicklistValues, filterValues) {
    if (!filterValues) {
        return allPicklistValues;
    }

    const filteredPicklistValues = [];
    allPicklistValues.forEach(element => {
        if (!filterValues.includes(element)) {
            filteredPicklistValues.push(element);
        }
    });
    
    return filteredPicklistValues;
}

function convertToOptionFormat(picklistValues) {
    const options = [];
    picklistValues.forEach(element => {
        options.push({label: element, value: element});
    })

    return options;
}