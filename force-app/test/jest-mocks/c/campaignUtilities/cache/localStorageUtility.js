const LOCAL_STORAGE_KEY = 'User_Campaign_Preferences';
const FILTER_TIME_TO_LIVE_IN_DAYS = 7;

export function getCampaignFilter(userId, campaignId, version){
    return getStorageItem(userId,campaignId,version,'filter');
}
export function getCampaignCurrentPage(userId, campaignId, version){
    return getStorageItem(userId,campaignId,version,'currentPage');
}
function getStorageItem(userId, campaignId, version,itemName) {
    const storageKey = buildStorageKey(userId, campaignId);
    const campaignLocalStorage = getLocalStorage();

    if (!campaignLocalStorage) {
       return undefined;
    } 
    
    deleteExpiredFilters(campaignLocalStorage);
    
    const thisCampaignLocalStorageItem = campaignLocalStorage.filter(item => item.storageKey === storageKey 
                                                                             && new Date(item.expireDate) > new Date() 
                                                                             && item.version === version)[0];

    if (thisCampaignLocalStorageItem) {
        thisCampaignLocalStorageItem.expireDate = calculateExpireDate();
        setLocalStorage(campaignLocalStorage);
        
        return thisCampaignLocalStorageItem[itemName];
    } 
    
    return undefined;
}

export function setCampaignCurrentPage(userId,campaignId,filter,version){
    setStorageItem(userId,campaignId,filter,version,'currentPage');
}
export function setCampaignFilter(userId,campaignId,filter,version){
    setStorageItem(userId,campaignId,filter,version,'filter');
}
function setStorageItem(userId, campaignId, itemValue, version, itemName) {
    const storageKey = buildStorageKey(userId, campaignId);
    var holder;
    let campaignLocalStorage = getLocalStorage();

    if (!campaignLocalStorage) {
       campaignLocalStorage = [];
    } 
        
    const thisCampaignLocalStorageItem = campaignLocalStorage.filter(item => item.storageKey === storageKey)[0];
    
    const expireDate = calculateExpireDate();

    if (thisCampaignLocalStorageItem) {
        thisCampaignLocalStorageItem.version = version;
        thisCampaignLocalStorageItem[itemName] = itemValue;
        thisCampaignLocalStorageItem.expireDate = expireDate
    } else {
        holder = {
            version: version,
            storageKey: storageKey,
            expireDate: expireDate
        };
        holder[itemName] = itemValue
        campaignLocalStorage.push(holder);

    }

    setLocalStorage(campaignLocalStorage);
}



function calculateExpireDate() {
    const expireDate = new Date();
    expireDate.setDate(expireDate.getDate() + FILTER_TIME_TO_LIVE_IN_DAYS);

    return expireDate;
}

function buildStorageKey(userId, campaignId) {
    return `${userId}_${campaignId}`;
}

function getLocalStorage() {
    return JSON.parse(localStorage.getItem(LOCAL_STORAGE_KEY));
}

function setLocalStorage(campaignLocalStorage) {
    localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(campaignLocalStorage));
}

function deleteExpiredFilters(campaignLocalStorage) {
    campaignLocalStorage = campaignLocalStorage.filter(item => new Date(item.expireDate) > new Date());
    setLocalStorage(campaignLocalStorage);
}