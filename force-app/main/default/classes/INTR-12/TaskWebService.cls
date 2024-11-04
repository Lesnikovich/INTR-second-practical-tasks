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
        Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        String leadIdOrEmail = (String) requestBody.get('leadIdOrEmail');
        Map<String, Object> taskBody = (Map<String, Object>) requestBody.get('taskBody');
        
        Task newTask = new Task();

        // Проверка leadIdOrEmail
        if (String.isBlank(leadIdOrEmail)) {
            return setResponse(taskResponse, 400, 'The request was unacceptable. Please provide the necessary parameters (Lead Id or Email address).');
        }

        // Обработка email
        if (leadIdOrEmail.contains('@')) {
            if (!Pattern.matches('^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$', leadIdOrEmail)) {
                return setResponse(taskResponse, 400, 'Invalid email format. Please provide a valid email address.');
            }

            List<Lead> leads = [SELECT Id FROM Lead WHERE Email = :leadIdOrEmail LIMIT 1];

            if (leads.isEmpty()) {
                return setResponse(taskResponse, 404, 'Lead was not found');
            }

            newTask.WhoId = leads[0].Id;
        } else {
            if (!leadIdOrEmail.startsWith('00Q') || !Pattern.matches('^(?:[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18})$', leadIdOrEmail)) {
                return setResponse(taskResponse, 400, 'Invalid Lead ID format. Please provide a valid Lead Id.');
            }

            newTask.WhoId = leadIdOrEmail;
        }

        // Присвоение атрибутов Task
        if (taskBody != null) {
            if (taskBody.containsKey('Subject')) {
                newTask.Subject = (String) taskBody.get('Subject');
            }
            if (taskBody.containsKey('Status')) {
                newTask.Status = (String) taskBody.get('Status');
            }
            if (taskBody.containsKey('Priority')) {
                newTask.Priority = (String) taskBody.get('Priority');
            }
        }

        insert newTask;
        taskResponse.task = newTask; // Сохранение созданной задачи в ответе
        return taskResponse;
    }

    private static TaskResponse setResponse(TaskResponse taskResponse, Integer statusCode, String message) {
        RestContext.response.statusCode = statusCode;
        taskResponse.resultMessage = message;
        taskResponse.success = (statusCode == 201); // Устанавливаем success в true, если код 201
        return taskResponse;
    }
}
