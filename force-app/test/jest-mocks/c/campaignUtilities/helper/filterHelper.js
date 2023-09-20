import { getCampaignFilter, setCampaignFilter } from '../cache/localStorageUtility'; 
import currentUserId from '@salesforce/user/Id';

const VERSION = 'v1.1';

const createMyCampaignMembersFilter = () => {
    return {
        enable: true,
        filterFieldName: 'AssignedTo__c',
        filterValues: [currentUserId],
        queryNullValues: false,
        filterType: 'LIST_OF_STRING'
    };
}
const phoneNumberOnlyFilter = () => {
    return {
        enable:true,
        filterType:"BOOLEAN",
        filterFieldName:"HasPhoneNumber__c",
        filterValue:true,
        queryNullValues:false
    }
}

const createCampaignFilter = (campaignId) => {
    return {
        enable: true,
        filterFieldName: 'CampaignId',
        filterValues: [campaignId],
        queryNullValues: false,
        filterType: 'LIST_OF_STRING'
    };
}

const getDefaultFilter = (campaignId, assignedToCounts) => {
    const filters = [createCampaignFilter(campaignId)];
    let filterDisplayString = 'Phone Numbers Only'
    filters.push(phoneNumberOnlyFilter());

    if (assignedToCounts.result.some(item => item.Id === currentUserId)) {
        filters.push(createMyCampaignMembersFilter());
        filterDisplayString = 'My Campaign Members | Phone Numbers Only'
    } 

    return {
        filters: filters,
        filterDisplayString: filterDisplayString
    }
};

const getInitialCampaignFilter = (campaignId, assignedToCounts, agentOffice) => {
    const cachedFilters = getCampaignFilter(currentUserId, campaignId, VERSION);
    if (cachedFilters) {
        const assignedToFilterInCache = cachedFilters.filters.map( f => f.filterFieldName).find(fieldName => fieldName === 'AssignedTo__c');

        if (assignedToFilterInCache) {
          const assignedToFilterInCacheIndex = cachedFilters.filters.map( f => f.filterFieldName).indexOf('AssignedTo__c');
          const agentOfficeMembers = agentOffice.map(member => member.Id);
          const assignedToIdsInFilterCache = cachedFilters.filters[assignedToFilterInCacheIndex].filterValues.filter(value => value !== "");          
          const inactiveAssignToCacheId = assignedToIdsInFilterCache.find( item => !agentOfficeMembers.includes(item)); 

          if (inactiveAssignToCacheId) {
            let newCacheFilter = getDefaultFilter(campaignId, assignedToCounts);
            setCampaignFilter(currentUserId,campaignId, newCacheFilter,VERSION);
            newCacheFilter.showToast = true;
            return newCacheFilter;
          }          
        } 
      
        return {
            filters: cachedFilters.filters,
            filterDisplayString: cachedFilters.filterDisplayString
        }
    }

    return getDefaultFilter(campaignId, assignedToCounts);

}

const saveFilter = (campaignId, filters) => {
    setCampaignFilter(currentUserId, campaignId, filters, VERSION);
}

const setLockedFilter = (filterDisplayString, campaignMembers) => {
    return {
        filters: [{
            enable: true,
            filterType: 'LIST_OF_STRING',
            filterFieldName: 'Id',
            filterValues: campaignMembers.map(member => member.Id),
            queryNullValues: false
        }],
        filterDisplayString: filterDisplayString
    }
}

export {
    getInitialCampaignFilter,
    getDefaultFilter,
    saveFilter,
    setLockedFilter
};