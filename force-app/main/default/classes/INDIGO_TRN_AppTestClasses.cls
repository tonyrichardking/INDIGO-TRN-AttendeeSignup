@isTest
private class INDIGO_TRN_AppTestClasses
{
    // --------------------------------------------------------------------------------
    // Contacts
    //

    @isTest static void EnsureContactTest() 
    {
        Test.starttest();

        Contact contact = INDIGO_TRN_AppController.EnsureContact('TestFirstName', 'TestLastName', 'test@test.com', true, true );

        Test.stoptest();
    }

    // --------------------------------------------------------------------------------
    // Volunteer Hours
    //

    @isTest static void ReadVolunteerHoursForJobFromDateTest() 
    {
        // Create Campaign

        Campaign newCampaign = new Campaign
        (
            Name = 'Test Campaign Name'
        );
        insert(newCampaign);
        string newCampaignId = newCampaign.Id;

        // Create Job

        GW_Volunteers__Volunteer_Job__c newJob = new GW_Volunteers__Volunteer_Job__c
        (
            Name = 'TestJob',
            GW_Volunteers__Campaign__c = newCampaignId
        );
        insert newJob;
        string newJobId = newJob.Id;

        // Create Contact

        Contact newContact = new Contact
        (
            Lastname = 'TestLastName',
            Email = 'test@test.com'
        );
        insert newContact;
        string newContactId = newContact.Id;

        // Create Volunteer Hours

        Integer dd = 1;
        Integer mm = 1;
        Integer yyyy = 2021;
        Date fromDate = Date.newInstance(yyyy, mm, dd);

        GW_Volunteers__Volunteer_Hours__c newVolHours = new GW_Volunteers__Volunteer_Hours__c
        (
            GW_Volunteers__Contact__c = newContactId,
            GW_Volunteers__Volunteer_Job__c = newJobId,
            GW_Volunteers__Start_Date__c = fromDate,
            T4R_TRN_Zoom_Session_URL__c = 'http://testzoomsession.com'
        );
        insert newVolHours;
        string volHoursId = newVolHours.Id;  

        // Test

        Test.starttest();

        List<GW_Volunteers__Volunteer_Hours__c>  volHours = INDIGO_TRN_AppController.ReadVolunteerHoursForJobFromDate(newJobId, dd, mm, yyyy);

        Test.stoptest();
    }    

    // --------------------------------------------------------------------------------
    // Campaigns
    //

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
    
    // --------------------------------------------------------------------------------
    // Jobs
    //
  
    @isTest static void ReadJobsForCampaignTest() 
    {
        // Create Campaign

        Campaign newCampaign = new Campaign
        (
            Name = 'Test Campaign Name'
        );
        insert(newCampaign);
        string newCampaignId = newCampaign.Id;
        string newCampaignName = newCampaign.Name;

        // Create Job

        GW_Volunteers__Volunteer_Job__c newJob = new GW_Volunteers__Volunteer_Job__c
        (
            Name = 'TestJob',
            GW_Volunteers__Campaign__c = newCampaignId
        );
        insert newJob;
        string newJobId = newJob.Id;

        Test.starttest();

        List<GW_Volunteers__Volunteer_Job__c> jobs = INDIGO_TRN_AppController.ReadJobsForCampaign(newCampaignName);

        Test.stoptest();
    }

    @isTest static void ReadJobsForCampaignIdTest() 
    {
        // Create Campaign

        Campaign newCampaign = new Campaign
        (
            Name = 'Test Campaign Name'
        );
        insert(newCampaign);
        string newCampaignId = newCampaign.Id;
        string newCampaignName = newCampaign.Name;

        // Create Job

        GW_Volunteers__Volunteer_Job__c newJob = new GW_Volunteers__Volunteer_Job__c
        (
            Name = 'TestJob',
            GW_Volunteers__Campaign__c = newCampaignId
        );
        insert newJob;
        string newJobId = newJob.Id;

        Test.starttest();

        List<GW_Volunteers__Volunteer_Job__c> jobs = INDIGO_TRN_AppController.ReadJobsForCampaignId(newCampaignId);

        Test.stoptest();
    } 

    // --------------------------------------------------------------------------------
    // Attendees
    //

    @isTest static void EnsureAttendeeForContactAndVolHoursTest() 
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

        GW_Volunteers__Volunteer_Hours__c volHours = INDIGO_TRN_AppController.EnsureVolHoursForJob(newContactId, 'TestJob');
        string volHoursId = volHours.Id;

        string zoomDetails = 'Test Zoom Details';
        string zoomUrl = 'http://TestZoomUrl.com';
        string sessionDescription = 'Test Session Description';

        Test.starttest();

        Attendee__c testAttendee = INDIGO_TRN_AppController.EnsureAttendeeForContactAndVolHours(newContactId, volHoursId, zoomDetails, zoomUrl, sessionDescription);

        Test.stoptest();
    }   
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
    
    @isTest static void ReadVolunteerHoursForJobFromDateTest() 
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

        List<GW_Volunteers__Volunteer_Hours__c>  volHours = INDIGO_TRN_AppController.ReadVolunteerHoursForJobFromDate(string jobId, Integer dd, Integer mm, Integer yyyy) 

        Test.stoptest();
    }  
    
    */