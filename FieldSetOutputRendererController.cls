public class FieldSetOutputRendererController {
    //Wrapper Class for hold field related information
    public class FieldsClass {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public Boolean required {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Boolean isUpdateable {get;set;}
        
        public FieldsClass(String label, Boolean required, String type, String name, Boolean isUpdatable) {
            this.label = label;
            this.required = required; 
            this.type = type;
            this.name = name;
            this.isUpdateable = isUpdatable;
        }
    }
    //Wrapper Class for hold field related information
    
    //Wrapper Class for Consolidate request result
    public class wrapperResult {
        @AuraEnabled
        Map<String , FieldsClass> mapFieldToFieldClass { get; set; }
        @AuraEnabled
        List<SObject> lstResult { get; set; }
        
        public wrapperResult(Map<String , FieldsClass> mapFieldToFieldClass, List<SObject> lstResult) {
            this.mapFieldToFieldClass = mapFieldToFieldClass;
            this.lstResult = lstResult; 
        }
    }
    //Wrapper Class for Consolidate request result
    
    //Initialize Component
    @AuraEnabled    
    public static wrapperResult getResult(String strObjName,String strFieldSetName, String strRecordId) {
        map<String , FieldsClass> mapFieldToFieldClass = new map<String, FieldsClass>();
        wrapperResult objWrapper;        
        
        if(string.isNotEmpty(strObjName) && string.isNotEmpty(strFieldSetName)){
            //Get Object Details
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(strObjName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            Map<String, Schema.SObjectField> describeObjectFields = SObjectTypeObj.getDescribe().fields.getMap();
            //Get Object Details
            
            //Get FieldSet Details
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(strFieldSetName);
            Set<String> setReferenceToAdd = new set<String>();    
            List<Schema.FieldSetMember> fieldset =  fieldSetObj.getFields();
            //Get FieldSet Details
            
            String query = 'SELECT ';
            
            for(Schema.FieldSetMember f : fieldset) {
                String fieldType = String.valueOf(f.getType());
                //Check if field type is textarea or is html enabled
                if(describeObjectFields.get(f.getFieldPath()).getDescribe().getType() == Schema.DisplayType.TEXTAREA 
                   && describeObjectFields.get(f.getFieldPath()).getDescribe().isHtmlFormatted())
                {
                    fieldType = 'richtextArea';
                }
                //Check if field type is textarea or is html enabled
                
                //Add element in field map
                mapFieldToFieldClass.put(f.getFieldPath(), new FieldsClass(f.getLabel(), (f.getDBRequired() || f.getRequired()), fieldType, f.getFieldPath(), Boolean.valueOf(describeObjectFields.get(f.getFieldPath()).getDescribe().isUpdateable())));
                //Add element in field map
                
                //Create Dynamic query to fetch data
                query += f.getFieldPath() + ',';
                //Create Dynamic query to fetch data
            }
            //Create Dynamic query to fetch data
            
            //remove last comma
            if(query.substring(query.length()-1) == ','){
                query = query.substring(0, query.length()-1);
            }
            //remove last comma
            
            query += ' FROM '+strObjName+' Where Id =:strRecordId LIMIT 1';
            System.debug('Query--'+query);
            //Create Dynamic query to fetch data
            List<SObject> lstResult = Database.query(query);
            //Fill Data in Wrapper Class
            
            objWrapper = new wrapperResult(mapFieldToFieldClass, lstResult);
            //Fill Data in Wrapper Class
        }
        return objWrapper;
    }
    //Initialize Component
    
}