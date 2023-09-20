
const handleSubmit = async (campaignDetails, clientIdentifier_list) => {
    if (campaignDetails && clientIdentifier_list) {
        return true;
    }    
    return false;
}

export default handleSubmit