import { LightningElement, api, wire } from 'lwc';
import getTeamMembers from '@salesforce/apex/OppTeamListController.getTeamMembers';

export default class OppTeamList extends LightningElement {
    @api recordId;
    teamMembers = [];
    error;

    columns = [
        { label: 'Team Member', fieldName: 'userName', type: 'text' },
        { label: 'Member Role', fieldName: 'TeamMemberRole', type: 'text' }
    ];

    @wire(getTeamMembers, { opportunityId: '$recordId' })
    wiredTeamMembers({ data, error }) {
        if (data) {
            this.teamMembers = data.map(member => ({
                ...member,
                userName: member.User?.Name
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.teamMembers = [];
        }
    }
}
