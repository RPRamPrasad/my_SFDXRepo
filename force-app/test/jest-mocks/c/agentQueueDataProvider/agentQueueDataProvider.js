const salesWorkItems = [
    {
        Item: {
            Id: 'ABCDEF111222333444',
            Assigned_To__r: {
                Id: '000111222333444555',
                Name: 'John Smith'
            },
            Account: {
                FirstName: 'Joe',
                LastName: 'Shmoe'
            },
            dueDate: '12-20-2022',
            LOB__c: 'Auto',
            Opportunity_Originator__c: "Agent/Team Member",
            StageName: 'Assigned',
            Name: "Auto-JOE SHMOE",
            Duration_of_Opportunity__c: 90,
            Tasks: [
                {
                    ActivityDate: "2022-12-20",
                    AssignedTo__c: "005888999000ABCDEF",
                    AssignedTo__r: {
                        Id: "005888999000ABCDEF",
                        Name: "Test User"
                    },
                    Id: "000111222333ABCDEF",
                    Subject: "Test Task"
                },
                {
                    ActivityDate: "2025-08-20",
                    AssignedTo__c: "005888999000ABCDEF",
                    AssignedTo__r: {
                        Id: "005888999000ABCDEF",
                        Name: "Test User"
                    },
                    Id: "000111222333ABCDEF",
                    Subject: "Test Task"
                },
                {
                    ActivityDate: "2022-12-20",
                    AssignedTo__c: "005888999000ABCDEF",
                    AssignedTo__r: {
                        Id: "005888999000ABCDEF",
                        Name: "Test User"
                    },
                    Id: "000111222333ABCDEF",
                    Subject: "Test Task"
                },
                {
                    ActivityDate: "2022-12-20",
                    AssignedTo__c: "005888999000ABCDEF",
                    AssignedTo__r: {
                        Id: "005888999000ABCDEF",
                        Name: "Test User"
                    },
                    Id: "000111222333ABCDEF",
                    Subject: "Test Task"
                }
            ]
        },
        ItemType: 'Opportunity',
        ItemSize: 1
    },{
        Item: {
            Id: 'ABCDEF111222333445',
            Assigned_To__r: {
                Id: '000111222333444555',
                Name: 'John Smith'
            },
            Account: {
                FirstName: 'Joe',
                LastName: 'Shmoe'
            },
            dueDate: '12-10-2022',
            LOB__c: 'Auto',
            Opportunity_Originator__c: "Agent/Team Member",
            StageName: 'Assigned',
            Name: "Auto-JOE SHMOE",
            Duration_of_Opportunity__c: 1
        },
        ItemType: 'Opportunity',
        ItemSize: 1
    },{
        Item: {
            Id: 'ABCDEF111222333446',
            AssignedTo__r: {
                Id: '000111222333444555',
                Name: 'John Smith'
            },
            dueDate: '12-22-2021',
            LeadSource: "Non-Customer Referral",
            Submitted_First_Name__c: "Joe",
            Submitted_Last_Name__c: "Shmoe",
            Name: "Joe Shmoe LEAD",
            DaysOpen__c: 2,
            Tasks: [
                {
                    ActivityDate: "2022-12-10",
                    AssignedTo__c: "005888999000ABCDEF",
                    AssignedTo__r: {
                        Id: "005888999000ABCDEF",
                        Name: "Test User"
                    },
                    Id: "000111222333ABCDEF",
                    Subject: "Test Task"
                },                
                {
                    ActivityDate: "2022-12-10",
                    AssignedTo__c: "005888999000ABCDEF",
                    AssignedTo__r: {
                        Id: "005888999000ABCDEF",
                        Name: "Test User"
                    },
                    Id: "000111222333ABCDEF",
                    Subject: "Test Task"
                },                
                {
                    ActivityDate: "2022-12-10",
                    AssignedTo__c: "005888999000ABCDEF",
                    AssignedTo__r: {
                        Id: "005888999000ABCDEF",
                        Name: "Test User"
                    },
                    Id: "000111222333ABCDEF",
                    Subject: "Test Task"
                },
                {
                    ActivityDate: "2022-12-10",
                    AssignedTo__c: "005888999000ABCDEF",
                    AssignedTo__r: {
                        Id: "005888999000ABCDEF",
                        Name: "Test User"
                    },
                    Id: "000111222333ABCDEF",
                    Subject: "Test Task"
                }
            ]
        },
        ItemType: 'Lead',
        ItemSize: 1
    },{
        Item: {
            Id: 'ABCDEF111222333447',
            AssignedTo__r: {
                Id: '000111222333444555',
                Name: 'John Smith'
            },
            dueDate: '12-23-2021',
            LeadSource: "Non-Customer Referral",
            Submitted_First_Name__c: "Joe",
            Submitted_Last_Name__c: "Shmoe",
            Name: "Joe Shmoe LEAD",
            DaysOpen__c: 1
        },
        ItemType: 'Lead',
        ItemSize: 1
    }
]

const mockGetSalesWorkItems = jest.fn().mockImplementation(
    async function() { return Promise.resolve(salesWorkItems)}
)

const getSalesWorkItems = jest.fn().mockImplementation(mockGetSalesWorkItems)

export  {
    getSalesWorkItems,
    mockGetSalesWorkItems,
    salesWorkItems
}