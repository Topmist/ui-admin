<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="struts" uri="/struts-tags"%>
<%@ taglib prefix="jquery" uri="/struts-jquery-tags"%>

<table id="CSARListMenuTable" width="100%"></table> <br />
<br />
<br />

<jquery:a id="uploadCSARButton" href="#" openDialog="uploadDialog"
	cssClass="styledButton">
	<div class="left"></div>
	<div class="middle">Upload new CSAR</div>
	<div class="right"></div>
</jquery:a>

<jquery:a id="deleteCSARButton" href="#" cssClass="styledButton"
	onclick="javascript:deleteCSAR()">
	<div class="left"></div>
	<div class="middle">Delete CSAR</div>
	<div class="right"></div>
</jquery:a>
<br />



<jquery:dialog id="uploadDialog" cssClass="uploadDialog"
	formIds="uploadform" autoOpen="false" width="auto" height="auto"
	modal="true" title="Select CSAR to upload.">

	<struts:form id="uploadformURL" name="uploadformURL" method="post"
		action="uploadCSARFromURL">
		
		<i>URL: </i><input name="urlToUpload" type="text" size="30">
		<jquery:submit id="uploadButton2" value="upload from URL" />
			
	</struts:form>
	
	<p />

	<struts:form id="uploadform" name="uploadform" method="post"
		action="uploadCSAR" enctype="multipart/form-data">

		<struts:file id="fileToUpload" name="file" size="40" label="File"/>
		<jquery:submit id="uploadButton" value="upload from disk" />

	</struts:form>
	<br />
</jquery:dialog>

