@RestResource(urlMapping='/Leads')
global with sharing class LeadWebService {

    global class LeadResponse {
        public Boolean success;
        public String resultMessage;
        public Lead lead;
    }

    @HttpGet
    global static LeadResponse getLead() {
        LeadResponse leadResponse = new LeadResponse();
        
        try{
            RestRequest req = RestContext.request;
            String email = req.params.get('email');
            String leadId = req.params.get('leadId');

            if((Test.IsRunningTest() && leadId == 'testException')){
                throw new StringException('An exceptional situation has been tested.');
            }

            if (String.isBlank(leadId) && String.isBlank(email)) {
                return setResponse(leadResponse, 400, 'The request was unacceptable. Please provide the necessary parameters (Lead Id or Email address).');
            }

            if (!String.isBlank(leadId) && 
                (!leadId.startsWith('00Q') || !Pattern.matches('^(?:[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18})$', leadId))) {
                return setResponse(leadResponse, 400, 'Invalid Lead ID format. Please provide a valid Lead Id.');
            }


            if (!String.isBlank(email) && !Pattern.matches('^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$', email)) {
                return setResponse(leadResponse, 400, 'Invalid email format. Please provide a valid email address.');
            }

            List<Lead> leads = !String.isBlank(leadId) 
                ? [ SELECT Id, Name, Email, Company, Status, Phone, Title, Industry, Rating, CreatedDate 
                    FROM Lead 
                    WHERE Id = :leadId 
                    LIMIT 1] 
                : [ SELECT Id, Name, Email, Company, Status, Phone, Title, Industry, Rating, CreatedDate 
                    FROM Lead 
                    WHERE Email = :email 
                    LIMIT 1];
        
            leadResponse.lead = leads.isEmpty() ? null : leads[0];

            if (leadResponse.lead == null) {
                return setResponse(leadResponse, 404, 'Lead was not found');
            }else {
                return setResponse(leadResponse, 200, 'The request was successful');
            }

        }catch(Exception e){
            return setResponse(leadResponse, 500, 'An unexpected error occurred: ' + e.getMessage());
        }
    }

    private static LeadResponse setResponse(LeadResponse leadResponse, Integer statusCode, String message) {
        RestContext.response.statusCode = statusCode;
        leadResponse.resultMessage = message;
        leadResponse.success = (statusCode == 200); // Устанавливаем success в true, если код 200
        return leadResponse;
    }
}
