<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles"%>
<%@ taglib prefix="struts" uri="/struts-tags"%>
<%@ taglib prefix="jquery" uri="/struts-jquery-tags"%>

<div class="errorHeadline">The website failed to connect to the
	OpenTOSCA Container</div>
<div class="errorText">
	The website failed to connect to <span class="description"
		id="urlString">not retrieved yet</span>! Please make sure OpenTOSCA
	runs properly on this machine and is accessible. In particular, check
	if the listed port is accessible from the outside, i.e., from this
	machine and from others user's machine. If OpenTOSCA runs (in its
	default configuration) on a virtual machine, you need to configure the
	firewall so at least ports 1337, 8080, 9443 and 9763 are open.
</div>
<div class="errorFooter">
	Caught exception: <span class="description"> <struts:property
			value="%{exception.message}" />
	</span> <br />
	<textarea rows="15" cols="90" readonly="readonly">
		<struts:property value="%{exceptionStack}" />
	</textarea>
</div>