<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="struts" uri="/struts-tags"%>
<%@ taglib prefix="jquery" uri="/struts-jquery-tags"%>

<struts:div id="overview">
	<table>
		<tr>
			<td colspan="2">
				<div id="uploadStatusDiv"></div>
			</td>
		</tr>
		<tr>
			<td>
				<struts:url var="getcsarBrowsingList" action="getCSARContent" /> 
				<jquery:select
					id="csarBrowsingList" 
					name="csarBrowsingList" href="%{getcsarBrowsingList}"
					list="selectedCsarBrowsingList" headerKey="-1" size="24"
					style="width: 268px; vertical-align: top" onChangeTopics="selectedContentChanged"/>
			</td>
			<td valign="top">
				<struts:div style="display: inline">
					<img id="topologyImg" width="492"
						style="vertical-align: top; max-width: 470px;"
						onerror="$('#topologyImg').attr('src','images/notopologyimg.png')" />
				</struts:div>
			</td>
		</tr>
	</table>
</struts:div>