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

<script type="text/javascript">
	$(document).ready(function() {
		$("#page").css("visibility", "visible");
		
		$.ajax({
			type : "GET",
			url : "getContainerBaseURI.action",
			async : true,
			error : function() {
				console.log("error while getting the csar instance list");
			},
			success : function(data) {
				$("#urlString").text(data.host + ":" + data.port + "/containerapi");
			}
		});
	});
</script>

<title><tiles:insertAttribute name="title" ignore="true" /></title>

</head>
<body>

	<struts:div id="pageContainer">
		<struts:div id="page">

			<struts:div id="header" />

			<struts:div id="content">
				<table id="contentTable" cellspacing="0" cellpadding="0">
					<tr>
						<td id="menuColumn" valign="top" rowspan="2" width="100%"><jquery:div
								id="menu" cssStyle="line-height: 0.5; width: 90%">
							</jquery:div></td>
						<td id="shadowTopColumn"><img
							src="images/contentShadowTop.jpg" /></td>
						<td id="contentColumn" valign="top" rowspan="2"><struts:div
								id="error" cssStyle="width : 95%">
								<tiles:insertAttribute name="error" />
							</struts:div></td>
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