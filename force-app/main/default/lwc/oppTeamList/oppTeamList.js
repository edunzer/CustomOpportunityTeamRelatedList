import { LightningElement, api, wire, track } from 'lwc';
import getTeamMembers from '@salesforce/apex/OppTeamListController.getTeamMembers';
import addTeamMember from '@salesforce/apex/OppTeamListController.addTeamMember';
import deleteTeamMember from '@salesforce/apex/OppTeamListController.deleteTeamMember';
import hasCreatePermissionOnOpportunity from '@salesforce/apex/OppTeamListController.hasCreatePermissionOnOpportunity';
import hasDeletePermissionOnOpportunity from '@salesforce/apex/OppTeamListController.hasDeletePermissionOnOpportunity';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class OppTeamList extends LightningElement {
    @api recordId;
    teamMembers = [];
    error;

    @track hasCreatePermission = false;

    @track isModalOpen = false;
    selectedUserId;
    teamMemberRole;

    columns = [
        { label: 'Team Member', fieldName: 'userName', type: 'text' },
        { label: 'Member Role', fieldName: 'TeamMemberRole', type: 'text' }
    ];

    connectedCallback() {
        hasCreatePermissionOnOpportunity().then(permission => {
            this.hasCreatePermission = permission;

            hasDeletePermissionOnOpportunity().then(canDelete => {
                if (this.hasCreatePermission && canDelete) {
                    this.columns = [
                        ...this.columns,
                        {
                            type: 'action',
                            typeAttributes: { rowActions: [{ label: 'Delete', name: 'delete' }] 
                            }
                        }
                    ];
                }
            });
        });
    }

    @wire(getTeamMembers, { opportunityId: '$recordId' })
    wiredTeamMembers(result) {
        this.wiredResult = result;
        const { data, error } = result;
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

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
    
        if (actionName === 'delete') {
            this.handleDelete(row.Id);
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
            this.selectedUserId = undefined;
            this.teamMemberRole = '';
            await refreshApex(this.wiredResult);

        } catch (err) {
            const message = err?.body?.message || err?.message || 'An unknown error occurred.';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error adding team member',
                message: message,
                variant: 'error'
            }));
        }        
    }

    async handleDelete(teamMemberId) {
        try {
            await deleteTeamMember({ teamMemberId });
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Team Member deleted successfully.',
                variant: 'success'
            }));
            await refreshApex(this.wiredResult);
        } catch (err) {
            const message = err?.body?.message || err?.message || 'An unknown error occurred.';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error deleting team member',
                message: message,
                variant: 'error'
            }));
        }
    }
    
}
