@IsTest
public class TaskWebServiceTest {

    @IsTest
    static void testCreateTaskWithLeadId() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest(lead.Id, 'Call', 'Not Started', 'Normal', '2024-11-05');
        Assert.isTrue(response.success, 'Expected response.success to be true');
        Assert.areEqual('The task was successfully created.', response.resultMessage, 'Expected specific success message');
        Assert.isNotNull(response.task, 'Expected response.task to be not null');
        Assert.areEqual('Call', response.task.Subject, 'Expected Subject to be Call');
        Assert.areEqual('Not Started', response.task.Status, 'Expected Status to be Not Started');
        Assert.areEqual('Normal', response.task.Priority, 'Expected Priority to be Normal');
    }

    @IsTest
    static void testCreateTaskWithLeadEmail() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest('testlead@example.com', 'Meeting', 'In Progress', 'High', '2024-11-05');
        Assert.isTrue(response.success, 'Expected response.success to be true');
        Assert.areEqual('The task was successfully created.', response.resultMessage, 'Expected specific success message');
        Assert.isNotNull(response.task, 'Expected response.task to be not null');
        Assert.areEqual('Meeting', response.task.Subject, 'Expected Subject to be Meeting');
        Assert.areEqual('In Progress', response.task.Status, 'Expected Status to be In Progress');
        Assert.areEqual('High', response.task.Priority, 'Expected Priority to be High');
    }

    @IsTest
    static void testInvalidLeadIdFormat() {
        TaskWebService.TaskResponse response = createTaskRequest('invalidLeadId', 'Call', 'Completed', 'Low', null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(400, RestContext.response.statusCode, 'Expected 400 status code');
        Assert.areEqual('Invalid input of leadIdOrEmail parameter.', response.resultMessage, 'Expected specific error message');
    }

    @IsTest
    static void testInvalidEmailFormat() {
        TaskWebService.TaskResponse response = createTaskRequest('invalid@Email', 'Call', 'Waiting on someone else', 'High', null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(400, RestContext.response.statusCode, 'Expected 400 status code');
        Assert.areEqual('Invalid email format. Please provide a valid email address.', response.resultMessage, 'Expected specific error message');
    }

    @IsTest
    static void testEmptyLeadIdOrEmail() {
        TaskWebService.TaskResponse response = createTaskRequest(null, 'Call', 'Not Started', 'Normal', null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(400, RestContext.response.statusCode, 'Expected 400 status code');
        Assert.areEqual('Parameter leadIdOrEmail is empty. Please provide the necessary parameters (Lead Id or Email address).', response.resultMessage, 'Expected specific error message');
    }

    @IsTest
    static void testEmptyTaskBody() {
        TaskWebService.TaskResponse response = createTaskRequest('testlead@example.com', null, null, null, null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(400, RestContext.response.statusCode, 'Expected 400 status code');
        Assert.areEqual('Parameter taskBody is empty. Please complete taskBody with valid Task values.', response.resultMessage, 'Expected specific error message');
    }


    @IsTest
    static void testMissingStatusField() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest(lead.Id, 'Call', null, 'Normal', null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(400, RestContext.response.statusCode, 'Expected 400 status code');
        Assert.areEqual('The Status field is required.', response.resultMessage);
    }

    @IsTest
    static void testMissingPriorityField() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest(lead.Id, 'Call', 'Not Started', null, null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(400, RestContext.response.statusCode, 'Expected 400 status code');
        Assert.areEqual('The Priority field is required.', response.resultMessage);
    }

    @IsTest
    static void testInvalidLeadIdFormatForLead() {
        TaskWebService.TaskResponse response = createTaskRequest('00Q1234', 'Call', 'Completed', 'Low', null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(400, RestContext.response.statusCode, 'Expected 400 status code');
        Assert.areEqual('Invalid Lead ID format. Please provide a valid Lead Id.', response.resultMessage);
    }

    @IsTest
    static void testTaskBodyMissingFields() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest(lead.Id, null, 'Not Started', 'Normal', null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(400, RestContext.response.statusCode, 'Expected 400 status code');
        Assert.areEqual('The Subject field is required.', response.resultMessage, 'Expected specific error message');
    }

    @IsTest
    static void testInvalidStatusValue() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest(lead.Id, 'Call', 'InvalidStatus', 'Normal', null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(400, RestContext.response.statusCode, 'Expected 400 status code');
        Assert.areEqual('Invalid value of the Status field', response.resultMessage, 'Expected specific error message');
    }

    @IsTest
    static void testInvalidPriorityValue() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest(lead.Id, 'Call', 'Not Started', 'InvalidPriority', null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(400, RestContext.response.statusCode, 'Expected 400 status code');
        Assert.areEqual('Invalid value of the Priority field', response.resultMessage, 'Expected specific error message');
    }

    @IsTest
    static void testInvalidDateFormat() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest(lead.Id, 'Call', 'Not Started', 'Normal', 'invalidDate');
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(400, RestContext.response.statusCode, 'Expected 400 status code');
        Assert.areEqual('Date format is invalid.', response.resultMessage, 'Expected specific error message');
    }

    @IsTest
    static void testLeadNotFound() {
        TaskWebService.TaskResponse response = createTaskRequest('00Q000000000000AAA', 'Call', 'Not Started', 'Normal', null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(404, RestContext.response.statusCode, 'Expected 404 status code');
        Assert.areEqual('Lead was not found', response.resultMessage, 'Expected specific error message');
    
        response = createTaskRequest('testlead@example.com', 'Call', 'Not Started', 'Normal', null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(404, RestContext.response.statusCode, 'Expected 404 status code');
        Assert.areEqual('Lead was not found', response.resultMessage, 'Expected specific error message');
    }

    @IsTest
    static void testUnexpectedError() {
        TaskWebService.TaskResponse response = createTaskRequest('testException', 'Call', 'Not Started', 'Normal', null);
        Assert.isFalse(response.success, 'Expected response.success to be false');
        Assert.areEqual(500, RestContext.response.statusCode, 'Expected 500 status code');
        Assert.areEqual('An unexpected error occurred: An exceptional situation was tested.', response.resultMessage, 'Expected specific error message');
    }

    private static TaskWebService.TaskResponse createTaskRequest(String leadIdOrEmail, String subject, String status, String priority, String activityDate) {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/Tasks/';
        request.httpMethod = 'POST';

        Map<String, Object> taskBody = new Map<String, Object>();
        if (subject != null) taskBody.put('Subject', subject);
        if (status != null) taskBody.put('Status', status);
        if (priority != null) taskBody.put('Priority', priority);
        if (activityDate != null) taskBody.put('ActivityDate', activityDate);

        Map<String, Object> requestBody = new Map<String, Object>{
            'leadIdOrEmail' => leadIdOrEmail,
            'taskBody' => taskBody
        };
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = request;
        RestContext.response = new RestResponse();

        return TaskWebService.createTask();
    }
}
