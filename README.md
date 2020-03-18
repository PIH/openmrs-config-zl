openmrs-config-zl
==============================

#### Usage

`mvn clean compile` - Will generate your configurations into "target/openmrs-packager-config/configuration"
`mvn clean package` - Will compile as above, and generate a zip package at "target/${artifactId}-${version}.zip"

In order to facilitate deploying configurations easily into an OpenMRS SDK server, one can add an additional parameter
to either of the above commands to specify that the compiled configuration should also be copied to an existing 
OpenMRS SDK server:

`mvn clean compile -DserverId=zl` - Will compile as above, and copy the resulting configuration to `~/openmrs/zl/configuration`

If the configuration package you are building will be depended upon by another configuration package, you must "install" it
in order for the other package to be able to pick it up.

`mvn clean install` - Will compile and package as above, and install as an available dependency on your system

##### To enable watching, you run the following:

* in the parent project (openmrs-config-pihemr) directory:  
`mvn clean openmrs-packager:watch`
* in the current openmr-config-zl directory:  
`mvn clean openmrs-packager:watch -Dgoal=compile -DserverId=SERVER_ID -DdelaySeconds=3`

For more details regarding the available commands please see:
https://github.com/openmrs/openmrs-contrib-packager-maven-plugin 
