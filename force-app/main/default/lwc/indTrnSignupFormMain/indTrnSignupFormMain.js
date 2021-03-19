import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { reduceErrors } from "c/ldsUtils";

import EnsureContact from "@salesforce/apex/INDIGO_TRN_AppController.EnsureContact";
import ReadVolunteerHoursForCampaign from "@salesforce/apex/INDIGO_TRN_AppController.ReadVolunteerHoursForCampaign";
import ReadVolunteerHoursForRecordTypeFromDate from "@salesforce/apex/INDIGO_TRN_AppController.ReadVolunteerHoursForRecordTypeFromDate";
import ReadJobsForCampaignId from "@salesforce/apex/INDIGO_TRN_AppController.ReadJobsForCampaignId";
import ReadCampaignForName from "@salesforce/apex/INDIGO_TRN_AppController.ReadCampaignForName";
import EnsureAttendeeForContactAndVolHours from "@salesforce/apex/INDIGO_TRN_AppController.EnsureAttendeeForContactAndVolHours";

const theRandMCampaignName = "R and M Partners";
const courseFromDate = '01/04/2020';
const trainingRecordTypeId = '0121r000000iitHAAQ';

export default class IndTrnSignupFormMain extends LightningElement {
    showSignup = true;
    showRequiredError = false;

    gdprValue = "";
    newsletterValue = "";

    theFirstname = "";
    theLastname = "";
    theEmail = "";

    @api pageCampaignName; // the name of the campaign from web page URL parameter

    //Debug
    error;
    errorMessage = 'Error message undefined';

    theDateToday;

    // --------------------------------------------------------------------------------
    // initialisation
    //
    connectedCallback() {

        // set up debugging

        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();  
        this.theDateToday = dd + '/' + mm + '/' + yyyy;

        // initialise the drop-downs

        //this.initialiseCoursesForCampaign();
        this.initialiseAllCoursesForFromDate();
        this.initialiseOrganisations();
    }

    // --------------------------------------------------------------------------------
    // List of R&M organisations.
    //
    theRandMCampaign;
    theRandMCampaignId;
    theRandMJobsList;
    theRandMOptions;
    theSelectedRandMValue = "";
    theSelectedRandMJob;               // the selected organisation (Volunteer Job)

    get theRandMPartners() {
        return this.theRandMOptions;
    }

    initialiseOrganisations() {
        ReadCampaignForName({ campaignName: theRandMCampaignName })
            .then((result) => {
                if (result != null) {
                    this.theRandMCampaign = result;
                    this.theRandMCampaignId = result.Id;
                    this.errorMessage = 'result OK;'
                }
                else {
                    this.theRandMCampaign = undefined;
                    this.errorMessage = 'result was null;'
                }
            })
            .then((result) => {
                ReadJobsForCampaignId({ campaignId: this.theRandMCampaignId })
                    .then((result) => {
                        if (result != null) {
                            this.theRandMJobsList = result;
                            this.theRandMOptions = this.buildRandMOptions(
                                this.theRandMJobsList
                            );
                        }
                    }).catch(error => {
                        this.error = error;
                        this.errorMessage = reduceErrors(error);
                    })
            })
    }

    buildRandMOptions(jobs) {
        var options = [];

        Object.values(jobs).forEach((job) => {
            options.push({
                label: job.Name,
                value: job.Name
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

        options.unshift({
            label: 'None',
            value: 'None'
        });

        return options;
    }

    handleRandMJobSelection(event) {
        // set the selected session
        this.theSelectedRandMValue = event.detail.value;

        // find the job for the selected session
        this.theSelectedRandMJob = this.theRandMJobsList.find(
            (v) => v.Name === this.theSelectedRandMValue
        );
    }

    // --------------------------------------------------------------------------------
    // List of courses.
    //
    theCourseVolHoursList;
    theCourseOptions;
    theSelectedCourseValue = "";
    theSelectedVolHours; // the selected training session (Volunteer Hours)

    get theCourses() {
        return this.theCourseOptions;
    }

    initialiseAllCoursesForFromDate() {
        ReadVolunteerHoursForRecordTypeFromDate({ recordType: trainingRecordTypeId, dd: 1,  mm: 4, yyyy: 2020})
            .then((result) => {
                if (result != null) {
                    this.theCourseVolHoursList = result;
                    this.theCourseOptions = this.buildCourseOptions(
                        this.theCourseVolHoursList
                    );
                    this.errorMessage = 'result OK';
                }
                else {
                    this.theCourseVolHoursList = undefined;
                    this.errorMessage = 'result was null;'
                }
            })
            .catch(error => {
                this.error = error;
                this.errorMessage = reduceErrors(error);
            });
    }

    initialiseCoursesForCampaign() {
        ReadVolunteerHoursForCampaign({ campaignName: this.pageCampaignName })
            .then((result) => {
                if (result != null) {
                    this.theCourseVolHoursList = result;
                    this.theCourseOptions = this.buildCourseOptions(
                        this.theCourseVolHoursList
                    );
                    this.errorMessage = 'result OK';
                }
                else {
                    this.theCourseVolHoursList = undefined;
                    this.errorMessage = 'result was null;'
                }
            })
            .catch(error => {
                this.error = error;
                this.errorMessage = reduceErrors(error);
            });
    }

    buildCourseOptions(volHours) {
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

    handleCourseSelection(event) {
        // set the selected session
        this.theSelectedCourseValue = event.detail.value;

        // find the vol hours for the selected session
        this.theSelectedVolHours = this.theCourseVolHoursList.find(
            (v) => v.Session__c === this.theSelectedCourseValue
        );

        //alert('handleCourseSelection: session = ' + this.theSelectedVolHours.Session_Description__c);
    }

    // --------------------------------------------------------------------------------
    // More details of courses.
    //

    @track theEnableMoreDetails = false;

    handleMoreDetails() {
        this.theEnableMoreDetails = !this.theEnableMoreDetails;
    }

    // --------------------------------------------------------------------------------
    // Handle the name and inputs
    //

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
    // If a Volunteer Hours exists for a 'Run For Love' do no more; create one and a home page otherwise
    //

    theNewAttendee;

    handleSave() {
        /*         alert('handleSave: Firstname = ' + this.theFirstname + ', Lastname = ' + this.theLastname + ', Email = '
                            + this.theEmail + ', gdpr = ' + this.gdprValue + ', newsletter = ' + this.newsletterValue); */

        var selectAgreeGdpr = this.gdprValue == "agree" ? true : false;
        var selectAgreeNewsletter = this.newsletterValue == "yes" ? true : false;

        if (
            this.theFirstname == "" ||
            this.theLastname == "" ||
            this.theEmail == "" ||
            this.theMiles == "" ||
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
                        volHoursId: this.theSelectedVolHours.Id
                    }).then((result) => {
                        if (result != null) {
                            this.theNewAttendee = result;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Success",
                                    message: "You have been registered for " + this.theSelectedCourseValue,
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
            this.showSignup = false;
        }
    }
}
