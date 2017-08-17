<cfcomponent displayname="Socket" output="false" hint="Implements binary socket for use in ColdFusion">
	<cfset socket = "">
	<cfset output = "">
	<cfset input = "">
    
	<!--- Open and setup a socket connection --->
	<cffunction access="public" name="open" output="false">
		<cfargument name="proxy" type="String" required="no" default="localhost">
		<cfargument name="port" type="Numeric" required="no" default="80">
		
		<cfset var factory="">

		<!--- Create socket connection --->
		<cfset factory = CreateObject("java", "javax.net.SocketFactory").getDefault()>
		<cfset socket = factory.createSocket(arguments.proxy, arguments.port)>
		        
		<!--- Connect to output stream --->
		<cfset output = createObject("java", "java.io.BufferedOutputStream").init(socket.getOutputStream())>
		<!--- Connect to input stream --->		
		<cfset input= createObject("java", "java.io.BufferedInputStream").init(socket.getInputStream())>
     		
		<cfreturn>
	</cffunction>
	
	<!--- Close everything --->
	<cffunction access="public" name="close" output="false" hint="Closes a socket">
		<cfset output.close()>
		<cfset input.close()>		
		<cfset socket.close()>
		
		<cfreturn>    
	</cffunction>
	
	<!--- Read a single byte --->
	<cffunction access="public" name="read" output="false" returntype="string" hint="Reads a single byte">
		<cfreturn input.read()>
	</cffunction>
	
	<!--- Write a single byte --->
	<cffunction access="public" name="write" output="false" hint="Writes a single byte">
		<cfargument name="byte" type="numeric" required="yes">
		
	    <cfset output.write(byte)>
	    
	    <cfreturn>	
	</cffunction>
	
	<!--- Flush written bytes (call after writes) --->
	<cffunction access="public" name="flush" output="false" hint="Flushes output (call after writes)">
	    <cfset output.flush()>
	    
	    <cfreturn>
	</cffunction>	
	
</cfcomponent>