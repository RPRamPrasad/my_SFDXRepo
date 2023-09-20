export const getActivePageData = (activePage, maxPerPage, allData) => {
    // Get our current position in the list
    const first = (activePage - 1) * maxPerPage;
       
    // Get our last position in the list
    const last = first + maxPerPage;

    return allData.slice(first, last);
}