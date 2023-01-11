public with sharing class DynamicObjectDatatableController {

    static Map<String, Schema.sObjectType> globalDescribeMap = Schema.getGlobalDescribe();
    
    @AuraEnabled(cacheable=true)
    public static List<DescribeColumnsWrapper> getObjectFields(String objectName) {
        List<DescribeColumnsWrapper> listOfFields = new List<DescribeColumnsWrapper>();
        String fieldSetName = objectName.replace('__c', 'List');

         
        Schema.sObjectType sobjType = globalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult describeSObjectResultObj = sobjType.getDescribe();
        Schema.FieldSet objFieldSet = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
    
        if(objFieldSet != null) {
            
            for(Schema.FieldSetMember member : objFieldSet.getFields()) {
                listOfFields.add(buildColWrapper(member.getSObjectField()));
            }
        } else {
            for(Schema.sObjectField member : describeSObjectResultObj.fields.getMap().values()) {
                listOfFields.add(buildColWrapper(member));
            }
        }
    
        return listOfFields;
    }  

    public static DescribeColumnsWrapper buildColWrapper(Schema.sObjectField field) {
        DescribeColumnsWrapper descCol = new DescribeColumnsWrapper();
        descCol.label = field.getDescribe().getLabel();
        descCol.fieldName = field.getDescribe().getName();

        return descCol;
    } 


    public class DescribeColumnsWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
    }

    @AuraEnabled
    public static List<sObject> getRecords(List<String> listOfFields, String objectName) {      
        String fieldsString = String.join(listOfFields, ', ');
        String query = String.format(       
            'SELECT {0} FROM {1}',
            new List<Object>{
            fieldsString, objectName 
            }
            );
        List<sObject> listOfRecords = Database.query(query);
        return listOfRecords;
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> searchRecords(String searchKey, String objectName, List<String> listOfFields){
        try {
            
            String fieldsString = String.join(listOfFields, ', ');
            String soqlStart = String.format('SELECT {0} FROM {1} WHERE ', new List<Object>{fieldsString, objectName});
            String soqlEnd = '';

            
            // Map<String, Schema.sObjectType> globalDescribeMap = Schema.getGlobalDescribe();                      // from above
            // Schema.sObjectType sobjType = globalDescribeMap.get(objectName);
            // Schema.DescribeSObjectResult describeSObjectResultObj = sobjType.getDescribe();
            // Schema.FieldSet objFieldSet = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

            Map<String, Schema.SObjectField> m = Schema.SObjectType.Reader__c.fields.getMap();
            
            
            // Map<String,Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();                       //copy of the above
            // Schema.SObjectType sobjType = globalDescribeMap.get('Reader__c');
            // Schema.DescribeSObjectResult describeResult = sobjType.getDescribe();
            // Schema.DisplayType FldType = describeResult.getType();
            
            // System.debug('m: ' + m);
            // System.debug('field: ' + field);
            // System.debug('fieldType: ' + fldType);

            // System.debug('global describe: ' + gd);
            // System.debug('sobjType: ' + sobjType); 
            // System.debug('describeResult: ' + describeResult);

            System.debug('listOfFields: ' + listOfFields);
            // Schema.DisplayType FldType = Name.getDescribe().getType();

            for(String el : listOfFields) {
                Schema.SObjectField field = m.get(el);
                Schema.DisplayType fldType = field.getDescribe().getType();
                // if(field)

                if(listOfFields.indexOf(el) < listOfFields.size() - 1) {
                    soqlEnd += '' + el + ' LIKE \'%' + searchKey + '%\' OR ';
                } else {
                    soqlEnd += '' + el + ' LIKE \'%' + searchKey + '%\'';
                }
            }
            String fullQuery = soqlStart + soqlEnd;

            List<sObject> searchResult = Database.query(fullQuery);
            
            return searchResult;                                                         
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}