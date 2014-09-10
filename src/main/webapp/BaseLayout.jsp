<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles"%>
<%@ taglib prefix="struts" uri="/struts-tags"%>
<%@ taglib prefix="jquery" uri="/struts-jquery-tags"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<struts:head />
<jquery:head jqueryui="true" />

<style type="text/css">
@import 'css/layout.css';
</style>

<title><tiles:insertAttribute name="title" ignore="true" /></title>
<tiles:insertAttribute name="scripts" />

</head>
<body>

	<jquery:dialog id="PlanParameterDialog" cssClass="uploadDialog" modal="true"
		formIds="PlanParameterDialogForm" autoOpen="false" width="auto" height="auto"
		draggable="true">
		<div id="PlanParameterDialogContent"></div>
	</jquery:dialog>

	<struts:div id="pageContainer">
		<struts:div id="page">

			<struts:div id="header">
				<tiles:insertAttribute name="header" />
			</struts:div>

			<struts:div id="content">
				<table id="contentTable" cellspacing="0" cellpadding="0">
					<tr>
						<td id="menuColumn" valign="top" rowspan="2" width="100%"><jquery:div
								id="menu" cssStyle="line-height: 0.5; width: 90%">
								<tiles:insertAttribute name="menu" />
							</jquery:div></td>
						<td id="shadowTopColumn"><img src="images/contentShadowTop.jpg" /></td>
						<td id="contentColumn" valign="top" rowspan="2"><jquery:div
								id="overviewPanel">
								<tiles:insertAttribute name="overview" />
							</jquery:div> <jquery:div id="deployPanel">
								<tiles:insertAttribute name="deploy" />
							</jquery:div> <jquery:div id="aboutPanel">
								<tiles:insertAttribute name="about" />
							</jquery:div></td>
					</tr>
					<tr>
						<td id="shadowMiddleAndBottomColumn" valign="bottom"><img
							src="images/contentShadowBottom.jpg" /></td>
					</tr>
				</table>
			</struts:div>

			<struts:div id="footer">
				<tiles:insertAttribute name="footer" />
			</struts:div>

		</struts:div>
	</struts:div>
</body>
</html>