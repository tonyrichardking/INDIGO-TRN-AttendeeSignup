//
// Log
//
// 18/1/2021 changed to without sharing 
// 18/1/2021 in GetHomePageForId set cacheable=true
// 21/1/2021 added T4R_Run_For_Love_Scoreboard__c to GetHomePageForId

public without sharing class INDIGO_TRN_AppController 
{
    public string conid {get;set;}

    public INDIGO_TRN_AppController() 
    {
        conid  = ApexPages.currentPage().getParameters().get('conid');
    }

    //
    // Contacts
    //

    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static Contact GetContactForId(string contactId) 
    {
        //system.debug('getContactForId: contactId = ' + contactId);
    
        return [
            SELECT Id, Name
            FROM Contact
            WHERE Id =: contactId
            //WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }  

/*     
    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static Contact GetContactForHomePageId(string homePageId) 
    {
        system.debug('getContactForHomePageId: homePageId = ' + homePageId);

        T4R_Run_For_Love_Home__c homePage = GetHomePageForId(homePageId);
        string volHoursId = homePage.T4R_Related_Runner__c;

        GW_Volunteers__Volunteer_Hours__c volHours =  GetVolunteerHoursForId(volHoursId);
        string contactId = volHours.GW_Volunteers__Contact__c;

        Contact contact = GetContactForId(contactId);

        return contact;
    }  
*/   

    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=false)
    public static Contact EnsureContact(string firstname, string lastname, string email, boolean gdpr, boolean newsletter) 
    {
        //system.debug('EnsureContact: firstname = ' + firstname + 'lastname = ' + lastname + 'email = ' + email + 'gdpr = ' + gdpr + 'newsletter = ' + newsletter);

        string fullName = firstname + ' ' + lastname;
            
        List<Contact> existingContacts = [
            SELECT Id, Name, Email, Permit_Contact_del__c, T4R_Receive_emails__c
            FROM Contact
            WHERE Email =: email AND Name =: fullName
            //WITH SECURITY_ENFORCED
        ];

        //system.debug('EnsureContacts: existingContact = ' + existingContacts);

        if(!existingContacts.isEmpty())
        {
            system.debug('EnsureContact: existingContact != null');
            return existingContacts.get(0);
        }

        Contact newContact = new Contact();
        newContact.Firstname = firstname;     
        newContact.Lastname = lastname;   
        newContact.Email = email;
        newContact.Permit_Contact_del__c = gdpr;
        newContact.T4R_Receive_emails__c = newsletter ? 'Yes' : 'No';

        //system.debug('EnsureContact: newContact = ' + newContact);

        try 
        {
            insert newContact;
        } 
        catch(DmlException e) 
        {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        } 

        return newContact;
    } 

    //
    // Volunteer Hours
    //

    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static GW_Volunteers__Volunteer_Hours__c getVolunteerHoursForId(string volHoursId) 
    {
        //system.debug('getVolunteerHoursForId: volHoursId = ' + volHoursId);

        return [
            SELECT Id, Name, GW_Volunteers__Contact__c, GW_Volunteers__Volunteer_Campaign__c,
                    Session__c, Session_Description__c, GW_Volunteers__Volunteer_Campaign_Name__c,
                    GW_Volunteers__Volunteer_Job__c, GW_Volunteers__Start_Date__c, Start_Time__c
            FROM GW_Volunteers__Volunteer_Hours__c
            WHERE Id =: volHoursId
            //WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }  

    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static List<GW_Volunteers__Volunteer_Hours__c> ReadVolunteerHoursForRecordTypeFromDate(string recordType, Integer dd, Integer mm, Integer yyyy) 
    {
        Date fromDate = Date.newInstance(yyyy, mm, dd);

        system.debug('ReadVolunteerHoursForRecordTypeFromDate: recordType = ' + recordType + 'date = ' + fromDate.day() + '/' + fromDate.month() + '/' + fromDate.year());       
    
        return [
            SELECT Id, Name, GW_Volunteers__Contact__c, GW_Volunteers__Volunteer_Campaign__c,
                    Session__c, Session_Description__c, GW_Volunteers__Volunteer_Campaign_Name__c,
                    GW_Volunteers__Volunteer_Job__c, GW_Volunteers__Start_Date__c, Start_Time__c, RecordTypeId
            FROM GW_Volunteers__Volunteer_Hours__c
            WHERE RecordTypeId =: recordType AND GW_Volunteers__Start_Date__c >= :fromDate
            //WITH SECURITY_ENFORCED
        ];
    }  

        // --------------------------------------------------------------------------------
        @AuraEnabled(cacheable=true)
        public static List<GW_Volunteers__Volunteer_Hours__c> ReadVolunteerHoursForCampaign(string campaignName) 
        {
            //system.debug('ReadVolunteerHoursForCampaign: volHoursId = ' + volHoursId);
        
            return [
                SELECT Id, Name, GW_Volunteers__Contact__c, GW_Volunteers__Volunteer_Campaign__c,
                        Session__c, Session_Description__c, GW_Volunteers__Volunteer_Campaign_Name__c,
                        GW_Volunteers__Volunteer_Job__c, GW_Volunteers__Start_Date__c, Start_Time__c
                FROM GW_Volunteers__Volunteer_Hours__c
                WHERE GW_Volunteers__Volunteer_Campaign_Name__c =: campaignName
                //WITH SECURITY_ENFORCED
            ];
        }  

    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=false)
    public static GW_Volunteers__Volunteer_Hours__c EnsureVolHoursForJob(string contactId, string jobName) 
    {
        //system.debug('EnsureVolHoursForJob: contactId = ' + contactId + 'jobName = ' + jobName);

        GW_Volunteers__Volunteer_Job__c job = ReadJobForName(jobName);

        List<GW_Volunteers__Volunteer_Hours__c> existingVolHours = [
            SELECT Id, GW_Volunteers__Volunteer_Job__c, GW_Volunteers__Contact__c
            FROM GW_Volunteers__Volunteer_Hours__c
            WHERE GW_Volunteers__Volunteer_Job__c =: job.Id AND GW_Volunteers__Contact__c =: contactId
            //WITH SECURITY_ENFORCED
        ];

        if(!existingVolHours.isEmpty())
        {
            //system.debug('EnsureVolHoursForJob: found an existing VolHours = ' + existingVolHours);            
            return null;
        }

        //system.debug('EnsureVolHoursForJob: creating a new VolHours = ');

        GW_Volunteers__Volunteer_Hours__c newVolHours = new GW_Volunteers__Volunteer_Hours__c();
        newVolHours.GW_Volunteers__Contact__c = contactId;
        newVolHours.GW_Volunteers__Volunteer_Job__c = job.Id;
        newVolHours.GW_Volunteers__Status__c = 'Web Sign Up';
        newVolHours.GW_Volunteers__Start_Date__c = Date.today();
    
        try 
        {
            insert newVolHours;
        } 
        catch(DmlException e) 
        {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        } 
   
        return newVolHours;
    }  
 
    //
    // Campaigns
    //

    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static Campaign ReadCampaignForName(string campaignName) 
    {
        //system.debug('ReadCampaignForName: campaignName = ' + campaignName);

        return [
            SELECT Id, Name, Type
            FROM Campaign
            WHERE Name =: campaignName
            //WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }  

    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static Campaign ReadCampaignForId(string campaignId) 
    {
        //system.debug('ReadCampaignForId: campaignName = ' + campaignId);

        return [
            SELECT Id, Name, Type
            FROM Campaign
            WHERE Id =: campaignId
            //WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    //
    // Jobs
    //

    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static GW_Volunteers__Volunteer_Job__c ReadJobForName(string jobName) 
    {
        //system.debug('GetJobForName: campaignName = ' + campaignName);

        return [
            SELECT Id, Name, GW_Volunteers__Campaign__c
            FROM GW_Volunteers__Volunteer_Job__c
            WHERE Name =: jobName
            //WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }  

    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static List<GW_Volunteers__Volunteer_Job__c> ReadJobsForCampaignId(string campaignId) 
    {
        //system.debug('ReadJobsForCampaignId: campaignId = ' + campaignId);
        
        return [
            SELECT Id, Name, GW_Volunteers__Campaign__c, Job_Contact__c, Organisation_Name__c
            FROM GW_Volunteers__Volunteer_Job__c
            WHERE GW_Volunteers__Campaign__c =: campaignId
            //WITH SECURITY_ENFORCED
        ];
    }

    //
    // Attendees
    //

    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=false)
    public static Attendee__c EnsureAttendeeForContactAndVolHours(string contactId, string volHoursId) 
    {
        //system.debug('EnsureAttendeeForContactAndVolHours: contactId = ' + contactId + 'volHoursId = ' + volHoursId);

        Attendee__c newAttendee = new Attendee__c();
        newAttendee.Attendee_Name__c = contactId;
        newAttendee.Training_Consulting_Therapy_Session__c = volHoursId;
        newAttendee.Attendee_Status__c = 'Registered';
        
        try 
        {
            insert newAttendee;
        } 
        catch(DmlException e) 
        {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        } 
   
        return newAttendee;
    }  
}