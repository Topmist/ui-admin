<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="struts" uri="/struts-tags"%>
<%@ taglib prefix="jquery" uri="/struts-jquery-tags"%>

<table id="CSARDeploymentPaneTable">

	<tr>

		<td valign="top" width="150">
			<p><b>Instances of CSAR:</b></p>
			<div id="CSARInstanceMenuDiv"> </div>
		</td>
		<td valign="top">
			<div>
				<p><b>Available Management Plans:</b></p>
				
				<table id="CSARManagementPlansTable"></table>
			</div>
			<p/>
			<div>
				<b>Build Informations:</b>
				<p/>
				<div id="buildinformations"></div>
			</div>
			<p/>
			<div>
				<b>Running Plans:</b>
				<p/>
				<div id="activePlans"></div>
			</div>
			<p/>
			<div>
				<b>History of Plans:</b>
				<p/>
				<div id="planHistory"></div>
			</div>
		</td>

	</tr>

</table>
<br />