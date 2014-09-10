<%@ taglib prefix="struts" uri="/struts-tags"%>

<struts:div id="about">

	<div style="margin: 6px;">
		<br>
		<b>Copyright (c) 2012-2013 University of Stuttgart<br>
 		All rights reserved. This program and the accompanying materials<br>
 		are made available under the terms of the Apache License 2.0.</b>
 		<br><br>
		
		<b>NOTICE</b><br>
		<% // MOST RECENT VERSION OF NOTICE IS COPIED BY MAVEN INTO THE WAR %>
		<textarea readonly style="width: 750px; height: 500px;"><struts:include value="/NOTICE"></struts:include></textarea>
		<br><br>
		
		<b>LICENSE</b><br>
		<% // MOST RECENT VERSION OF LICENSE IS COPIED BY MAVEN INTO THE WAR %>
		<textarea readonly style="width: 750px; height: 500px;"><struts:include value="/LICENSE"></struts:include></textarea>
	</div>

</struts:div>