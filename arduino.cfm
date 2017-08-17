<!--- Connect to the Arduino board and show firmata version --->
<cfset arduino = createobject("component", "com.classsoftware.arduino.Arduino")>
<cfdump var="#arduino.init()#">

<!--- Set digita pins 2-6 to be outputs --->
<cfset arduino.setPinMode(2, arduino.OUTPUT)>
<cfset arduino.setPinMode(3, arduino.OUTPUT)>
<cfset arduino.setPinMode(4, arduino.OUTPUT)>
<cfset arduino.setPinMode(5, arduino.OUTPUT)>
<cfset arduino.setPinMode(6, arduino.OUTPUT)>

<!--- Blink Leds on and off will take about 1.5 seconds ---->
<cfloop index="i" from="1" to="1000">
	<cfset no = randrange(2,6)>
    <cfloop index="j" from="2" to="6">
		<cfif no gte j>
            <cfset arduino.writeDigitalPin(j, arduino.HIGH)>
        <cfelse>
       		<cfset arduino.writeDigitalPin(j, arduino.LOW)>
        </cfif>
     </cfloop>
</cfloop>

<cfset arduino.close()>