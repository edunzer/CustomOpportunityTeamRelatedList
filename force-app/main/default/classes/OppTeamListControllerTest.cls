@isTest
private class OppTeamListControllerTest {
    private static Id testOppId;
    private static Id testUserId;

    @testSetup
    static void setupTestData() {
        // Create test User
        Profile testProfile = [
            SELECT Id 
            FROM Profile 
            WHERE Name = 'FullSeat - User - Lvl 1' 
            LIMIT 1
        ];

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'otuser',
            Email = 'opptestuser@example.com',
            Username = 'opptestuser' + DateTime.now().getTime() + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = testProfile.Id
        );
        insert testUser;
        testUserId = testUser.Id;

        // Get Record Type for Account - Customer
        RecordType customerRT = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'Account' AND Name = 'Account - Customer' 
            LIMIT 1
        ];

        // Create test Customer Account
        Account customerAccount = new Account(
            Name = 'Test Customer Account',
            Type = 'Customer',
            Industry = 'Technology',
            RecordTypeId = customerRT.Id
        );
        insert customerAccount;

        // Custom pricebook
        Pricebook2 customPb = new Pricebook2(Name = 'Test Pricebook', IsActive = true);
        insert customPb;

        Product2 prod = new Product2(Name = 'Test Product', ProductCode = 'TP-001', IsActive = true);
        insert prod;

        Id standardPbId = Test.getStandardPricebookId();
        update new Pricebook2(Id = standardPbId, IsActive = true);

        insert new PricebookEntry(Pricebook2Id = standardPbId, Product2Id = prod.Id, UnitPrice = 100, IsActive = true);
        insert new PricebookEntry(Pricebook2Id = customPb.Id, Product2Id = prod.Id, UnitPrice = 100, IsActive = true);

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'New',
            Event_type__c = 'Conference',
            Lead_Agency__c = 'Opus',
            Type = 'Repeat',
            CloseDate = Date.today().addDays(30),
            Pricebook2Id = customPb.Id,
            OwnerId = testUserId,
            AccountId = customerAccount.Id
        );
        insert opp;
        testOppId = opp.Id;

        OpportunityTeamMember teamMember = new OpportunityTeamMember(
            OpportunityId = opp.Id,
            UserId = testUser.Id,
            TeamMemberRole = 'Opus Account Manager'
        );
        insert teamMember;
    }

    @isTest
    static void testGetTeamMembers() {
        Test.startTest();
        List<OpportunityTeamMember> members = OppTeamListController.getTeamMembers(testOppId);
        Test.stopTest();

        System.assertNotEquals(0, members.size(), 'Team members should be returned');
        System.assertEquals('Opus Account Manager', members[0].TeamMemberRole);
    }

    @isTest
    static void testAddTeamMember() {
        User anotherUser = [SELECT Id FROM User WHERE Id != :testUserId LIMIT 1];

        Test.startTest();
        OppTeamListController.addTeamMember(testOppId, anotherUser.Id, 'Opus Account Manager');
        Test.stopTest();

        List<OpportunityTeamMember> added = [
            SELECT Id, UserId, TeamMemberRole FROM OpportunityTeamMember
            WHERE OpportunityId = :testOppId AND UserId = :anotherUser.Id
        ];
        System.assertEquals(1, added.size(), 'Team member should have been added');
        System.assertEquals('Opus Account Manager', added[0].TeamMemberRole);
    }

    @isTest
    static void testDeleteTeamMember() {
        OpportunityTeamMember memberToDelete = [
            SELECT Id FROM OpportunityTeamMember
            WHERE OpportunityId = :testOppId AND UserId = :testUserId
            LIMIT 1
        ];

        Test.startTest();
        OppTeamListController.deleteTeamMember(memberToDelete.Id);
        Test.stopTest();

        List<OpportunityTeamMember> remaining = [
            SELECT Id FROM OpportunityTeamMember
            WHERE OpportunityId = :testOppId AND UserId = :testUserId
        ];
        System.assertEquals(0, remaining.size(), 'Team member should be deleted');
    }

    @isTest
    static void testHasCreatePermissionOnOpportunity() {
        Test.startTest();
        Boolean hasPermission = OppTeamListController.hasCreatePermissionOnOpportunity();
        Test.stopTest();
        System.assertEquals(true, hasPermission, 'Should return true if user has create permission');
    }
}
