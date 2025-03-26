import { LightningElement, api, wire, track } from 'lwc';
import getTeamMembers from '@salesforce/apex/OppTeamListController.getTeamMembers';
import addTeamMember from '@salesforce/apex/OppTeamListController.addTeamMember';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OppTeamList extends LightningElement {
    @api recordId;
    teamMembers = [];
    error;

    @track isModalOpen = false;
    selectedUserId;
    teamMemberRole;

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

    handleAddClick() {
        this.isModalOpen = true;
    }

    handleModalCancel() {
        this.isModalOpen = false;
        this.selectedUserId = undefined;
        this.teamMemberRole = '';
    }

    handleUserChange(event) {
        this.selectedUserId = event.detail.value[0]; 
    }       

    handleRoleChange(event) {
        this.teamMemberRole = event.detail.value;
    }

    async handleSave() {
        if (!this.selectedUserId || !this.teamMemberRole) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please fill out all required fields.',
                variant: 'error'
            }));
            return;
        }

        try {
            await addTeamMember({ 
                opportunityId: this.recordId, 
                userId: this.selectedUserId, 
                teamMemberRole: this.teamMemberRole 
            });
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Team Member added successfully.',
                variant: 'success'
            }));
            this.isModalOpen = false;
            return refreshApex(this.wiredTeamMembers);
        } catch (err) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error adding team member',
                message: err.body.message,
                variant: 'error'
            }));
        }
    }
}
