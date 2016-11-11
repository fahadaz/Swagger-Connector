# Swagger-Connector

[![Alt Text]( https://andrewfawcett.files.wordpress.com/2014/09/deploy.png)](https://githubsfdeploy.herokuapp.com/app/githubdeploy/fahadaz/Swagger-Connector)

This connector is designed to show case the capabilities of Salesforce Connect's Apex Connector framework to consume a Swagger 2.0 file to create external objects in salesforce. For those not familiar with Swagger please see below

"Swagger is a simple yet powerful representation of your RESTful API." (http://swagger.io/).    

This connector is tested to work with http://loopback.io strongloop framework generate api. 

Following are the capabilities of this framework
* Can read Swagger 2.0 file and generate External Object in salesforce
* It can query data in listview and detail view.
* It provides sorting 
* It provides paging 

To Do
1. Searching
2. Upsert
3. Delete
4. Authentication

Gotach's
1. Entering end service url should not include a forward slash
    Correct: https://sub.domain.com
2. Entity names should be singular. Service automatically adds 's' to the url.

