import { LightningElement, api, wire } from 'lwc';
import readFieldSet from '@salesforce/apex/DynamicObjectDatatableController.readFieldSet';
import getRecordFields from '@salesforce/apex/DynamicObjectDatatableController.getRecordFields';

export default class DynamicObjectDatatable extends LightningElement {
    listRecs;  
    error;
    recordsError;
    columns;  
 
    @api fields;
    @api tableColumns;
    @api objectApiName;
    @api recordPage;

    @wire(readFieldSet, {objectName: '$objectApiName'})
    wiredFieldSet({ error, data }) {
        if (data) {
            this.columns = data.filter((el)=> el.fieldName !== 'Id');       
            this.error = undefined;
            console.log('data: ', data);
            let fields = this.columns.map(x => x.fieldName);
            console.log('fields: ', fields);
            getRecordFields({listOfFields: fields, objectName: this.objectApiName})
                .then(result => {
                    this.listRecs = result;
                    console.log('result: ', result);
                })
                .catch(recordsError => {
                    this.recordsError = recordsError;
                });
            return fields;
        } else if (error) {
            this.error = error;
            this.columns = undefined;
            console.log('Error: ', error);
        }
        return 'error: out of ifs';
    }
}
    
    
