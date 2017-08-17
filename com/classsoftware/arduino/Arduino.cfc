<cfcomponent displayname="Arduino" output="false" extends="Socket" hint="Implements the Firmata protocol to allow ColdFusion to communicate with Arduinos">
	<cfset this.OUTPUT = 1>
	<cfset this.INPUT = 0>
	<cfset this.HIGH = 1>
	<cfset this.LOW = 0>
	<cfset this.ON = 1>
	<cfset this.OFF = 0>
	<cfset this.PWM = 2>
		 	
	<cfset variables.host = "localhost">	
	<cfset variables.port = 5331>
	
	<cfset variables.digitalPins = 0>
	
	<cfset variables.ARD_TOTAL_DIGITAL_PINS = 14>
		 
	<cfset variables.ARD_DIGITAL_MESSAGE = 144>
	<cfset variables.ARD_REPORT_DIGITAL_PORTS = 208> 
	<cfset variables.ARD_REPORT_ANALOG_PIN = 192>
	<cfset variables.ARD_REPORT_VERSION = 249> 
	<cfset variables.ARD_SET_DIGITAL_PIN_MODE = 244> 	
	<cfset variables.ARD_ANALOG_MESSAGE = 224>
	<cfset variables.ARD_SYSTEM_RESET = 255>
	<cfset variables.ARD_SYSEX_MESSAGE_START = 240>
	<cfset variables.ARD_SYSEX_MESSAGE_END = 247>
	
	<cffunction name="init" returntype="struct" hint="Initialise the arduino opening a socket and asking for firmata version">
		<cfargument name="proxy" type="String" default="localhost" required="no">
		<cfargument name="port" type="Numeric" default="5331" required="no">		

		<cfif arguments.port lt 1024 or arguments.port gt 65535>
			<cfthrow message="Arduino: Port needs to be between 1024 and 65535.">
		</cfif>
		
		<cfset variables.proxy = arguments.proxy>
		<cfset variables.port = arguments.port>
	
		<cfset this.open(variables.proxy, variables.port)> 
                   
		<cfreturn version()>
	</cffunction>
    
    <cffunction name="version" returntype="struct" hint="Ask for the firmata version">
 		<cfset var bytes = []>
		<cfset var i = 1>
				
		<!--- Send the firmware request message --->
		<cfset this.write(variables.ARD_SYSEX_MESSAGE_START)>
		<cfset this.write(variables.ARD_REPORT_VERSION)>
		<cfset this.write(variables.ARD_SYSEX_MESSAGE_END)>
		<cfset this.flush()>

		<!--- Read the response --->
        <cfset bytes[i] = input.read()>
        <cfset i = i + 1>
        <cfloop condition="bytes[i-1] neq variables.ARD_SYSEX_MESSAGE_END">
            <cfset bytes[i] = input.read()>
            <cfset i = i + 1>
        </cfloop>
        
        <!--- Decode the response and put into structure --->
        <cfset version = {}>
        <cfset version.version = bytes[2] & "." & bytes[3]>
        <cfset version.name = "">
        <cfset length = arraylen(bytes)-1>
		<cfloop from="6" to="#length#" index="i">
        	<cfset version.name = version.name & chr(bytes[i])>
        </cfloop>
        
        <cfreturn version>        
    </cffunction>
    
	<cffunction name="setPinMode" hint="Sets digital pin mode as input, output or PWM">
		<cfargument name="pin" type="Numeric" required="true">
		<cfargument name="mode" type="Numeric" required="true">		
			
		<cfset this.write(variables.ARD_SET_DIGITAL_PIN_MODE)>
		<cfset this.write(arguments.pin)>
		<cfset this.write(arguments.mode)>
		<cfset this.flush()>
	</cffunction>
	
	<cffunction name="writeDigitalPin" hint="Turns a digital pin on or off">
		<cfargument name="pin" type="Numeric" required="true">
		<cfargument name="value" type="Numeric" required="true">
				
		<cfif arguments.value is this.HIGH>
			<cfset digitalPins = bitor(digitalPins, bitshln(arguments.value, arguments.pin))>
		</cfif>
		
		<cfif arguments.value is this.LOW>
			<cfset digitalPins = bitand(digitalPins, bitnot(bitshln(1, arguments.pin)))>
		</cfif>
        
        <cfset this.write(variables.ARD_DIGITAL_MESSAGE)>
        <cfset this.write(bitand(digitalPins, 127))> <!--- Tx pins 0-6 --->
        <cfset this.write(bitshln(digitalPins, 7))>  <!--- Tx pins 7-13 --->
		<cfset this.flush()>
		
		<cfreturn>
	</cffunction>
	
    <cffunction name="writeAnaloguePin" returntype="numeric" hint="Writes an analog value (used for PWM)">
		<cfargument name="pin" type="Numeric" required="true">
		<cfargument name="value" type="Numeric" required="true">
		
 		<!--- Send the analog report message --->
		<cfset this.write(variables.ARD_ANALOG_MESSAGE)>
		<cfset this.write(arguments.pin)>
		<cfset this.write(bitand(value, 127))>
		<cfset this.write(bitshln(value, 7))>
		<cfset this.flush()>     
    </cffunction>	

    <cffunction name="readAnaloguePin" returntype="numeric" hint="Reads an anolog value">
		<cfargument name="pin" type="Numeric" required="true">

		<cfset var analog = 0>
        <cfset var ls7bits = 0>
		<cfset var ms7bits = 0>
		
 		<!--- Send the analog report message --->
		<cfset this.write(variables.ARD_REPORT_ANALOG_PIN)>
		<cfset this.write(argumnets.pin)>
		<cfset this.write(1)>
		<cfset this.flush()>
		
		<!--- Read the response --->
		<cfset analog = input.read()>
        <cfset ls7bits = input.read()>
		<cfset ms7bits = input.read()>
        
		<!--- analog value is in 2 bytes ---> 
        <cfreturn ls7bits + bitshrn(ms7bits,7)>        
    </cffunction>
	
    <cffunction name="readDigitalPin" returntype="numeric" hint="Reads a digtal pin">
		<cfargument name="pin" type="Numeric" required="true">

		<cfset var digital = 0>
        <cfset var ls7bits = 0>
		<cfset var bits = 0>
				
 		<!--- Send the analog report message --->
		<cfset this.write(variables.ARD_REPORT_DIGITAL_PORTS)>
		<cfset this.write(arguments.pin)>
		<cfset this.write(1)>
		<cfset this.flush()>
		
		<!--- Read the response --->
		<cfset digital = input.read()>
        <cfset ls7bits = input.read()>
		<cfset ms7bits = bitshrn(input.read(),7)>
		<cfset bits = ls7bits + ms7bits>
        
		<cfset digitalPins = bitand(bitshln(bits, arguments.pin), 1)>
		
		<!--- all digital values are returned just pick the one we want --->  
        <cfreturn digitalPins>        
    </cffunction>
	
	<cffunction name="resetBoard" hint="Resets the arduino board">
		<cfset this.write(this.ARD_SYSTEM_RESET)>
		<cfset this.flush()>
		
		<cfreturn>		
	</cffunction>		
</cfcomponent>