@IsTest
private class LeadWebServiceTest {

    @TestSetup
    static void setupData() {
        Lead lead1 = new Lead(
            LastName = 'Test Lead One',
            Company = 'Test Company One',
            Email = 'test1@example.com',
            Status = 'Open - Not Contacted'
        );
        insert lead1;

        Lead lead2 = new Lead(
            LastName = 'Test Lead Two',
            Company = 'Test Company Two',
            Email = 'test2@example.com',
            Status = 'Working - Contacted'
        );
        insert lead2;
    }

    @IsTest
    static void testGetLeadById() {
        Lead testLead = [SELECT Id FROM Lead WHERE Email = 'test1@example.com' LIMIT 1];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Leads/*';
        req.addParameter('leadId', testLead.Id);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        LeadWebService.LeadResponse response = LeadWebService.getLead();

        Assert.areEqual(200, RestContext.response.statusCode);
        Assert.isTrue(response.success, 'Expected success to be true');
        Assert.areEqual('The request was successful', response.resultMessage);
        Assert.isNotNull(response.lead, 'Expected lead to not be null');
        Assert.areEqual(testLead.Id, response.lead.Id);
    }

    @IsTest
    static void testGetLeadByEmail() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Leads/*';
        req.addParameter('email', 'test2@example.com');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        LeadWebService.LeadResponse response = LeadWebService.getLead();

        Assert.areEqual(200, RestContext.response.statusCode);
        Assert.isTrue(response.success, 'Expected success to be true');
        Assert.areEqual('The request was successful', response.resultMessage);
        Assert.isNotNull(response.lead, 'Expected lead to not be null');
        Assert.areEqual('test2@example.com', response.lead.Email);
    }

    @IsTest
    static void testLeadNotFound() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Leads/*';
        req.addParameter('leadId', '00Q000000000000AAA');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        LeadWebService.LeadResponse response = LeadWebService.getLead();

        Assert.areEqual(404, RestContext.response.statusCode);
        Assert.isFalse(response.success, 'Expected success to be false');
        Assert.areEqual('Lead was not found', response.resultMessage);
        Assert.isNull(response.lead, 'Expected lead to be null');
    }

    @IsTest
    static void testInvalidRequest() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Leads/*';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        LeadWebService.LeadResponse response = LeadWebService.getLead();

        Assert.areEqual(400, RestContext.response.statusCode);
        Assert.isFalse(response.success, 'Expected success to be false');
        Assert.areEqual('The request was unacceptable. Please provide the necessary parameters (Lead Id or Email address).', response.resultMessage);
        Assert.isNull(response.lead, 'Expected lead to be null');
    }

    @IsTest
    static void testExceptionHandling() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Leads/*';
        req.addParameter('leadId', 'testException'); 
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        LeadWebService.LeadResponse response = LeadWebService.getLead();
        Test.stopTest();

        Assert.areEqual(500, RestContext.response.statusCode, 'Expected a 500 error code for exception');
        Assert.isFalse(response.success, 'Expected success to be false');
        Assert.isTrue(response.resultMessage.startsWith('An unexpected error occurred:'), 'Expected specific error message');
    }

    @IsTest
    static void testInvalidLeadIdFormat() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Leads/*';
        req.addParameter('leadId', 'INVALID_LEAD_ID'); 
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        LeadWebService.LeadResponse response = LeadWebService.getLead();

        Assert.areEqual(400, RestContext.response.statusCode);
        Assert.isFalse(response.success, 'Expected success to be false');
        Assert.areEqual('Invalid Lead ID format. Please provide a valid Lead Id.', response.resultMessage);
        Assert.isNull(response.lead, 'Expected lead to be null');
    }

    @IsTest
    static void testInvalidEmailFormat() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Leads/*';
        req.addParameter('email', 'INVALID_EMAIL_FORMAT'); 
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        LeadWebService.LeadResponse response = LeadWebService.getLead();

        Assert.areEqual(400, RestContext.response.statusCode);
        Assert.isFalse(response.success, 'Expected success to be false');
        Assert.areEqual('Invalid email format. Please provide a valid email address.', response.resultMessage);
        Assert.isNull(response.lead, 'Expected lead to be null');
    }
}
