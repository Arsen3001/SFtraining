public with sharing class DynamicObjectDatatableController {
    
    @AuraEnabled(cacheable=true)
    public static List<DescribeColumnsWrapper> readFieldSet(String objectName) {
    List<DescribeColumnsWrapper> listOfFields = new List<DescribeColumnsWrapper>();
    List<Schema.FieldSetMember> objectFields = new List<Schema.FieldSetMember>();
    String fieldSetName = objectName.replace('__c', '') + 'List';

    Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
    Schema.SObjectType anSObjectType = globalDescribeMap.get(objectName);
    Schema.DescribeSObjectResult describeSObjectResultObj = anSObjectType.getDescribe();

    Schema.FieldSet objFieldSet = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
    if(objFieldSet != null) {
    objectFields = objFieldSet.getFields();
    for(Schema.FieldSetMember member : objectFields) {
        listOfFields.add(buildColWrapper(member.getSObjectField()));
    }
    } else {
        Map<String,Schema.SObjectField> mfields = describeSObjectResultObj.fields.getMap();
        for(Schema.SObjectField member : mfields.values()) {
            listOfFields.add(buildColWrapper(member));
        }
    }
    
    return listOfFields;
    }  

    public static DescribeColumnsWrapper buildColWrapper(Schema.SObjectField field) {
        DescribeColumnsWrapper descCol = new DescribeColumnsWrapper();
        descCol.label = field.getDescribe().getLabel();
        descCol.fieldName = field.getDescribe().getName();
        // descCol.type = field.getDescribe().getType();

        return descCol;
    } 


    public class DescribeColumnsWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        // @AuraEnabled public Schema.DisplayType type;
    }

    @AuraEnabled
    public static List<SObject> getRecordFields(List<String> listOfFields, String objectName) {      
        String fieldsString = String.join(listOfFields, ', ');
        String query = String.format(       
            'SELECT {0} FROM {1}',
            new List<Object>{
            fieldsString, objectName 
            }
            );
            System.debug(query);
        List<SObject> listRecs = Database.query(query);
        System.debug(listRecs);
        return listRecs;
    }

}