public class CSVCreator  {

    public static List<List<String>> lines;
    public static List<CSVHeader> headers;
    public static List<String> listOfHeader;
    public static String message;

    private static List<String> separateCommas(String input){
        List<String> results = input.split(',');

        for(String result : results) {
            result = result.trim();
        }
        return results;
    }

    @AuraEnabled
    public static CSVObject getCSVObject(String csv_str) {

        List<String> lines_raw = csv_str.split('\n');
        List<String> headers_raw = separateCommas(lines_raw[0]);
        lines = new List<List<String>>();
        headers = new List<CSVHeader>();
        listOfHeader = new List<String>();

        // Eliminating column header
        lines_raw.remove(0);

        //Handling fields with commas
        for(String line : lines_raw) {
            List<String> line_sep = separateCommas(line);
            List<String> fields = new List<String>();
            Boolean makeCompositeField = false;
            String compositeField;
            for(String field : line_sep) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    fields.add(field.trim());
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    fields.add(compositeField.trim());
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    fields.add(field.trim());
                }
            }
            lines.add(fields);
            //System.debug('***lines***'+lines);
        }
        for(String header : headers_raw) {
            headers.add(new CSVHeader(header));
        }
        return new CSVObject(headers, lines);
    }

    // Create a picklist to show all the objects
    @AuraEnabled
    public static List<String> getObjectName() {

        List<string> SObjectList = new List<string>();

        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){

            String name = objTyp.getDescribe().getName();

            // Exclude all the unwanted Sobjects e.g. History, Share etc..
            if(!name.containsignorecase('history') && !name.containsignorecase('tag') &&
               !name.containsignorecase('share') && !name.containsignorecase('feed') &&
               !name.containsignorecase('npe') && !name.containsignorecase('trailheadapp') &&
               !name.containsignorecase('_mdt')){
                   SobjectList.add(name);
                   SobjectList.sort();
               }
        }
        System.debug('---SobjectList.size()---'+SobjectList.size());
        return SObjectList;
    }

    @AuraEnabled
    public static String columnHeader(String csv_str,string objectName) {

        message = '';
        System.debug('object Name :'+objectName);
        List<String> lines_raw = csv_str.split('\n');
        List<String> listColumn = lines_raw[0].split(',');
        System.debug('listColumn==>'+listColumn );

        //exclude coulumn Header
        lines_raw.remove(0);

        List<Map<String,Object>> list_AllValues = new List<Map<String,Object>>();
        Map<String,Object> map_StoreValues = new Map<String,Object>();
        List<SObject> listSobject = new List<SObject>();
        lines = new List<List<String>>();

        for (String iterateOverRows : lines_raw){

            List<String> line_sep = separateCommas(iterateOverRows);
            List<String> fields = new List<String>();
            Boolean makeCompositeField = false;
            String compositeField;

            for(String field : line_sep) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    fields.add(field.trim());
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    fields.add(compositeField.trim());
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    fields.add(field.trim());//store individual rows
                }
            }
            System.debug('---fields.size()---'+fields.size());
            if(fields.size() < listColumn.size()){
                fields.add('');
            }
            integer p = 0;
            SObject createObj = Schema.getGlobalDescribe().get(objectName).newSObject();
            System.debug('++listColumn.size()++'+listColumn.size());

            for(String iterateOverColumn : listColumn){

                String typeOfAccountfield = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(iterateOverColumn).getDescribe().getType().Name();
                System.debug('typeOfField '+iterateOverColumn +' is : '+typeOfAccountfield);

                if(typeOfAccountfield.equalsIgnoreCase('Integer')) {
                    createObj.put(iterateOverColumn, String.isBlank(fields.get(p))? null : Integer.valueOf(fields.get(p)) );
                }
                else if (typeOfAccountfield.equalsIgnoreCase('Boolean')){
                    createObj.put(iterateOverColumn,Boolean.valueOf(fields.get(p)) );
                }
                else if (typeOfAccountfield.equalsIgnoreCase('Currency')){
                    createObj.put(iterateOverColumn,Decimal.valueOf(fields.get(p)) );
                }
                else if (typeOfAccountfield.equalsIgnoreCase('double')){
                    createObj.put(iterateOverColumn,Double.valueOf(fields.get(p)) );
                }
                else if (typeOfAccountfield.equalsIgnoreCase('Reference')){
                    createObj.put(iterateOverColumn,ID.valueOf(fields.get(p)) );
                }
                else {
                    createObj.put(iterateOverColumn,fields.get(p));
                }
                map_StoreValues.put(iterateOverColumn,fields.get(p));
                p++;
            }
            listSobject.add(createObj);
            list_AllValues.add(map_StoreValues);
        }
        System.debug('--list_AllValues--'+list_AllValues.size());
        Database.insert(listSobject);
        message = 'Records Imported Successfully';

        // get the Id's of the inserted records
        for(SObject obj : listSobject ) {
            System.debug('-obj: '+obj.Id);
        }
        return message;
    }
}
