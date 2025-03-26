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
}
