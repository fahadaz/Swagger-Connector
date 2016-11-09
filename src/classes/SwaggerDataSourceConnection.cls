global class SwaggerDataSourceConnection extends DataSource.Connection {
	private DataSource.ConnectionParams connectionInfo;
	private String url = '';

	public SwaggerDataSourceConnection(){

	}

	public SwaggerDataSourceConnection(DataSource.ConnectionParams connectionParams) {
		this.connectionInfo = connectionParams;
		this.url = this.connectionInfo.endPoint;
	}

	// To get meta data from the swagger service and create external objects
	override global List<DataSource.Table> sync(){
		SwaggerParser sw = new SwaggerParser(this.url);
		return sw.getMetaData();
	}


	// Used to query external system data
	override global DataSource.TableResult query(DataSource.QueryContext c){
		DataSource.Filter filter = c.tableSelection.filter;
		Integer offset = c.offset;
		Integer maxResults = c.maxResults;	

		string entity = c.tableSelection.tableSelected;
		string call_url = url;
		string display_url = url + '/api/' + entity +'s/';

		if(filter == null){
			//call_url = url+'/api/'+entity+'s' + addPagingFilters(offset, maxResults, true);
			//if(c.tableSelection.order != null){
					call_url = url + '/api/'+ entity + 's' + addPagingFilters(offset, maxResults, true) + addSortFilters(c.tableSelection.order, false);					
			/*	}
				else{
					call_url = url+'/api/'+entity+'s' + addPagingFilters(offset, maxResults, true);
				}*/
		}
		
		else if(filter != null){
			String cName = filter.columnName;
            
			if (cName != null && cName.equals('ExternalId'))
				call_url = url+'/api/'+entity+'s/' + filter.columnValue;
			
			else{
				//if(c.tableSelection.order != null){
					call_url = url + '/api/'+ entity + 's' + addPagingFilters(offset, maxResults, true) + addSortFilters(c.tableSelection.order, false);					
				/*}
				else{
					call_url = url+'/api/'+entity+'s' + addPagingFilters(offset, maxResults, true);
				}*/

				//call_url = url+'/api/'+entity+'s' + addPagingFilters(offset, maxResults, true);
			}
		}

		// calling external service to get data
        HttpResponse response = getResponse(call_url);

		List<Map<String, Object>> rows = new List<Map<String, Object>>();
		Object res = JSON.deserializeUntyped(response.getBody());

		// multiple rows
		if(res instanceof List<Object>){
			List<Object> m = (List<Object>) res; 
			for(Integer i=0; i <m.size(); i++ ){
				rows.add(createRow((Map<String, Object>)m[i], display_url));
			}
		}
		// single row
		else if(res instanceof Map<String,Object>){
			rows.add(createRow((Map<String, Object>)res, display_url));
		}

		return DataSource.TableResult.get(true, null, c.tableSelection.tableSelected, rows);
	}

	// Adding Sorting for limits
	private string addSortFilters(List<DataSource.Order> order, Boolean isFirstFilter){
		string retFilter = '';
		
		if(order == null) return '';

		if(order.size() == 1){
			// External Id doesn't exists in external system. Replace with 'id' for sort
			if(order[0].columnName == 'ExternalId'){
				retFilter = 'filter[order]=id' + '%20' + getDirection(order[0].direction);
			}
			else{
				retFilter = 'filter[order]=' + order[0].columnName + '%20' + getDirection(order[0].direction);
			}

			if(isFirstFilter == false){
				retFilter = '&' + retFilter;
			}
			else{
				retFilter = '?' + retFilter;
			}
		}
		
		return retFilter;
	}

	// Getting sort direction
	private string getDirection(DataSource.OrderDirection d){
		if(d == DataSource.OrderDirection.ASCENDING)
			return 'ASC';
		else
			return 'DESC';
	}

	// Adds filter for limits and paging
	private string addPagingFilters(Integer offset, Integer maxResults, Boolean isFirstFilter){
		if(maxResults <= 0 )
			return '';
		
		if(isFirstFilter == true){
			return '?filter[limit]='+maxResults+'&filter[skip]='+offset;	
		}
		return 'filter[limit]='+maxResults+'&filter[skip]='+offset;
	}

	// Creates rows from JSON data
	public Map<String, Object> createRow(Map<String, Object> item, string DisplayUrl){
            Map<String, Object> row = new Map<String, Object>();
            for ( String key : item.keySet() ){
				Integer id = 0;
                if (key == 'id') {
                    row.put('ExternalId', item.get(key));
					row.put('id', item.get(key));
                }
				else {
                    row.put(key, item.get(key));                    
                }

				row.put('DisplayUrl', DisplayUrl + row.get('ExternalId'));
            }
            return row;
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

	// Checking swagger version. Only version 2.0 is supported
	private boolean checkVersion(Map<String, Object> m){
		Double ver = Double.valueOf((String)m.get('swagger'));
		if(ver == 2.0) 
			return true;

		return false;		
	}

}