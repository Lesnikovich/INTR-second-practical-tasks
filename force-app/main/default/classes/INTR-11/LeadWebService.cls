@RestResource(urlMapping='/Leads/*')
global with sharing class LeadWebService {

    global class LeadResponse {
        public Boolean success;
        public String resultMessage;
        public Lead lead;
    }

    @HttpGet
    global static LeadResponse getLead() {
        LeadResponse leadResponse = new LeadResponse();
        List<Lead> leads = new List<Lead>();
        
        try{
            RestRequest req = RestContext.request;
            String leadIdOrEmail = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

            if((Test.IsRunningTest() && leadIdOrEmail == 'testException')){
                throw new StringException('An exceptional situation has been tested.');
            }

            if (String.isBlank(leadIdOrEmail)) {            
                return setResponse(leadResponse, 400, 'The request was unacceptable. Please provide the necessary valid parameters (Lead Id or Email address).');
            }

            if(leadIdOrEmail.contains('@')){
                if (!Pattern.matches('^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$', leadIdOrEmail)) {
                    return setResponse(leadResponse, 400, 'Invalid email format. Please provide a valid email address.');
                }

                leads = 
                    [ SELECT Id, Name, Email, Company, Status, Phone, Title, Industry, Rating, CreatedDate 
                      FROM Lead 
                      WHERE Email = :leadIdOrEmail 
                      LIMIT 1];
            }else if(leadIdOrEmail.startsWith('00Q')){
                if(!Pattern.matches('^(?:[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18})$', leadIdOrEmail)){
                    return setResponse(leadResponse, 400, 'Invalid Lead ID format. Please provide a valid Lead Id.');
                }
                
                leads =
                    [ SELECT Id, Name, Email, Company, Status, Phone, Title, Industry, Rating, CreatedDate 
                      FROM Lead 
                      WHERE Id = :leadIdOrEmail
                      LIMIT 1];
            }else{
                return setResponse(leadResponse, 400, 'The request was unacceptable. Please provide the necessary valid parameters (Lead Id or Email address).');
            }

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
        leadResponse.success = (statusCode == 200);
        return leadResponse;
    }
}
