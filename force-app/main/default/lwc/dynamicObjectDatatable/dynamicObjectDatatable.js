import { LightningElement, api, wire, track } from 'lwc';
import getObjectFields from '@salesforce/apex/DynamicObjectDatatableController.getObjectFields';
import getRecords from '@salesforce/apex/DynamicObjectDatatableController.getRecords';
import searchRecords from '@salesforce/apex/DynamicObjectDatatableController.searchRecords';

export default class DynamicObjectDatatable extends LightningElement {
    @track data;
    @track listOfRecords;
    @track error;
    @track columns;  
 
    @api fields;
    @api objectApiName;
    

    @wire(getObjectFields, {objectName: '$objectApiName'})
    async wiredFieldSet({ error, data }) {
        if (data) {
            this.columns = data.filter((el) => el.fieldName !== 'Id');       
            this.error = undefined;
            let fields = this.columns.map(el => el.fieldName);
            try {
                this.listOfRecords = await getRecords({listOfFields: fields, objectName: this.objectApiName});                
            } catch (recordsError) {
                this.error = recordsError;
            }
        } else if (error) {
            this.error = error;
            this.columns = undefined;
        }
    }

    handleSearch(event) {
        const key = event.target.value.toLowerCase();
        let fields = this.columns.map(el => el.fieldName);
       
        searchRecords({searchKey: key, objectName: this.objectApiName, listOfFields: fields})
            .then(result => {
                this.listOfRecords = result;
            })
            .catch(searchError => {
                this.error = searchError; 
            });
        }
        
}
    
    
