@isTest
public class OppTeamListControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test User
        User testUser = new User(
            Alias = 'otuser',
            Email = 'opptestuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'opptestuser' + DateTime.now().getTime() + '@example.com'
        );
        insert testUser;

        // Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'New',
            Event_type__c = 'Conference',
            Lead_Agency__c = 'Opus',
            Type = 'Repeat',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        // Insert Opportunity Team Member
        OpportunityTeamMember teamMember = new OpportunityTeamMember(
            OpportunityId = opp.Id,
            UserId = testUser.Id,
            TeamMemberRole = 'Account Manager'
        );
        insert teamMember;
    }

    @isTest
    static void testGetTeamMembers() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityTeamMember> members = OppTeamListController.getTeamMembers(opp.Id);
        System.assertNotEquals(0, members.size(), 'Should return opportunity team members');
    }

    @isTest
    static void testAddTeamMember() {
        User testUser = [SELECT Id FROM User LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        OppTeamListController.addTeamMember(opp.Id, testUser.Id, 'Sales Engineer');
        Test.stopTest();

        OpportunityTeamMember newMember = [
            SELECT Id FROM OpportunityTeamMember 
            WHERE OpportunityId = :opp.Id AND UserId = :testUser.Id AND TeamMemberRole = 'Sales Engineer' 
            LIMIT 1
        ];
        System.assertNotEquals(null, newMember, 'Opportunity Team Member should have been created');
    }

    @isTest
    static void testDeleteTeamMember() {
        OpportunityTeamMember memberToDelete = [SELECT Id FROM OpportunityTeamMember LIMIT 1];

        Test.startTest();
        OppTeamListController.deleteTeamMember(memberToDelete.Id);
        Test.stopTest();

        Integer count = [SELECT COUNT() FROM OpportunityTeamMember WHERE Id = :memberToDelete.Id];
        System.assertEquals(0, count, 'Team member should be deleted');
    }

    @isTest
    static void testHasCreatePermissionOnOpportunity() {
        Boolean result = OppTeamListController.hasCreatePermissionOnOpportunity();
        System.assertNotEquals(null, result, 'Should return a boolean');
    }
}
