<%@ taglib prefix="struts" uri="/struts-tags"%>
<%@ taglib prefix="jquery" uri="/struts-jquery-tags"%>

<struts:div id="mainMenu">
	<jquery:a onclick="showViewOverview()"  cssClass="mainMenuButton" id="overviewButton" />
	<jquery:a onclick="showViewDeploy()" cssClass="mainMenuButton" id="deployCSARButton" />
	<jquery:a onclick="showViewAbout()" cssClass="mainMenuButton" id="aboutButton" />

</struts:div>

