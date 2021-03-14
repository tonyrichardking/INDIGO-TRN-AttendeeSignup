@isTest
private class INDIGO_TRN_AppTestClasses
{
    // --------------------------------------------------------------------------------
    // Contacts
    @isTest static void getContactForIdTest() 
    {
        Contact newContact = new Contact
        (
            Lastname = 'TestLastName',
            Email = 'test@test.com'
        );
        insert newContact;
        string newContactId = newContact.Id;

        Test.starttest();        

        Contact readContact = INDIGO_TRN_AppController.GetContactForId(newContactId);

        Test.stoptest();
    }

    @isTest static void ensureContactTest() 
    {
        Test.starttest();

        Contact contact = INDIGO_TRN_AppController.EnsureContact('TestFirstName', 'TestLastName', 'test@test.com', true, true );

        Test.stoptest();
    }

    // --------------------------------------------------------------------------------
    // Volunteer Hours
    @isTest static void EnsureVolHoursForJobTest() 
    {
        Campaign newCampaign = new Campaign
        (
            Name = 'Test Campaign Name'
        );
        insert(newCampaign);
        string newCampaignId = newCampaign.Id;

        GW_Volunteers__Volunteer_Job__c newJob = new GW_Volunteers__Volunteer_Job__c
        (
            Name = 'TestJob',
            GW_Volunteers__Campaign__c = newCampaignId
        );

        insert newJob;

        Contact newContact = new Contact
        (
            Lastname = 'TestLastName',
            Email = 'test@test.com'
        );
        insert newContact;
        string newContactId = newContact.Id;

        Test.starttest();

        GW_Volunteers__Volunteer_Hours__c volHours = INDIGO_TRN_AppController.EnsureVolHoursForJob(newContactId, 'TestJob');

        Test.stoptest();
    }    

    // --------------------------------------------------------------------------------
    // Campaigns
    @isTest static void ReadCampaignForNameTest() 
    {
        Campaign newCampaign = new Campaign
        (
            Name = 'Test Campaign Name'
        );
        insert(newCampaign);

        Test.starttest();

        Campaign readCampaign = INDIGO_TRN_AppController.ReadCampaignForName('Test Campaign Name');

        Test.stoptest();
    }      

/*     
    // --------------------------------------------------------------------------------
    // Scoreboard
    @isTest static void getScoreboardForCampaignIdTest() 
    {
        Campaign newCampaign = new Campaign
        (
            Name = 'Test Campaign Name'
        );
        insert(newCampaign);
        string campaignId = newCampaign.Id;              

        T4R_Run_For_Love_Scoreboard__c newScoreboard = new T4R_Run_For_Love_Scoreboard__c
        (
            T4R_Campaign__c = campaignId,
            T4R_Collective_target_miles__c = 999
        );
        insert(newScoreboard);

        Test.starttest();

        T4R_Run_For_Love_Scoreboard__c readScoreboard = INDIGO_TRN_AppController.getScoreboardForCampaignId(campaignId);

        Test.stoptest();
    }  

    @isTest static void getScoreboardIdForCampaignIdTest() 
    {
        Campaign newCampaign = new Campaign
        (
            Name = 'Test Campaign Name'
        );
        insert(newCampaign);
        string campaignId = newCampaign.Id;              

        T4R_Run_For_Love_Scoreboard__c newScoreboard = new T4R_Run_For_Love_Scoreboard__c
        (
            T4R_Campaign__c = campaignId,
            T4R_Collective_target_miles__c = 999
        );
        insert(newScoreboard);

        Test.starttest();

        string readScoreboardId = INDIGO_TRN_AppController.getScoreboardIdForCampaignId(campaignId);

        Test.stoptest();
    }  

    // --------------------------------------------------------------------------------
    // Home Pages
    @isTest static void getAllHomePagesTest() 
    {
        Test.starttest();

        INDIGO_TRN_AppController.GetAllHomePages();

        Test.stoptest();
    }    

    @isTest static void UpdateHomePageTest() 
    {
        Campaign newCampaign = new Campaign
        (
            Name = 'Test Campaign Name'
        );
        insert(newCampaign);
        string newCampaignId = newCampaign.Id;
        
        T4R_Run_For_Love_Scoreboard__c newScoreboard = new T4R_Run_For_Love_Scoreboard__c
        (
            T4R_Campaign__c = newCampaignId,
            T4R_Collective_target_miles__c = 24901
        );
        insert(newScoreboard);

        GW_Volunteers__Volunteer_Job__c newJob = new GW_Volunteers__Volunteer_Job__c
        (
            Name = 'TestJob',
            GW_Volunteers__Campaign__c = newCampaignId
        );
        insert newJob;

        Contact newContact = new Contact
        (
            Lastname = 'TestLastName',
            Email = 'test@test.com'
        );
        insert newContact;
        string newContactId = newContact.Id;

        GW_Volunteers__Volunteer_Hours__c volHours = INDIGO_TRN_AppController.EnsureVolHoursForJob(newContactId, 'TestJob');
        string volHoursId = volHours.Id;

        T4R_Run_For_Love_Home__c homePage = INDIGO_TRN_AppController.CreateHomePage(volHoursId, 1000);
        string homePageId = homePage.Id;
             
        Test.starttest();

        INDIGO_TRN_AppController.UpdateHomePage(homePageId, 999);

        Test.stoptest();
    }   
    
    */
}