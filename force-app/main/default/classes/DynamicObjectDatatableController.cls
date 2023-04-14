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

            // Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Reader__c.fields.getMap();
            
            
            Boolean SearchKeyIsInteger = false;
            try{
                Integer searchKeyInt = Integer.valueOf(searchKey);
                SearchKeyIsInteger = true;
                    // for(String el : listOfFields) {
                    //     if(listOfFields.indexOf(el) < listOfFields.size() - 1) {
                    //         soqlEnd += '' + el + ' LIKE \'%' + searchKeyInt + '%\' OR ';
                    //     } else {
                    //         soqlEnd += '' + el + ' LIKE \'%' + searchKeyInt + '%\'';
                    //     }   
                    // }
            }catch(Exception SearchKeyIntegerEx){
                SearchKeyIsInteger = false;
            }

            List<String> listOfNumberFields = new List<String>();
            List<String> listOfStringFields = new List<String>();
            System.debug('listOfFields: ' + listOfFields);
            for(String el : listOfFields) {

                System.debug('el: ' + el);
            System.debug('method: ' + getFieldType(el));

                // String fieldType = String.valueOf(getFieldType(el));

                // String.valueOf(getFieldType(el));
                // if(SearchKeyIsInteger && fieldType == 'Integer') {
                //     listOfNumberFields.add(el);
                //     listOfFields = listOfNumberFields;
                //     System.debug('SearchKeyIsInteger: ' + listOfNumberFields);
                // } else {
                //     if(listOfFields.indexOf(el) < listOfFields.size() - 1) {
                //         soqlEnd += '' + el + ' LIKE \'%' + searchKey + '%\' OR ';
                //     } else {
                //         soqlEnd += '' + el + ' LIKE \'%' + searchKey + '%\'';
                //     }
                // }

            }
            String fullQuery = soqlStart + soqlEnd;
            // System.debug('startQuery: ' + soqlStart);
            // System.debug('endQuery: ' + soqlEnd);
            // System.debug('query: ' + fullQuery);

            List<sObject> searchResult = Database.query(fullQuery);
            // System.debug('searchResult: ' + searchResult);
            return searchResult;                                              
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Schema.DisplayType getFieldType(String fieldName) {
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
        Schema.DisplayType fieldType = fieldMap.get(fieldName).getDescribe().getType();
        System.debug('fieldType: ' + fieldType);
        return fieldType;
    }

}