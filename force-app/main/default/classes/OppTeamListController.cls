public with sharing class OppTeamListController {
    @AuraEnabled(cacheable=true)
    public static List<OpportunityTeamMember> getTeamMembers(Id opportunityId) {
        return [
            SELECT Id, UserId, User.Name, TeamMemberRole
            FROM OpportunityTeamMember
            WHERE OpportunityId = :opportunityId
            ORDER BY User.Name ASC
        ];
    }
    @AuraEnabled
    public static void addTeamMember(Id opportunityId, Id userId, String teamMemberRole) {
        OpportunityTeamMember newMember = new OpportunityTeamMember(
            OpportunityId = opportunityId,
            UserId = userId,
            TeamMemberRole = teamMemberRole
        );
        insert newMember;
    }
    @AuraEnabled
    public static void deleteTeamMember(Id teamMemberId) {
        delete [SELECT Id FROM OpportunityTeamMember WHERE Id = :teamMemberId];
    }
}
