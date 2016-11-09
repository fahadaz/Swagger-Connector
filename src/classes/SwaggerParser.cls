public class SwaggerParser {
	
	private String url = '';
	
	public SwaggerParser(String endPoint) {
		url = endPoint;
	}

	private HttpResponse getResponse(String url) {
    Http httpProtocol = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndPoint(url);
    request.setMethod('GET');
    //request.setHeader('Authorization', 'Bearer ' + this.connectionInfo.oauthToken);
    HttpResponse response = httpProtocol.send(request);
    return response;
	}

	private boolean checkVersion(Map<String, Object> m){
		Double ver = Double.valueOf((String)m.get('swagger'));
		if(ver == 2.0) 
			return true;

		return false;		
	}

	private List<String> getAllEntities(Map<String, Object> m){
		
		List<String> entities = new List<String>(m.keySet());
		for(string ent: entities){
			System.Debug('entity: ' + ent);
		}

		return entities;
	}

	public List<DataSource.Table> getMetaData(){
		// base url
		//String url = this.connectionInfo.endpoint;
		HttpResponse res = getResponse( url +'/explorer/swagger.json'); // get swagger metadata File
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
		List<Object> tags = (List<Object>) m.get('tags');
		
		if(!checkVersion(m)){
			throw new SwaggerException('Only swagger version 2.0 is supported.');
		}
				
		List<DataSource.Table> tables = new List<DataSource.Table>();
		
		Map<String,Object> definitions = (Map<String,Object>) m.get('definitions');
		List<String> entities = getAllEntities(definitions);

		for(String ent: entities){
		    Map<String, Object> defs = (Map<String, Object>) definitions.get(ent);

		    List<DataSource.Column> columns = new List<DataSource.Column>();

		    if(defs != null){
		    	Map<String, Object> properties = (Map<String, Object>)defs.get('properties');
		        Set<String> keys = properties.keySet();

		        for(String key: keys){
		            DataSource.Column dCol = getDataColumn(key, (Map<String,Object>)properties.get(key));

		            if(dCol != null){
		            	columns.add(dCol);
		            }
		        }

				columns.add(DataSource.Column.url('DisplayUrl'));
		        columns.add(DataSource.Column.text('ExternalId',255));

		        tables.add(DataSource.Table.get(ent, 'id', columns));
		    }
		}

		return tables;
	}

	private DataSource.Column getDataColumn(String name, Map<String, Object> col){
    String colType = (String)col.get('type');
    System.debug('type: ' + colType );

    if(colType == 'string'){
        String maxLength = (String)col.get('maxlength');
        Integer len = 255;
        if(maxLength != null){
            len = Integer.valueOf(maxLength);
        }
        return DataSource.Column.text(name, len);
    }
    else if(colType == 'number'){
        String format = (String)col.get('format');
        if(format == 'double'){
            return DataSource.Column.number(name, 10, 2);
        }
        else{
            return DataSource.Column.integer(name, 8);
        }
    }
    else if(colType == 'boolean'){
        return DataSource.Column.text(name, 5);
    }

    return null;
 }

}