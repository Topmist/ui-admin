<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<script type="text/javascript">

	// variables for the current view
	var selectedCSAR;
	var selectedCSARInstance;
	var contentPath;
	var lastShowedPlan = null;
	
	// refreshrate and IDs for interval
	var refreshRateMilis = 3000;
	var csarRefreshID = null;
	var instanceRefreshID = null;
	
	// all loading is done, so start the viewing
	$(document).ready(
		function() {
			
			// show the first pane and instantly refresh the list of CSARs
			showViewOverview();
			refreshCSARList();
			
			// show the page
			$("#page").css("visibility", "visible");
			
			// event listeners
			$("#CSARListMenuTable").on("click", "tbody tr", csarSelected);
			$("#CSARInstanceMenuDiv").on("click", "table tbody tr",
				csarInstanceSelected);
			$("#CSARManagementPlansTable").on("click", "tbody tr",
				csarManagementPlanSelected);
			$("#planHistory").on("click", "#planHistoryTable tbody tr",
				showPlanHistoryDetails);
			$("#planHistory").on("click",
				"#planHistoryTable tbody tr td .styledButton",
				showPlanHistoryDialog);
			// this listens for the change of the content path
			$.subscribe('selectedContentChanged', function(event) {
				
				event.preventDefault();
				
				// report the selected content path
				changeOverviewContent(selectedCSAR, contentPath
						+ $("#csarBrowsingList").val());
			});
		});
	
	// functions to switch between the view panes
	{
		// this function shows the overview pane and activates and deactivates the intervals
		function showViewOverview() {
			console.log("showViewOverview");
			
			$("#menu,#overviewPanel").show();
			$("#deployPanel,#aboutPanel").hide();
			$("#overviewButton").attr("class", "mainMenuButton selected");
			$("#deployCSARButton,#aboutButton").attr("class", "mainMenuButton");
			
			if (csarRefreshID == null) {
				csarRefreshID = setInterval(refreshCSARList, refreshRateMilis);
			}
			
			clearInterval(instanceRefreshID);
			instanceRefreshID = null;
		}

		// this function shows the management pane and activates and deactivates the intervals
		function showViewDeploy() {
			console.log("showViewDeploy");
			
			refreshCSARInstanceList();
			$("#menu,#deployPanel").show();
			$("#overviewPanel,#aboutPanel").hide();
			$("#deployCSARButton").attr("class", "mainMenuButton selected");
			$("#overviewButton,#aboutButton").attr("class", "mainMenuButton");
			
			if (csarRefreshID == null) {
				csarRefreshID = setInterval(refreshCSARList, refreshRateMilis);
			}
			
			if (instanceRefreshID == null) {
				instanceRefreshID = setInterval(refreshCSARInstanceInformations,
					refreshRateMilis);
			}
		}

		// this function shows the about pane and activates and deactivates the intervals
		function showViewAbout() {
			console.log("showViewAbout");
			
			$("#aboutPanel").show();
			$("#menu,#deployPanel,#overviewPanel").hide();
			$("#aboutButton").attr("class", "mainMenuButton selected");
			$("#deployCSARButton,#overviewButton").attr("class", "mainMenuButton");
			
			clearInterval(csarRefreshID);
			csarRefreshID = null;
			
			clearInterval(instanceRefreshID);
			instanceRefreshID = null;
		}
		
	}

	// CSAR menu pane
	{
		
		// this function is activated by an event listener, if there is a click on a csar entry
		function csarSelected(event) {
			console.log("csarSelected");
			
			event.preventDefault();
			
			selectedCSARInstance == null;
			
			if (this.id == "ListItem_No CSARs uploaded.") {
				return;
			}
			
			// show the highlighting
			$("#ListItem_" + selectedCSAR).addClass("CSARListItemUnselected");
			$("#ListItem_" + selectedCSAR).removeClass("CSARListItemSelected");
			
			selectedCSAR = $("#" + this.id).attr("name"); // + ".csar";
			selectedCSARInstance = "";
			
			$("#ListItem_" + selectedCSAR).addClass("CSARListItemSelected");
			$("#ListItem_" + selectedCSAR).removeClass("CSARListItemUnselected");
			
			// changes the information content in the overview pane such as the CSAR browsing content or the topology picture
			changeOverviewContent(selectedCSAR, "");
			
			// sets the upload information whether the CSAR can produce CSAR-Instances or not
			getUploadInformation();
			
			// if the click hitted the plus sign for BUILD
			if (event.target.id.substring(0, 6) == "build_") {
				csarGetBuildPlan();
			}
			
			// refresh the CSAR-Instance list
			refreshCSARInstanceList();
		}
		
		// this method gets the BUILD plan for the selected CSAR
		function csarGetBuildPlan() {
			console.log("csarGetBuildPlan");
			
			// add the .csar for complete CSARID
			var csar = selectedCSAR + ".csar";
			
			// get the BUILD plan by AJAX call
			$.ajax({
				type : "GET",
				async : false,
				url : "getCSARPublicPlans.action",
				data : {
					selectedCSAR : csar,
					planType : "BUILD",
					internalID : 0,
				},
				success : function(data) {
					
					var dialog = null;
					
					// due internalID=0 there can be only one PublicPlan here
					$.each(data.publicPlans, function(index, publicPlan) {
						// generate the form
						dialog = generateForm(publicPlan);
					});
					
					// set up the dialog
					$("#PlanParameterDialog").dialog("option", "title", "Put in plan parameter details.");
					$("#PlanParameterDialog").dialog({
						buttons : {
							'invoke plan' : function() {
								putBUILDInvocation();
								$("#PlanParameterDialog").dialog('close');
							},
							'Cancel' : function() {
								$("#PlanParameterDialog").dialog('close');
							}
						},
						open : function() {
							$("#PlanParameterDialogContent").append(dialog);
						},
						close : function() {
							$("#PlanParameterDialogContent").empty();
						}
					});
					
					$("#PlanParameterDialog").dialog('open');
				},
				error : function() {
					console.log("error");
				}
			});
		}
		
		// generates a form for a given PublicPlan
		function generateForm(publicPlan) {
			console.log("generateForm");
			
			dialog = jQuery("<div />");
			dialog.append(jQuery("<p/>").text(publicPlan.planID.localPart));
			
 			var planid = "{" + publicPlan.planID.namespaceURI + "}"
 					+ publicPlan.planID.localPart;
			var form = jQuery("<form id=\"PlanParameterDialogContentForm\" name=\""
					+ planid + "\">");
			dialog.append(form);
			
			form.append(jQuery("<input type=\"hidden\" id=\"PlanType\" value=\""
				+ publicPlan.planType + "\">"));
			
			var table = jQuery("<table>");
			form.append(table);
			
			// for each input parameter
			$.each(publicPlan.inputParameter,
				function(index, parameter) {
					console.log(parameter);
					
					// do not show parameter which are generated by OpenTOSCA
					if (parameter.type != "correlation" && parameter.type != "callbackaddress" && parameter.type != "containerApiAddress" && parameter.type != "csarName") {
						
						var tr = jQuery("<tr>");
						table.append(tr);
						
						var td = jQuery("<td>");
						tr.append(td);
						td.append(parameter.name + ":&nbsp;");
						
						var td = jQuery("<td>");
						tr.append(td);
						
						if (parameter.type == "string-password"){
							td.append(jQuery("<input type=\"password\" name=\""
								+ parameter.name + "\" size=\"30\" />"));
						} else if (parameter.type == "string-multiline"){
							td.append(jQuery("<textarea name=\""
								+ parameter.name + "\" cols=\"30\" rows=\"2\" />"));
						} else {
							td.append(jQuery("<input type=\"text\" name=\""
								+ parameter.name + "\" size=\"30\" />"));
						}
					}
				}
			);
			
			return dialog;
		}
		
		// posts a PublicPlan for invocation
		function putBUILDInvocation() {
			console.log("putBUILDInvocation");
			
			// get some informations
			var planid = $("#PlanParameterDialogContentForm").attr("name");
			var type = $("#PlanType").val();
			
			// get the input parameter values
			var inputvalues = "";
			$("#PlanParameterDialogContentForm input[type=text]").each(
					function() {
						// need for to post it due AJAX call
						inputvalues = inputvalues + $(this).attr("name")
								+ "$$$$$$$$$$$$$" + $(this).val() + "$$$$$$$$$$$$$!";
					}
				);
			$("#PlanParameterDialogContentForm input[type=password]").each(
					function() {
						// need for to post it due AJAX call
						inputvalues = inputvalues + $(this).attr("name")
								+ "$$$$$$$$$$$$$" + $(this).val() + "$$$$$$$$$$$$$!";
					}
				);
			$("#PlanParameterDialogContentForm textarea").each(
					function() {
						// need for to post it due AJAX call
						inputvalues = inputvalues + $(this).attr("name")
								+ "$$$$$$$$$$$$$" + $(this).val() + "$$$$$$$$$$$$$!";
					}
				);
			
			$.ajax({
				type : "POST",
				async : false,
				url : "postBUILDInvocation.action",
				data : {
					csarID : selectedCSAR + ".csar",
					planType : type,
					planID : planid,
					internalID : 0,
					parameters : inputvalues,
				},
				error : function(jqXHR, textStatus, errorThrown) {
					console.log("error on plan invocation");
					console.log(errorThrown);
				},
				success : function() {
					console.log("plan invocation success");
				}
			});
			refreshCSARInstanceList();
		}
		
		// this function refreshes the CSAR list
		function refreshCSARList() {
			console.log("refreshCSARList");
			
			// get the informations
			$.ajax({
				async : false,
				type : "GET",
				url : "getCSARList.action",
				error : function() {
					console.log("error while getting the csar list");
				},
				success : function(data) {
					processRefreshCSARList(data);
				}
			});
		}
		
		// delete a CSAR
		function deleteCSAR() {
			console.log("deleteCSAR");
			
			// check if a csar is selected
			if (null != selectedCSAR && "" != selectedCSAR) {
				
				// check if there are instances available
				var instancesAvailable = false;
				$.ajax({
					type : "GET",
					url : "getCSARInstanceList.action",
					async : false,
					data : {
						selectedCSAR : selectedCSAR + ".csar",
					},
					error : function() {
						console.log("error while getting the csar instance list");
					},
					success : function(data) {
						if (data.availableInstances.length > 0){
							instancesAvailable = true;
						}
					}
				});
				
				if (instancesAvailable){
					$("#PlanParameterDialogContent").empty();
					$("#PlanParameterDialog").dialog("option", "title", "Please delete the CSAR instances.");
					$("#PlanParameterDialog").dialog({
						buttons : {
							'OK' : function() {
								$("#PlanParameterDialog").dialog('close');
							}
						},
						open : function() {
							var p = jQuery("<p>");
							p.append("Please terminate all instances of this CSAR.<br />Unless then you cannot delete the CSAR.");
							$("#PlanParameterDialogContent").append(p);
						},
						close : function() {
							$("#PlanParameterDialogContent").empty();
						}
					});
					$("#PlanParameterDialog").dialog('open');
					
				} else {
					
					$.ajax({
						type : "POST",
						url : "deleteCSAR.action",
						async : false,
						data : {
							selectedCSAR : selectedCSAR + ".csar"
						},
						success : function(data) {
							// remove the item instantly
							$("#csarList option[value = '" + data.selectedCSAR + "']")
									.remove();
							
							refreshCSARList();
						},
						error : function() {
							console.log("error on delete a CSAR");
						}
					});
				}
			} else {
				console.log("no CSAR selected");
			}
		}
		
		// generates the html output for a refresh of the CSAR list
		function processRefreshCSARList(data) {
			console.log("processRefreshCSARList");
			
			var old = $("#CSARListMenuTable tr");
			var table = $("#CSARListMenuTable");
			
			table.css("border-spacing", "0");
			table.css("width", "100%");
			
			// each CSAR build a row in the table
			$.each(data.csars,
				function(index, value) {
					
					var tr = jQuery('<tr id="ListItem_' + value + '" name="'+ value + '"></tr>');
					
					if (value == selectedCSAR) {
						tr.addClass("CSARListItemSelected");
					} else {
						tr.addClass("CSARListItemUnselected");
					}
					
					tr.css("height", "26");
					
					var td = jQuery('<td id="justSelect_' + value+'"></td>');
					td.append(value);
					tr.append(td);
					
					var td = jQuery('<td id="build_' + value+'"></td>');
					
					if (value == "No CSARs uploaded.") {
						td.css('background-image', 'none');
						td.css('background-image',
							'images/CSARManagementPlanItemEnd.jpg');
						console.log("non upload");
					}
					
					tr.append(td);
					
					table.append(tr);
				}
			);
			old.remove();
		}
	}

	// overview pane
	{
		// gets the information about the upload of a CSAR
		function getUploadInformation() {
			console.log("getUploadInformation");
			
			if (null == selectedCSAR || "" == selectedCSAR) {
				return;
			}
			
			$.ajax({
				type : "GET",
				url : "getCSARUploadInformations",
				async : false,
				data : {
					selectedCSAR : selectedCSAR + ".csar",
				},
				success : function(data) {
					
					var div = $("#uploadStatusDiv");
					var txt = "CSAR status: ";
					
					if (data.state == "PLANS_DEPLOYED") {
						div.text(txt + " CSAR sucessfully deployed");
					} else {
						div.text(txt + " An error occured during CSAR deployment");
					}
					div.append(jQuery("<p />"));
				},
				error : function(httpRequest, textStatus, errorThrown) {
					console.log("error while recieving upload status of CSAR");
				}
			});
		}
		
		// changes the information content in the overview pane such as the CSAR browsing content or the topology picture
		function changeOverviewContent(selectedCSAR, selectedContent) {
			console.log("changeOverviewContent");
			
			if (null == selectedCSAR || "" == selectedCSAR) {
				return;
			}
			
			$.ajax({
				type : "GET",
				url : "getCSARContent.action",
				async : false,
				data : {
					selectedCSAR : selectedCSAR + ".csar",
					selectedCSARContentPath : selectedContent
				},
				success : function(data) {
					
					contentPath = data.selectedCSARContentPath;
					
					// process content list
					$("#csarBrowsingList option").remove();
					
					$.each(data.selectedCsarBrowsingList, function(index, value) {
						$("#csarBrowsingList").append(
							jQuery('<option></option>').html(value));
						
					});
					
					// process topology image
					$("#topologyImg").attr("src", data.selectedCSARTopologyURL);
				},
				error : function() {
					console.log("error on selected CSAR change");
					contentPath = "/";
				}
			});
		}
	}

	// manage csar pane
	{
		// this function refreshes the CSAR list
		function refreshCSARInstanceList() {
			console.log("refreshCSARInstanceList");
			
			if (null == selectedCSAR || "" == selectedCSAR) {
				$("#CSARInstanceMenuDiv").children().remove();
				$("#CSARInstanceMenuDiv").append(
					jQuery("<p>").append("No CSAR selected."));
				return;
			}
			
			console.log("refresh csar instance list ");
			
			$.ajax({
				type : "GET",
				url : "getCSARInstanceList.action",
				async : false,
				data : {
					selectedCSAR : selectedCSAR + ".csar",
				},
				error : function() {
					console.log("error while getting the csar instance list");
				},
				success : function(data) {
					processRefreshCSARInstanceList(data);
				}
			});
		}
		
		// processes the refresh of the CSAR instance list
		function processRefreshCSARInstanceList(data) {
			console.log("processRefreshCSARInstanceList");
			
			// if no instances are built
			if (data.availableInstances.length == 0) {
				
				console.log("no instances");
				
				$("#CSARInstanceMenuDiv").children().remove();
				$("#CSARInstanceMenuDiv").append(
					jQuery("<p>").append("No instances built."));
				return;
			}
			
			var table = jQuery('<table id="CSARInstanceMenuTable">');
			table.css("border-spacing", "0");
			table.css("width", "150");
			
			// add a row for each instance
			$.each(data.availableInstances,
				function(index, value) {
					
					var instance = "InstanceItem_" + value.substring(9);
					var tr = jQuery('<tr id="' + instance
						+ '" name="' + value + '"></tr>');
					
					if (instance == selectedCSARInstance) {
						tr.addClass("CSARInstanceListItemSelected");
					} else {
						tr.addClass("CSARInstanceListItemUnselected");
					}
					
					tr.css("height", "26");
					
					var td = jQuery('<td id="justSelect_' + value+'"></td>');
					
					var bool = false;
					$.ajax({
						async : false,
						type : "GET",
						url : "getRunningPlansInformations.action",
						data : {
							csarID : selectedCSAR + ".csar",
							internalInstanceID : index,
						},
						error : function(jqXHR, textStatus, errorThrown) {
							console.log("error");
							console.log(errorThrown);
						},
						success : function(data) {
							
							console.log(data);
							if (data.activePlans.length > 0) {
								bool = true;
							}
						}
					});
					
					if (bool == true) {
						td.append(jQuery('<img src="images/imagesofothers/loading51.gif" width="11" />;'));
						td.append("&nbsp;");
					}
					
					td.append(value);
					
					tr.append(td);
					
					var td = jQuery('<td id="terminate_' + value+'"></td>');
					td.css("width", "50");
					
					tr.append(td);
					
					table.append(tr);
				});
			
			$("#CSARInstanceMenuDiv").children().remove();
			$("#CSARInstanceMenuDiv").append(table);
		}
		
		// this function is activated due an event listener if there is a click on a CSAR-Instance item
		function csarInstanceSelected(event) {
			console.log("csarInstanceSelected");
			
			event.preventDefault();
			
			if (null != selectedCSARInstance) {
				$("#" + selectedCSARInstance).removeClass(
					"CSARInstanceListItemSelected");
				$("#" + selectedCSARInstance).addClass(
					"CSARInstanceListItemUnselected");
			}
			
			selectedCSARInstance = this.id;
			
			// the highlighting
			$("#" + selectedCSARInstance).addClass("CSARInstanceListItemSelected");
			$("#" + selectedCSARInstance).removeClass(
				"CSARInstanceListItemUnselected");
			
			// show new informations
			showBUILDInformations();
			showAvailableManagementPlans();
			showRunningPlans();
			showPlanHistory();
			
			// if the area for the TERMINATION PublicPlan is clicked
			if (event.target.id.substring(0, 10) == "terminate_") {
				getInstanceTerminationPlan(selectedCSAR, selectedCSARInstance);
			}
			
		}
		
		// function which is called due the interval if the manage pane is viewed
		// refreshes the information part of the manage pane
		function refreshCSARInstanceInformations() {
			console.log("refreshCSARInstanceInformations");
			
			refreshCSARInstanceList();
			
			if (selectedCSARInstance != null && selectedCSARInstance != ""
					&& $("#" + selectedCSARInstance).size() == 0) {
				console.log("old instance");
				selectedCSARInstance = null;
				$("#CSARManagementPlansTable tr").remove();
			}
			
			showAvailableManagementPlans();
			showBUILDInformations();
			showRunningPlans();
			showPlanHistory();
		}
		
		// gathers the informations about the available management PublicPlans for a CSAR-Instance
		function showAvailableManagementPlans() {
			
			console.log("showAvailableManagementPlans");
			
			if (null == selectedCSAR || "" == selectedCSAR) {
				return;
			}
			if (null == selectedCSARInstance || "" == selectedCSARInstance) {
				return;
			}
			
			var csar = selectedCSAR;
			var instance = selectedCSARInstance.substring(13);
			var builddone = 0;
			var oldTrs = $("#CSARManagementPlansTable tr");
			
			// check if build is done
			$.ajax({
				async : false,
				type : "GET",
				url : "getBuildPlanFromHistory.action",
				data : {
					csarID : selectedCSAR + ".csar",
					internalInstanceID : instance,
				},
				error : function(jqXHR, textStatus, errorThrown) {
					console.log("error");
					console.log(errorThrown);
				},
				success : function(data) {
					
					console.log(selectedCSAR + " " + selectedCSARInstance);
					
					// if there is a invocation date, the build PublicPlan has finished
					if (data.invocationDate != "") {
						console.log(data.invocationDate);
						builddone = 1;
					} else {

						// the build PublicPlan has not finished, thus no management yet
						oldTrs.remove();
					}
				}
			});
			
			// if build PublicPlan has finished
			if (builddone == 1) {
				console.log("get the available management plans for csar "
						+ selectedCSAR);
				
				// get the management PublicPlan informations
				$.ajax({
					async : false,
					type : "GET",
					url : "getCSARPublicPlans.action",
					// async : false,
					data : {
						selectedCSAR : csar + ".csar",
						
						planType : "OTHERMANAGEMENT",
					},
					success : function(data) {
						
						// build the entries
						var table = jQuery("<div>");
						$("#CSARManagementPlansTable").css("border-spacing",
							"0");
						
						// for each PublicPlan
						$.each(data.publicPlans,
							function(index, publicPlan) {
								
								var tr = jQuery('<tr id="ManagementPlanItem_' + publicPlan.internalPlanID + '" name="' + publicPlan.internalPlanID + '"></tr>');
								
								tr.css("height", "26");
								tr.addClass("CSARManagementPlanItem");
								
								var td = jQuery('<td></td>');
								td.css("width", "24");
								tr.append(td);
								
								var td = jQuery('<td></td>');
								td.append(publicPlan.planID.namespaceURI);
								tr.append(td);
								
								var td = jQuery('<td></td>');
								td.append(publicPlan.planID.localPart);
								tr.append(td);
								
								var td = jQuery('<td></td>');
								td.css("width", "26");
								tr.append(td);
								
								table.append(tr);
							}
						);
						
						$("#CSARManagementPlansTable").children().remove();
						$("#CSARManagementPlansTable").append(table.children());
					},
					error : function() {
						console.log("error");
					}
				});
			}
		}
		
		// this function is called due a event listener if there is a click on one of the management plan items
		function csarManagementPlanSelected(event) {
			console.log("csarManagementPlanSelected");
			
			event.preventDefault();
			
			if (null == selectedCSAR || "" == selectedCSAR) {
				return;
			}
			if (null == selectedCSARInstance || "" == selectedCSARInstance) {
				return;
			}
			
			var planID = $("#" + this.id).attr("name");
			
			// get the input dialog informations
			$.ajax({
				type : "GET",
				url : "getCSARPublicPlans.action",
				async : false,
				data : {
					selectedCSAR : selectedCSAR + ".csar",
					planType : "OTHERMANAGEMENT",
					internalID : planID,
				},
				success : function(data) {
					
					var dialog = null;
					
					// there is only one plan
					$.each(data.publicPlans, function(index, publicPlan) {
						dialog = generateForm(publicPlan);
					});
					
					// set up the dialog
					$("#PlanParameterDialog").dialog("option", "title", "Put in plan parameter details.");
					$("#PlanParameterDialog").dialog({
						buttons : {
							'invoke plan' : function() {
								postManagementPlan(selectedCSAR, planID);
								$("#PlanParameterDialog").dialog('close');
							},
							'Cancel' : function() {
								$("#PlanParameterDialog").dialog('close');
							}
						},
						open : function() {
							$("#PlanParameterDialogContent").append(dialog);
						},
						close : function() {
							$("#PlanParameterDialogContent").empty();
						}
					});
					
					$("#PlanParameterDialog").dialog('open');
				},
				error : function() {
					console.log("error");
				}
			});
		}
		
		// post a management plan
		function postManagementPlan(csarID, internalPlanID) {
			console.log("postManagementPlan");
			
			// get the needed informations
			var planID = $("#PlanParameterDialogContentForm").attr("name");
			var inputvalues = "";
			var type = $("#PlanType").val();
			var instance = selectedCSARInstance.substring(13);
			$("#PlanParameterDialogContentForm input[type=text]").each(
				function() {
					inputvalues = inputvalues + $(this).attr("name")
							+ "$$$$$$$$$$$$$" + $(this).val() + "$$$$$$$$$$$$$!";
				});
			
			// add
			$("#PlanParameterDialogContentForm input[type=password]").each(
					function() {
						// need for to post it due AJAX call
						inputvalues = inputvalues + $(this).attr("name")
								+ "$$$$$$$$$$$$$" + $(this).val() + "$$$$$$$$$$$$$!";
					}
				);
			$("#PlanParameterDialogContentForm textarea").each(
					function() {
						// need for to post it due AJAX call
						inputvalues = inputvalues + $(this).attr("name")
								+ "$$$$$$$$$$$$$" + $(this).val() + "$$$$$$$$$$$$$!";
					}
				);
			var data = {
				csarID : csarID + ".csar",
				planType : type,
				planID : planID,
				internalID : internalPlanID,
				parameters : inputvalues,
				internalInstanceID : instance,
			};
			
			console.log(data);
			
			// do the post
			$.ajax({
				async : false,
				type : "POST",
				url : "postMANAGEMENTInvocation.action",
				data : data,
				error : function(jqXHR, textStatus, errorThrown) {
					console.log("error on plan invocation");
					console.log(errorThrown);
				},
				success : function() {
					console.log("plan invocation success");
				}
			});
		}
		
		// get the BUILD informations of a CSAR-Instance and show them
		function showBUILDInformations() {
			console.log("showBUILDInformations");
			
			if (null == selectedCSAR || "" == selectedCSAR) {
				return;
			}
			if (null == selectedCSARInstance || "" == selectedCSARInstance) {
				return;
			}
			
			var csar = selectedCSAR;
			var container = $("#buildinformations");
			var old = container.children();
			
			var instance = selectedCSARInstance.substring(13);
			$.ajax({
				async : false,
				type : "GET",
				url : "getBuildPlanFromHistory.action",
				data : {
					csarID : selectedCSAR + ".csar",
					internalInstanceID : instance,
				},
				error : function(jqXHR, textStatus, errorThrown) {
					console.log("error");
					console.log(errorThrown);
				},
				success : function(data) {
					
					// show the informations
					var div = jQuery('<div>');
					if (data.invocationDate == "") {
						div.append("build not finished yet");
					} else {
						div.append("build date: " + data.invocationDate);
					}
					container.append(div);
					old.remove();
				}
			});
		}
		
		// show the running plans of a CSAR-Instnace
		function showRunningPlans() {
			console.log("showRunningPlans");
			
			if (null == selectedCSAR || "" == selectedCSAR) {
				return;
			}
			if (null == selectedCSARInstance || "" == selectedCSARInstance) {
				return;
			}
			
			var container = jQuery("<div>");
			var oldContent = $("#activePlans").children();
			
			var instance = selectedCSARInstance.substring(13);
			$.ajax({
				async : false,
				type : "GET",
				url : "getRunningPlansInformations.action",
				data : {
					csarID : selectedCSAR + ".csar",
					internalInstanceID : instance,
				},
				error : function(jqXHR, textStatus, errorThrown) {
					console.log("error");
					console.log(errorThrown);
				},
				success : function(data) {
					
					$.each(data.activePlans,
						function(index, content) {
							
							// show the informations
							var div = jQuery('<div/>');
							div.append(jQuery('<img src="images/imagesofothers/loading51.gif" width="11" />;'));
							div.append("&nbsp;" + content);
							container.append(div);
							var br = jQuery("<br/>");
							container.append(br);
						}
					);
					
					oldContent.remove();
					$("#activePlans").append(container.children());
				}
			});
		}
		
		// get the TERMINATION PublicPlan informations and show them
		function getInstanceTerminationPlan(csarID, selectedCSARInstance) {
			console.log("getInstanceTerminationPlan");
			
			$.ajax({
				type : "GET",
				url : "getCSARPublicPlans.action",
				async : false,
				data : {
					selectedCSAR : csarID + ".csar",
					planType : "TERMINATION",
					internalID : 0,
				},
				success : function(data) {
					
					var dialog = null;
					
					// there is only one plan
					$.each(data.publicPlans, function(index, publicPlan) {
						dialog = generateForm(publicPlan);
					});
					
					// set up the dialog
					$("#PlanParameterDialog").dialog("option", "title", "Put in plan parameter details.");
					$("#PlanParameterDialog").dialog({
						buttons : {
							'invoke plan' : function() {
								postInstanceTermination(csarID);
								$("#PlanParameterDialog").dialog('close');
							},
							'Cancel' : function() {
								$("#PlanParameterDialog").dialog('close');
							}
						},
						open : function() {
							$("#PlanParameterDialogContent").append(dialog);
						},
						close : function() {
							$("#PlanParameterDialogContent").empty();
						}
					});
					
					$("#PlanParameterDialog").dialog('open');
				},
				error : function() {
					console.log("error");
				}
			});
		}
		
		// post the CSAR-Instance termination
		function postInstanceTermination(csarID) {
			console.log("postInstanceTermination");
			
			// gather up the needed informations
			var planid = $("#PlanParameterDialogContentForm").attr("name");
			var inputvalues = "";
			var type = $("#PlanType").val();
			var instance = selectedCSARInstance.substring(13);
			$("#PlanParameterDialogContentForm input[type=text]").each(
				function() {
					inputvalues = inputvalues + $(this).attr("name")
							+ "$$$$$$$$$$$$$" + $(this).val() + "$$$$$$$$$$$$$!";
				});
			
			$("#PlanParameterDialogContentForm input[type=password]").each(
					function() {
						// need for to post it due AJAX call
						inputvalues = inputvalues + $(this).attr("name")
								+ "$$$$$$$$$$$$$" + $(this).val() + "$$$$$$$$$$$$$!";
					}
				);
			$("#PlanParameterDialogContentForm textarea").each(
					function() {
						// need for to post it due AJAX call
						inputvalues = inputvalues + $(this).attr("name")
								+ "$$$$$$$$$$$$$" + $(this).val() + "$$$$$$$$$$$$$!";
					}
				);
			// post the termination
			$.ajax({
				async : false,
				type : "POST",
				url : "postTERMINATIONInvocation.action",
				data : {
					csarID : csarID + ".csar",
					planType : type,
					planID : planid,
					internalID : 0,
					parameters : inputvalues,
					internalInstanceID : instance,
				},
				error : function(jqXHR, textStatus, errorThrown) {
					console.log("error on plan invocation");
					console.log(errorThrown);
				},
				success : function() {
					
					// success thus refresh the view
					console.log("plan invocation success");
					selectedCSARInstance = null;

					$("#activePlans").children().remove();
					$("#buildinformations").children().remove();
					$("#planHistory").children().remove();
					$("#CSARManagementPlansTable tr").remove();
					
					refreshCSARInstanceList();
					$("#buildinformations").children().remove();
				}
			});
		}
		
		// show the plan History of CSAR-Instance
		function showPlanHistory() {
			console.log("show plan history");
			
			if (null == selectedCSAR || "" == selectedCSAR) {
				return;
			}
			if (null == selectedCSARInstance || "" == selectedCSARInstance) {
				return;
			}
			
			var oldContent = $("#planHistory").children();
			
			// get the informations
			$.ajax({
				async : false,
				type : "GET",
				url : "getHistory.action",
				data : {
					csarID : selectedCSAR + ".csar",
					internalInstanceID : selectedCSARInstance.substring(13),
				},
				error : function(jqXHR, textStatus, errorThrown) {
					console.log("error on plan invocation");
					console.log(errorThrown);
				},
				success : function(data) {
					
					// show the informations
					var container = jQuery("<div>");
					var bigTable = $('<table id="planHistoryTable" />');
					container.append(bigTable);
					
					// for each PublicPlan in History
					$.each(
						data.plans,
						function(index, content) {
							
							var bigtr = jQuery('<tr id="' + content.operationName + '" class="planHistoryItem" />');
							var bigtd = jQuery("<td />");
							bigtr.append(bigtd);
							var img;
							if (content.hasFailed === false) {
								img = '<img src="images/imagesofothers/check-24-ns.png" width="15" />;';
							} else {
								img = '<img src="images/imagesofothers/warning-24-ns.png" width="15" />;';
							}
							bigtd.append(jQuery(img));
							bigtd.append(jQuery("<b/>").append(
								"&nbsp;" + content.interfaceName
										+ ":&nbsp;"
										+ content.planID.localPart));
							
							bigTable.append(bigtr);
							
							var bigtr = jQuery('<tr id="' + content.operationName + '_details" class="planHistoryDetails" />');
							var bigtd = jQuery("<td />");
							bigtr.append(bigtd);
							bigTable.append(bigtr);
							
							var table = jQuery('<table />');
							bigtd.append(table);
							
							var tr = jQuery('<tr>');
							table.append(tr);
							var td = jQuery('<td colspan="2" />');
							td.append("<u>input parameter:</u>");
							tr.append(td);
							
							$.each(content.inputParameter, function(index,
									param) {
								var tr = jQuery('<tr/>');
								table.append(tr);
								var td = jQuery('<td>' + param.name
										+ "</td>");
								tr.append(td);
								var td = jQuery('<td>:&nbsp;' + param.value
										+ "</td>");
								tr.append(td);
							});
							
							var tr = jQuery('<tr></tr>');
							table.append(tr);
							var td = jQuery('<td colspan="2" />');
							td.append("<u>output parameter:</u>");
							tr.append(td);
							
							$.each(content.outputParameter, function(
									index, param) {
								var tr = jQuery('<tr/>');
								table.append(tr);
								var td = jQuery('<td>' + param.name
										+ "</td>");
								tr.append(td);
								var td = jQuery('<td>:&nbsp;' + param.value
										+ "</td>");
								tr.append(td);
							});
							
							var a = jQuery('<a id="invoke_' + content.operationName + '" href="#" />');
							a.addClass("styledButton");
							a.append(jQuery('<div class="left" />'));
							a
									.append(jQuery('<div class="middle">invoke again</a>'));
							a.append(jQuery('<div class="right" />'));
							
							bigtd.append(a);
						});
					
					oldContent.remove();
					$("#planHistory").append(container.children());
					
					if (lastShowedPlan == null) {
						$(".planHistoryDetails").css("display", "none");
					} else {
						console.log("argh");
						$(".planHistoryDetails").not("#" + lastShowedPlan).css(
							"display", "none");
					}
				}
			});
		}
		
		// this function processes the click on a PublicPlan in History to show the details
		function showPlanHistoryDetails(event) {
			console.log("showPlanHistoryDetails");
			
			if (null == selectedCSAR || "" == selectedCSAR) {
				return;
			}
			if (null == selectedCSARInstance || "" == selectedCSARInstance) {
				return;
			}
			
			event.preventDefault();
			console.log("show history details");
			if ($("#" + this.id).attr("class") === "planHistoryItem") {
				
				if ($("#" + this.id + "_details").css("display") === "none") {
					$(".planHistoryDetails").fadeOut(500);
					$("#" + this.id + "_details").fadeIn(500);
					lastShowedPlan = $("#" + this.id + "_details").attr("id");
					console.log(lastShowedPlan);
				} else {
					$(".planHistoryDetails").fadeOut(500);
					lastShowedPlan = null;
				}
				
			}
		}
		
		// this method calls the dialog for invoking a PublicPlan in History again
		function showPlanHistoryDialog(event) {
			console.log("showPlanHistoryDialog");
			event.preventDefault();
			console.log("show dialog for plan of history");
			
			if (null == selectedCSAR || "" == selectedCSAR) {
				return;
			}
			if (null == selectedCSARInstance || "" == selectedCSARInstance) {
				return;
			}
			
			// get the input dialog informations
			$.ajax({
				type : "GET",
				url : "getSpecificPlanFromHistory.action",
				async : false,
				data : {
					csarID : selectedCSAR + ".csar",
					internalInstanceID : selectedCSARInstance.substring(13),
					correlationID : this.id.substring(7),
				},
				success : function(data) {
					
					var plan = data.plans[0];
					
					$("#PlanParameterDialog").dialog("option", "title", "Put in plan parameter details.");
					$("#PlanParameterDialog").dialog({
						buttons : {
							'invoke plan' : function() {
								postManagementPlan(selectedCSAR, plan.internalPlanID);
								$("#PlanParameterDialog").dialog('close');
							},
							'Cancel' : function() {
								$("#PlanParameterDialog").dialog('close');
							}
						},
						open : function() {
							
							// show the dialog
							
							var total = jQuery("<div />");
							
							total.append(plan.planID.localPart + "<p/>");
							
							var planID = '{' + plan.planID.namespaceURI + '}' + plan.planID.localPart;
							
							var form = jQuery('<form id="PlanParameterDialogContentForm" name="'+ planID +'" />');
							total.append(form);
							
							var input = jQuery('<input type="hidden" id="PlanType" value="' + plan.planType + '">');
							form.append(input);
							
							var table = jQuery("<table>");
							form.append(table);
							
							$.each(plan.inputParameter,
								function(index, parameter) {
									
									if (parameter.type != "correlation" && parameter.type != "callbackaddress" && parameter.type != "containerApiAddress" && parameter.type != "csarName") {
										
										var tr = jQuery("<tr>");
										table.append(tr);
										
										var td = jQuery("<td>");
										tr.append(td);
										td.append(parameter.name + ":&nbsp;");
										
										var td = jQuery("<td>");
										tr.append(td);
										
										var input;
										if (parameter.type == "string-password"){
											input = jQuery("<input type=\"password\" name=\""
												+ parameter.name + "\" size=\"30\" />");
										} else if (parameter.type == "string-multiline"){
											input = jQuery("<textarea name=\""
												+ parameter.name + "\" cols=\"30\" rows=\"2\" />");
										} else {
											input = jQuery("<input type=\"text\" name=\""
												+ parameter.name + "\" size=\"30\" />");
										}
										input.val(parameter.value);
										td.append(input);
										
									}
								});
							
							total.append(jQuery("<p/>"));
							
							$("#PlanParameterDialogContent").append(total);
						},
						close : function() {
							$("#PlanParameterDialogContent").empty();
						}
					});
					
					$("#PlanParameterDialog").dialog('open');
				},
				error : function() {
					console.log("error");
				}
			});
		}
	}
</script>