/**
@author Team STARK
@owner Team Stark
@name UTIL_XMLParser
@createDate 03/12/20202
@modifiedDate 
@description This utility class is used to convert XML data to JSON data
@version 1.0
*/
public without sharing class UTIL_XMLParser {
    // To find the root element so that we can enclose it in the curly braces 
    public static String rootElementName;
     
    /**
    * @description Method which is parsing the XML content into JSON 
    * @name : xmlToJson
    * @param xml : input xml string
    * @return String : json string
    */
     public static String xmlToJson(String xml) {
        // Load the xml in the document
        Dom.Document doc = new Dom.Document();
        doc.load(xml);
        Dom.XMLNode root = doc.getRootElement();
        // Pass the root element and false as the second parameter
        String jsonContent = UTIL_XMLParser.parse(root, false);
        return jsonContent;
    }
     
    /** @description : Method which makes the recursive calls and creates the JSON for
     * each element, it processes each node and finds the attributes and text content of a node
     * @param node      : Dom.XMLNode instance - XML node which will be processed
     * @param isChild   : Boolean - To control the structure of JSON, should be true for child element
     * @return String     : JSON string 
    */
    public static String parse(Dom.XMLNode node, Boolean isChild) {
        String json = '';
        Boolean isArray = false;
        rootElementName = rootElementValue(node);
        if ( node.getNodeType() == Dom.XmlNodeType.ELEMENT ) {  
            List<String> lstAttributes = children(node,isArray);
            lstAttributes = constructJson(node,lstAttributes);
        	String textContent = node.getText();
        	if ( String.isNotBlank(textContent.trim()) ) {
        		textContent = textContent.replace( '"', '\\"' );
            	lstAttributes.add( '"ele_text": "' + textContent + '"' );    
        	}
            if ( !isChild ) {
                json = isNotChildElementNotArray(lstAttributes,isArray,json);
            }
            else {
                if ( lstAttributes.size() == 1 && String.isNotBlank(textContent.trim()) ) {  
                    json = '"' + textContent + '"';
                } 
                else {
                    json = isChildElementArray(lstAttributes,isArray,json);
                }   
            }
        }
        json = returnJson(node,isArray,json);
        system.debug(LoggingLevel.INFO,node.getName()+ ':' + json);
        return json;
    }
    
    private static String rootElementValue(Dom.XMLNode node) {
        if ( String.isBlank(rootElementName) ) { rootElementName = node.getName(); }
        return rootElementName;
    }
    
    private static List<String> children(Dom.XMLNode node, Boolean isArray) {
        Map<String, List<String>> mapChildrenJSON = new Map<String, List<String>>();
            List<String> lstJSONForChildren = new List<String>();
            List<Dom.XMLNode> children = node.getChildElements();
            if ( children.size() > 0 ) {
                mapChildrenJSON = constructMapOfChildren(children,mapChildrenJSON);
                for ( String key : mapChildrenJSON.keySet() ) { 
                    if ( mapChildrenJSON.get(key).size() > 1 ) {
                    	lstJSONForChildren.add( '"' + key + '": [' + String.join(mapChildrenJSON.get(key), ', ') + ']' );
                    }
                    else {
                        lstJSONForChildren.add( '"' + key + '": ' + mapChildrenJSON.get(key)[0] );
                    }
                }
            }
        List<String> lstAttributes = new List<String>( lstJSONForChildren );
        return lstAttributes;
    }
    private static Map<String, List<String>> constructMapOfChildren(List<Dom.XMLNode> children,Map<String, List<String>> mapChildrenJSON) {
        for ( Dom.XMLNode child : children ) {  
            String tmp = parse( child, true );
            if ( tmp != '' ) {
                if ( !mapChildrenJSON.containsKey( child.getName() ) ) { 
                    mapChildrenJSON.put( child.getName(), new List<String>() );
                }
                mapChildrenJSON.get( child.getName() ).add( tmp );  
            }
        }
        return mapChildrenJSON;
    }
    private static List<String> constructJson(Dom.XMLNode node, List<String> lstAttributes) {
        for ( Integer i=0; i<node.getAttributeCount(); i++ ) { 
        	String key = node.getAttributeKeyAt( i );
            String value = node.getAttribute( key, '' );
            lstAttributes.add( '"' + key + '": "' + value + '"' );    
        }
        return lstAttributes;
    }
    
    private static String isNotChildElementNotArray(List<String> lstAttributes,Boolean isArray, String json) {
        String elementJson =json;       
         if ( !isArray ) {
            elementJson = '"' + rootElementName + '": {' + String.join(lstAttributes,  ', ') + '}';
        }
        else {
            elementJson = ' {' + String.join(lstAttributes,  ', ') + '}';
        }
        return elementJson;
    }

    private static String isChildElementArray(List<String> lstAttributes,Boolean isArray, String json) {
        String elementJson =json;
        if ( !isArray ) {
        	if ( lstAttributes.size() > 0 ){
                elementJson = '{' + String.join(lstAttributes,  ', ') + '}'; 
        	}
        }
        else {
            elementJson  = '{' + String.join(lstAttributes,  ', ') + '}';

        }
        return elementJson;
    }

    private static String returnJson(Dom.XMLNode node, Boolean isArray, String json ) {
        String elementJson = json;
        if ( rootElementName.equals(node.getName())) {
            if ( !isArray ) {
                elementJson = '{' + elementJson + '}';
            }
            else {
                elementJson = '{"' + node.getName() + '" : ' + elementJson + '}';   
            }
        }
        return elementJson;
    }
}