public class DailyOutdatedContactsBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name, OwnerId FROM Contact WHERE Is_Outdated__c = TRUE]);
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        Map<Id, List<Contact>> contactsByOwner = new Map<Id, List<Contact>>();
        for(Contact contact : scope) {
            if(!contactsByOwner.containsKey(contact.OwnerId)) {
                contactsByOwner.put(contact.OwnerId, new List<Contact>());
            }
            contactsByOwner.get(contact.OwnerId).add(contact);
        }

        for(Id ownerId : contactsByOwner.keySet()) {
            List<Contact> ownerContacts = contactsByOwner.get(ownerId);
            String body = 'Contacts that need review:<br>';
            for(Contact contact : ownerContacts) {
                body += '• <a href="https://resourceful-fox-fe02sd-dev-ed.trailblaze.lightning.force.com/lightning/r/Contact/' 
                        + contact.Id + '/view">' + contact.Name + '</a><br>';
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('The list of possible outdated Contacts that needs review!');
            mail.setToAddresses(new String[] { [SELECT Email FROM User WHERE Id = :ownerId].Email });
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    public void finish(Database.BatchableContext bc) {
          
    }
}