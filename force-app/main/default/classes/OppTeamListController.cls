public without sharing class OppTeamListController {
    
    @AuraEnabled(cacheable=true)
    public static List<OpportunityTeamMember> getTeamMembers(Id opportunityId) {
        try {
            if (opportunityId == null) {
                throw new AuraHandledException('Opportunity Id must not be null.');
            }
            return [
                SELECT Id, UserId, User.Name, TeamMemberRole
                FROM OpportunityTeamMember
                WHERE OpportunityId = :opportunityId
                ORDER BY User.Name ASC
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Error fetching team members: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static void addTeamMember(Id opportunityId, Id userId, String teamMemberRole) {
        try {
            if (opportunityId == null || userId == null || String.isBlank(teamMemberRole)) {
                throw new AuraHandledException('All parameters (opportunityId, userId, teamMemberRole) are required.');
            }

            OpportunityTeamMember newMember = new OpportunityTeamMember(
                OpportunityId = opportunityId,
                UserId = userId,
                TeamMemberRole = teamMemberRole
            );
            insert newMember;
        } catch (DmlException dmlEx) {
            throw new AuraHandledException('Failed to add team member: ' + dmlEx.getMessage());
        } catch (Exception ex) {
            throw new AuraHandledException('Unexpected error while adding team member: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteTeamMember(Id teamMemberId) {
        try {
            if (teamMemberId == null) {
                throw new AuraHandledException('Team Member Id must not be null.');
            }

            OpportunityTeamMember memberToDelete = [
                SELECT Id FROM OpportunityTeamMember WHERE Id = :teamMemberId
                LIMIT 1
            ];
            delete memberToDelete;
        } catch (QueryException qEx) {
            throw new AuraHandledException('Team member not found: ' + qEx.getMessage());
        } catch (DmlException dmlEx) {
            throw new AuraHandledException('Failed to delete team member: ' + dmlEx.getMessage());
        } catch (Exception ex) {
            throw new AuraHandledException('Unexpected error while deleting team member: ' + ex.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean hasCreatePermissionOnOpportunity() {
        try {
            return Schema.sObjectType.Opportunity.isCreateable();
        } catch (Exception ex) {
            throw new AuraHandledException('Error checking Create permissions: ' + ex.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean hasDeletePermissionOnOpportunity() {
        try {
            return Schema.sObjectType.Opportunity.isDeletable();
        } catch (Exception ex) {
            throw new AuraHandledException('Error checking Delete permissions: ' + ex.getMessage());
        }
    }
}
