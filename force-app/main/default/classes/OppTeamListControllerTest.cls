@isTest
private class OppTeamListControllerTest {

    @isTest
    static void testGetTeamMembers_WithNullId() {
        Boolean exceptionThrown = false;
        try {
            OppTeamListController.getTeamMembers(null);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Expected AuraHandledException to be thrown');
    }       
    
    @isTest
    static void testAddTeamMember_WithInvalidIds() {
        Boolean exceptionThrown = false;
        try {
            Id fakeOppId = '006000000000001';
            Id fakeUserId = '005000000000001';
            String role = 'FakeRole';
    
            Test.startTest();
            OppTeamListController.addTeamMember(fakeOppId, fakeUserId, role);
            Test.stopTest();
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Expected AuraHandledException to be thrown');
    }      

    @isTest
    static void testAddTeamMember_WithMissingParams() {
        Boolean exceptionThrown = false;
        try {
            OppTeamListController.addTeamMember(null, null, '');
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Expected AuraHandledException to be thrown');
    }    
    
    @isTest
    static void testDeleteTeamMember_WithNullId() {
        Boolean exceptionThrown = false;
        try {
            OppTeamListController.deleteTeamMember(null);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Expected AuraHandledException to be thrown');
    } 
    
    @isTest
    static void testDeleteTeamMember_WithInvalidId() {
        Boolean exceptionThrown = false;
        try {
            Id fakeTeamMemberId = '00k000000000001';
            OppTeamListController.deleteTeamMember(fakeTeamMemberId);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Expected AuraHandledException to be thrown');
    }
    
    @isTest
    static void testHasCreatePermissionOnOpportunity() {
        Boolean result = OppTeamListController.hasCreatePermissionOnOpportunity();
        System.assertEquals(true, result); // Should reflect actual org permission
    }

    @isTest
    static void testHasDeletePermissionOnOpportunity() {
        Boolean result = OppTeamListController.hasDeletePermissionOnOpportunity();
        System.assertEquals(true, result); // Should reflect actual org permission
    }
}
