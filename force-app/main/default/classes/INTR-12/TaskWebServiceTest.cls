@IsTest
public class TaskWebServiceTest {

    @IsTest
    static void testCreateTaskWithLeadId() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest(lead.Id, 'Call', 'Not Started', 'Normal', '2024-11-05');
        System.assertEquals(true, response.success);
        System.assertEquals('The task was successfully created.', response.resultMessage);
        System.assertNotEquals(null, response.task);
        System.assertEquals('Call', response.task.Subject);
        System.assertEquals('Not Started', response.task.Status);
        System.assertEquals('Normal', response.task.Priority);
    }

    @IsTest
    static void testCreateTaskWithLeadEmail() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest('testlead@example.com', 'Meeting', 'In Progress', 'High', '2024-11-05');
        System.assertEquals(true, response.success);
        System.assertEquals('The task was successfully created.', response.resultMessage);
        System.assertNotEquals(null, response.task);
        System.assertEquals('Meeting', response.task.Subject);
        System.assertEquals('In Progress', response.task.Status);
        System.assertEquals('High', response.task.Priority);
    }

    @IsTest
    static void testInvalidLeadIdFormat() {
        TaskWebService.TaskResponse response = createTaskRequest('invalidLeadId', 'Call', 'Completed', 'Low', null);
        System.assertEquals(false, response.success);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('Invalid input of leadIdOrEmail parameter.', response.resultMessage);
    }

    @IsTest
    static void testInvalidEmailFormat() {
        TaskWebService.TaskResponse response = createTaskRequest('invalid@Email', 'Call', 'Waiting on someone else', 'High', null);
        System.assertEquals(false, response.success);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('Invalid email format. Please provide a valid email address.', response.resultMessage);
    }

    @IsTest
    static void testEmptyLeadIdOrEmail() {
        TaskWebService.TaskResponse response = createTaskRequest(null, 'Call', 'Not Started', 'Normal', null);
        System.assertEquals(false, response.success);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('Parameter leadIdOrNone is empty. Please provide the necessary parameters (Lead Id or Email address).', response.resultMessage);
    }

    @IsTest
    static void testTaskBodyMissingFields() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        // Subject is missing
        TaskWebService.TaskResponse response = createTaskRequest(lead.Id, null, 'Not Started', 'Normal', null);
        System.assertEquals(false, response.success);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('The Subject field is required.', response.resultMessage);
    }

    @IsTest
    static void testInvalidStatusValue() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest(lead.Id, 'Call', 'InvalidStatus', 'Normal', null);
        System.assertEquals(false, response.success);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('Invalid value of the Status field', response.resultMessage);
    }

    @IsTest
    static void testInvalidPriorityValue() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest(lead.Id, 'Call', 'Not Started', 'InvalidPriority', null);
        System.assertEquals(false, response.success);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('Invalid value of the Priority field', response.resultMessage);
    }

    @IsTest
    static void testInvalidDateFormat() {
        Lead lead = new Lead(LastName = 'Test', Company = 'TestCompany', Email = 'testlead@example.com');
        insert lead;

        TaskWebService.TaskResponse response = createTaskRequest(lead.Id, 'Call', 'Not Started', 'Normal', 'invalidDate');
        System.assertEquals(false, response.success);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('Date format is invalid.', response.resultMessage);
    }

    @IsTest
    static void testLeadNotFound() {
        TaskWebService.TaskResponse response = createTaskRequest('00Q000000000000AAA', 'Call', 'Not Started', 'Normal', null);
        System.assertEquals(false, response.success);
        System.assertEquals(404, RestContext.response.statusCode);
        System.assertEquals('Lead was not found', response.resultMessage);
    }

    @IsTest
    static void testUnexpectedError() {
        TaskWebService.TaskResponse response = createTaskRequest('testException', 'Call', 'Not Started', 'Normal', null);
        System.assertEquals(false, response.success);
        System.assertEquals(500, RestContext.response.statusCode);
        System.assertEquals('An unexpected error occurred: An exceptional situation was tested.', response.resultMessage);
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
