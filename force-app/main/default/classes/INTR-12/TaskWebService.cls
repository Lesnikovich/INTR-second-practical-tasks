@RestResource(urlMapping='/Tasks/*')
global with sharing class TaskWebService {

    global class TaskResponse {
        public Boolean success;
        public String resultMessage;
        public Task task;
    }

    @HttpPost
    global static TaskResponse createTask() {
        TaskResponse taskResponse = new TaskResponse();
        Task newTask = new Task();
        
        try{
            Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            String leadIdOrEmail = (String) requestBody.get('leadIdOrEmail');
            Map<String, Object> taskBody = (Map<String, Object>) requestBody.get('taskBody');
            
            if((Test.IsRunningTest() && leadIdOrEmail == 'testException')){
                throw new StringException('An exceptional situation was tested.');
            }
            
            if (String.isBlank(leadIdOrEmail)) {
                return setResponse(taskResponse, 400, 'Parameter leadIdOrEmail is empty. Please provide the necessary parameters (Lead Id or Email address).');
            }

            if (taskBody == null || taskBody.isEmpty()) {
                return setResponse(taskResponse, 400, 'Parameter taskBody is empty. Please complete taskBody with valid Task values.');
            }

            if (leadIdOrEmail.contains('@')) {
                if (!Pattern.matches('^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$', leadIdOrEmail)) {
                    return setResponse(taskResponse, 400, 'Invalid email format. Please provide a valid email address.');
                }

                List<Lead> leads = [SELECT Id FROM Lead WHERE Email = :leadIdOrEmail LIMIT 1];

                if (leads.isEmpty()) {
                    return setResponse(taskResponse, 404, 'Lead was not found');
                }

                newTask.WhoId = leads[0].Id;
            } else if(leadIdOrEmail.startsWith('00Q')){
                if (!Pattern.matches('^(?:[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18})$', leadIdOrEmail)) {
                    return setResponse(taskResponse, 400, 'Invalid Lead ID format. Please provide a valid Lead Id.');
                }

                List<Lead> leads = [SELECT Id FROM Lead WHERE Id = :leadIdOrEmail LIMIT 1];

                if (leads.isEmpty()) {
                    return setResponse(taskResponse, 404, 'Lead was not found');
                }

                newTask.WhoId = leadIdOrEmail;
            }else{
                return setResponse(taskResponse, 400, 'Invalid input of leadIdOrEmail parameter.');
            }

            
            if (taskBody.containsKey('Subject') && !String.isBlank((String)taskBody.get('Subject'))) {
                newTask.Subject = (String) taskBody.get('Subject');
            }else{
                return setResponse(taskResponse, 400, 'The Subject field is required.');
            }

            if (taskBody.containsKey('Status') && !String.isBlank((String)taskBody.get('Status'))){
                Set<String> validStatuses = new Set<String>{'Not Started', 'In Progress', 'Completed', 'Waiting on someone else', 'Deferred'};
                String status = (String)taskBody.get('Status');
                if(validStatuses.contains(status)){
                    newTask.Status = status;
                }else{
                    return setResponse(taskResponse, 400, 'Invalid value of the Status field');
                }          
            }else{
                return setResponse(taskResponse, 400, 'The Status field is required.');
            }

            if (taskBody.containsKey('Priority') && !String.isBlank((String)taskBody.get('Priority'))) {
                Set<String> validPriorities = new Set<String>{'Low', 'Normal', 'High'};
                String priority = (String)taskBody.get('Priority');
                if(validPriorities.contains(priority)){
                    newTask.Priority = priority;
                }else{
                    return setResponse(taskResponse, 400, 'Invalid value of the Priority field');
                }
            }else{
                return setResponse(taskResponse, 400, 'The Priority field is required.');
            }

            try {
                if (taskBody.containsKey('ActivityDate')) {
                    newTask.ActivityDate = Date.valueOf((String) taskBody.get('ActivityDate'));
                }
            } catch (Exception e){
                return setResponse(taskResponse, 400, 'Date format is invalid.');
            }

            insert newTask;
            taskResponse.task = newTask;
            return setResponse(taskResponse, 201, 'The task was successfully created.');

        }catch(Exception e){
            return setResponse(taskResponse, 500, 'An unexpected error occurred: ' + e.getMessage());
        }
    }

    private static TaskResponse setResponse(TaskResponse taskResponse, Integer statusCode, String message) {
        RestContext.response.statusCode = statusCode;
        taskResponse.resultMessage = message;
        taskResponse.success = (statusCode == 201); 
        return taskResponse;
    }
}
