@isTest
public class DailyOutdatedContactsTest {
    @testSetup
    static void setupData() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com', 
            ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            contacts.add(new Contact(
                LastName = 'Outdated ' + i,
                OwnerId = testUser.Id,
                Is_Outdated__c = true
            ));
        }
        insert contacts;
    }
    
    @isTest
    static void testDailyOutdatedContactsSchedule() {
        Test.startTest();
        String cronExp = '0 0 0 * * ?';
        System.schedule('Test DailyOutdatedContactsSchedule', cronExp, new DailyOutdatedContactsSchedule());
        Test.stopTest();
    }
}


