import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { reduceErrors } from "c/ldsUtils";

import EnsureContact from "@salesforce/apex/INDIGO_TRN_AppController.EnsureContact";
import ReadJobsForCampaign from "@salesforce/apex/INDIGO_TRN_AppController.ReadJobsForCampaign";
import ReadVolunteerHoursForJobFromDate from "@salesforce/apex/INDIGO_TRN_AppController.ReadVolunteerHoursForJobFromDate";
import EnsureAttendeeForContactAndVolHours from "@salesforce/apex/INDIGO_TRN_AppController.EnsureAttendeeForContactAndVolHours";
import ReadActivePartnerProjects from "@salesforce/apex/INDIGO_TRN_AppController.ReadActivePartnerProjects";

const theRandMCampaignName = "R and M Partners";

export default class IndTrnSignupFormMain extends LightningElement {
    enableFirstPage = true;
    showRequiredError = false;

    @api pageCampaignName; // the name of the campaign from web page URL parameter

    //Debug
    error;
    errorMessage = 'Error message undefined';

    theDateToday;
    theLastEditedDate = '8/4/2022';
    theTimeNow;

    dd;
    mm;
    yyyy;

    // --------------------------------------------------------------------------------
    // initialisation
    //
    connectedCallback() {

        // set up debugging

        var today = new Date();
        this.dd = String(today.getDate()).padStart(2, '0');
        this.mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        this.yyyy = today.getFullYear();
        this.theDateToday = this.dd + '/' + this.mm + '/' + this.yyyy;
        this.theTimeNow = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();

        // initialise the drop-downs

        this.initialiseCoursesForCampaign();
        this.initialiseAllStateForStartup();
        this.initialiseActivePartnerProjects();
    }

    initialiseAllStateForStartup() {
        this.enableFirstPage = true;
        this.hasMultipleSessions = false;
        this.assertSessionsAvailable = true;
        this.theEnableMoreDetails = false;
        this.theSelectedCourseValue = "";
        this.theSelectedSessionValue = "";
        this.theSelectedVolHours = null;
    }

    // --------------------------------------------------------------------------------
    // List of Partner Projects
    //

    thePartnerProjectList;                      // the List<Partner_Project__c> returned from the controller
    thePartnerProjectOptions;                   // the java array of partner project strings 
    theSelectedPartnerProjectValue = "";        // the value returned from the partner project dropdown
    theSelectedPartnerProject;                  // the partner project selected by the user

    get thePartnerProjects() {                  // accessor used to populate the dropdown
        return this.thePartnerProjectOptions;
    }

    // read the partner project objects which are "Operational" or "Onboarding"
    initialiseActivePartnerProjects() {
        ReadActivePartnerProjects()
            .then((result) => {
                if (result != null) {
                    this.thePartnerProjectList = result;
                    this.thePartnerProjectOptions = this.buildPartnerProjectOptions(this.thePartnerProjectList);
                }
            }).catch(error => {
                this.error = error;
                this.errorMessage = reduceErrors(error);
            })
    }

    // convert the List<Partner_Project__c> into an array to populate the dropdown
    buildPartnerProjectOptions(partnerProjects) {
        var options = [];

        Object.values(partnerProjects).forEach((partnerProject) => {
            options.push({
                label: partnerProject.Name,
                value: partnerProject.Name
            });
        });

        // sort alphabetically
        options.sort(function (a, b) {
            var nameA = a.label.toUpperCase(); // ignore upper and lowercase
            var nameB = b.label.toUpperCase(); // ignore upper and lowercase
            if (nameA < nameB) {
                return -1; //nameA comes first
            }
            if (nameA > nameB) {
                return 1; // nameB comes first
            }

            return 0;  // names must be equal
        });

        options.unshift({
            label: 'None',
            value: 'None'
        });

        return options;
    }

    // handle the event fired by the selection of a partner project
    handlePartnerProjectSelection(event) {
        // set the selected session
        this.theSelectedPartnerProjectValue = event.detail.value;

        // find the job for the selected session
        this.theSelectedPartnerProject = this.thePartnerProjectList.find(
            (v) => v.Name === this.theSelectedPartnerProjectValue
        );
    }

    // --------------------------------------------------------------------------------
    // List of courses (Volunteer Jobs).
    //

    theJobCourseList;
    theCourseDetails;
    theSelectedCourseValue = "";
    theSelectedJob;                     // the selected training course (Volunteer Job)

    get theCourses() {
        return this.theCourseDetails;
    }

    initialiseCoursesForCampaign() {
        ReadJobsForCampaign({ campaignName: this.pageCampaignName })
            .then((result) => {
                if (result != null) {
                    this.theJobCourseList = result;
                    this.theCourseDetails = this.buildCourseDetails(
                        this.theJobCourseList
                    );
                    this.errorMessage = 'result OK';
                }
                else {
                    this.theJobCourseList = undefined;
                    this.errorMessage = 'result was null;'
                }
            })
            .catch(error => {
                this.error = error;
                this.errorMessage = reduceErrors(error);
            });
    }

    buildCourseDetails(volJob) {
        var options = [];

        Object.values(volJob).forEach((volJob) => {
            options.push({
                label: volJob.Name,
                value: volJob.Name
            });
        });

        options.sort(function (a, b) {
            var nameA = a.label.toUpperCase(); // ignore upper and lowercase
            var nameB = b.label.toUpperCase(); // ignore upper and lowercase
            if (nameA < nameB) {
                return -1; //nameA comes first
            }
            if (nameA > nameB) {
                return 1; // nameB comes first
            }

            return 0;  // names must be equal
        });

        return options;
    }

    handleCourseSelection(event) {
        // set the selected session
        this.theSelectedCourseValue = event.detail.value;

        // find the vol hours for the selected session
        this.theSelectedJob = this.theJobCourseList.find(
            (v) => v.Name === this.theSelectedCourseValue
        );

        this.initialiseAllSessionsForJobFromDate();

        //alert('handleCourseSelection: course = ' + this.theSelectedJob.Name);
    }

    // --------------------------------------------------------------------------------
    // List of sessions (Volunteer Hours).
    //

    theSessionVolHoursList;
    theSessionDetails;
    theSelectedSessionValue = "";
    theSelectedVolHours = null;         // the selected training session (Volunteer Hours)
    hasMultipleSessions = false;        // there are multiple sessions for this course (job)
    assertSessionsAvailable = true;     // only allow signup if there are future sessions for this course (job)

    get theStartTime() {
        if (this.theSelectedVolHours && this.theSelectedVolHours.Start_Time__c) {
            const timeInMillisecs = this.theSelectedVolHours.Start_Time__c;
            const date = new Date(timeInMillisecs);
            var hh = String(date.getHours() - 1).padStart(2, '0');
            var mm = String(date.getMinutes()).padStart(2, '0');

            return hh + ':' + mm;
        }

        return "";
    }

    get theStartDateTime() {
        if (this.theSelectedVolHours && this.theSelectedVolHours.GW_Volunteers__Start_Date__c && this.theSelectedVolHours.Time_Zone__c) {
            const date = new Date(this.theSelectedVolHours.GW_Volunteers__Start_Date__c);

            return `${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()}   ${this.theStartTime}   ${this.theSelectedVolHours.Time_Zone__c}`;
        }

        return "";
    }

    get theSessions() {
        return this.theSessionDetails;
    }

    initialiseAllSessionsForJobFromDate() {
        ReadVolunteerHoursForJobFromDate({ jobId: this.theSelectedJob.Id, dd: this.dd, mm: this.mm, yyyy: this.yyyy })
            .then((result) => {
                if (result != null) {
                    this.theSessionVolHoursList = result;
                    this.theSessionDetails = this.buildSessionDetails(
                        this.theSessionVolHoursList
                    );
                    this.errorMessage = 'result OK';
                }
                else {
                    this.theSessionVolHoursList = undefined;
                    this.errorMessage = 'result was null;';
                }
            })
            .then(() => {
                // if there are more than one session for this course enable the session drop-down to select a session.
                // If there is only one then select the first (and only) session in the list.
                this.hasMultipleSessions = (this.theSessionVolHoursList.length > 1) ? true : false;
                this.theSelectedVolHours = (this.hasMultipleSessions) ? null : this.theSessionVolHoursList[0];
                this.assertSessionsAvailable = (this.theSessionVolHoursList.length > 0) ? true : false;
            })
            .catch(error => {
                this.error = error;
                this.errorMessage = reduceErrors(error);
            });
    }

    buildSessionDetails(volHours) {
        var options = [];

        Object.values(volHours).forEach((volHour) => {
            options.push({
                label: volHour.Session__c,
                value: volHour.Session__c
            });
        });

        options.sort(function (a, b) {
            var nameA = a.label.toUpperCase(); // ignore upper and lowercase
            var nameB = b.label.toUpperCase(); // ignore upper and lowercase
            if (nameA < nameB) {
                return -1; //nameA comes first
            }
            if (nameA > nameB) {
                return 1; // nameB comes first
            }

            return 0;  // names must be equal
        });

        return options;
    }

    handleSessionSelection(event) {
        // set the selected session
        this.theSelectedSessionValue = event.detail.value;

        // find the vol hours for the selected session
        this.theSelectedVolHours = this.theSessionVolHoursList.find(
            (v) => v.Session__c === this.theSelectedSessionValue
        );

        //alert('handleSessionSelection: session = ' + this.theSelectedVolHours.Session_Description__c);
    }

    // --------------------------------------------------------------------------------
    // More details of courses.
    //

    @track theEnableMoreDetails = false;

    handleMoreDetails() {
        this.theEnableMoreDetails = !this.theEnableMoreDetails;
    }

    // --------------------------------------------------------------------------------
    // Handle the contact info
    //

    theFirstname = "";
    theLastname = "";
    theEmail = "";

    handleFirstname(event) {
        // alert('handleFirstname: theFirstname = ' + event.target.value);
        this.theFirstname = event.target.value;
    }

    handleLastname(event) {
        // alert('handleLastname: theLastname = ' + event.target.value);
        this.theLastname = event.target.value;
    }

    handleEmail(event) {
        // alert('handleEmail: theEmail = ' + event.target.value);
        this.theEmail = event.target.value;
    }

    // --------------------------------------------------------------------------------
    // Handle the GDPR agreement and newsletter signup inputs.
    //

    gdprValue = "";
    newsletterValue = "";

    get gdprOptions() {
        return [{ label: "I Agree", value: "agree" }];
    }

    handleGdprAgreement(event) {
        this.gdprValue = event.detail.value;
        //alert('handleGdprAgreement: value = ' + this.gdprValue);
    }

    get newsletterOptions() {
        return [
            { label: "Yes", value: "yes" },
            { label: "No", value: "no" }
        ];
    }

    handleNewsletterAgreement(event) {
        this.newsletterValue = event.detail.value;
        //alert('handleNewsletterAgreement: value = ' + this.newsletterValue);
    }

    // --------------------------------------------------------------------------------
    // Save the signup information.
    // If the Contact exists use it; create a new one otherwise.
    // Create a new Attendee record (junction object connecting a Contact to a Session/Voluntee Hours)
    //

    theNewAttendee;

    handleSave() {
        //alert('handleSave: sessionDescription = ' + this.theSelectedVolHours.Session_Description__c);

        var selectAgreeGdpr = this.gdprValue == "agree" ? true : false;
        var selectAgreeNewsletter = this.newsletterValue == "yes" ? true : false;

        if (
            this.theFirstname == "" ||
            this.theLastname == "" ||
            this.theEmail == "" ||
            this.gdprValue == "" ||
            this.newsletterValue == ""
        ) {
            //  All the required combos must have a value selected
            //alert('Both gdpr and newsletter combos must have a value selected');
            this.showRequiredError = true;
        } else {
            EnsureContact({
                firstname: this.theFirstname,
                lastname: this.theLastname,
                email: this.theEmail,
                gdpr: selectAgreeGdpr,
                newsletter: selectAgreeNewsletter
            })
                .then((result) => {
                    EnsureAttendeeForContactAndVolHours({
                        contactId: result.Id,
                        volHoursId: this.theSelectedVolHours.Id,
                        zoomDetails: this.theSelectedVolHours.Zoom_Session_Details__c,
                        zoomUrl: this.theSelectedVolHours.T4R_TRN_Zoom_Session_URL__c,
                        sessionDescription: this.theSelectedVolHours.Session_Description__c
                    }).then((result) => {
                        if (result != null) {
                            this.theNewAttendee = result;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Success",
                                    message: "You have been registered for " + this.theSelectedSessionValue,
                                    variant: "success"
                                }))
                        }
                    });
                })
                .catch((error) => {
                    this.error = error;
                    this.errorMessage = reduceErrors(error);
                });

            // change the component view
            this.showRequiredError = false;
            this.enableFirstPage = false;
        }
    }

    handleAnotherSession() {
        this.initialiseAllStateForStartup();
    }
}
