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
    public static List<GW_Volunteers__Volunteer_Hours__c> ReadVolunteerHoursForJobFromDate(string jobId, Integer dd, Integer mm, Integer yyyy) 
    {
        //system.debug('ReadVolunteerHoursForJob: jobId = ' + jobId);
        
        Date fromDate = Date.newInstance(yyyy, mm, dd);
        
        return [
            SELECT Id, Name, GW_Volunteers__Contact__c, GW_Volunteers__Volunteer_Campaign__c,
            Session__c, Session_Description__c, GW_Volunteers__Volunteer_Campaign_Name__c,
            GW_Volunteers__Volunteer_Job__c, GW_Volunteers__Start_Date__c, Start_Time__c, Session_Start__c,
            Time_Zone__c, RecordTypeId, Zoom_Session_Details__c, T4R_TRN_Zoom_Session_URL__c
            FROM GW_Volunteers__Volunteer_Hours__c
            WHERE GW_Volunteers__Volunteer_Job__c =: jobId AND GW_Volunteers__Start_Date__c >= :fromDate
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
            SELECT Id, Name, GW_Volunteers__Campaign__c, Job_Contact__c, Organisation_Name__c,
            GW_Volunteers__Description__c, Project_Type__c
            FROM GW_Volunteers__Volunteer_Job__c
            WHERE GW_Volunteers__Campaign__c =: campaignId
            //WITH SECURITY_ENFORCED
        ];
    }
    
    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static List<GW_Volunteers__Volunteer_Job__c> ReadJobsForCampaign(string campaignName) 
    {
        system.debug('ReadJobsForCampaign: campaignName = ' + campaignName);
        
        Campaign campaign = ReadCampaignForName(campaignName);
        List<GW_Volunteers__Volunteer_Job__c> jobs = ReadJobsForCampaignId(campaign.Id);
        
        return jobs;
    }
    
    //
    // Attendees
    //
    
    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=false)
    //public static Attendee__c EnsureAttendeeForContactAndVolHours(string contactId, string volHoursId, string zoomDetails, string zoomUrl, string sessionDescription) 
    //public static Attendee__c EnsureAttendeeForContactAndVolHours(string contactId, string volHoursId, string partnerProjectId) 
    public static Attendee__c EnsureAttendeeForContactAndVolHours(string contactId, string volHoursId) 
    {
        system.debug('EnsureAttendeeForContactAndVolHours: contactId = ' + contactId + 'volHoursId = ' + volHoursId 
                     //+ 'zoomDetails = ' + zoomDetails + 'zoomUrl = ' + zoomUrl
                    );
        
        Attendee__c newAttendee = new Attendee__c();
        newAttendee.Attendee_Name__c = contactId;
        newAttendee.Training_Consulting_Therapy_Session__c = volHoursId;
        newAttendee.Attendee_Status__c = 'Registered';
        newAttendee.Partner_Project__c = partnerProjectId;
        //newAttendee.T4R_Zoom_Session_Details__c = zoomDetails;
        //newAttendee.T4R_TRN_Zoom_Session_URL__c = zoomUrl;
        //newAttendee.Training_Session_Description__c = sessionDescription;
        
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
    
    //
    // Partner Projects
    //
    
    // --------------------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static List<Partner_Project__c> ReadActivePartnerProjects() 
    {
        //system.debug('ReadActivePartnerProjects:');
        
        List<Partner_Project__c> partnerProjects = [
            SELECT Id, Name, Activity_Status__c
            FROM Partner_Project__c
            //WHERE Activity_Status__c =: '🟢 Operational' OR  Activity_Status__c = '🔵 Onboarding'
        ];
        
        List<Partner_Project__c> activePartnerProjects = new List<Partner_Project__c>();
        
        for (Partner_Project__c partnerProject : partnerProjects)
        {
            if (partnerProject.Activity_Status__c.contains('Operational') || partnerProject.Activity_Status__c.contains('Onboarding'))
            {
                activePartnerProjects.add(partnerProject);
            }
        }
        
        return activePartnerProjects;
    }
}