global class SwaggerDataSourceProvider extends DataSource.Provider{

	public SwaggerDataSourceProvider(){}

		override global List<DataSource.AuthenticationCapability> getAuthenticationCapabilities() {
	    List<DataSource.AuthenticationCapability> capabilities = new List<DataSource.AuthenticationCapability>();
			capabilities.add(DataSource.AuthenticationCapability.OAUTH);
	    capabilities.add(DataSource.AuthenticationCapability.ANONYMOUS);
	    return capabilities;
	}

	override global List<DataSource.Capability> getCapabilities()
	{
    List<DataSource.Capability> capabilities = new
        List<DataSource.Capability>();
    capabilities.add(DataSource.Capability.ROW_QUERY);
    capabilities.add(DataSource.Capability.SEARCH);	
	capabilities.add(DataSource.Capability.REQUIRE_ENDPOINT);
    //capabilities.add(DataSource.Capability.ROW_CREATE);
    //capabilities.add(DataSource.Capability.ROW_UPDATE);
    //capabilities.add(DataSource.Capability.ROW_DELETE);
    return capabilities;
	}

	override global DataSource.Connection getConnection(DataSource.ConnectionParams connectionParams) {
	        return new SwaggerDataSourceConnection(connectionParams);
	    }
}