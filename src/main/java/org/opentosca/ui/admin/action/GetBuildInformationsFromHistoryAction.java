package org.opentosca.ui.admin.action;

import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.opentosca.model.consolidatedtosca.PublicPlan;
import org.opentosca.ui.admin.action.client.ContainerClient;

import com.opensymphony.xwork2.ActionSupport;

/**
 * 
 * This class is the Struts2 Action which gathers the BUILD informations of a
 * CSAR Instance from the container.
 * 
 * @author Christian Endres - endrescn@studi.informatik.uni-stuttgart.de
 * 
 */
public class GetBuildInformationsFromHistoryAction extends ActionSupport {
	
	private static final long	serialVersionUID	= -252865773415470831L;
	private String				csarID;
	private String				internalInstanceID;
	private String				invocationDate		= "";
	private PublicPlan			publicPlan;
	
	
	@Override
	public String execute() {
	
		System.out.println("get the build plan from history");
		
		ContainerClient client = ContainerClient.getInstance();
		
		// get all the CorrelationIDs in History for CSARID and InstanceID
		List<String[]> correlationIDStringArrays = client.getLinksFromUri(ContainerClient.BASEURI
				+ "/CSARs/"
				+ this.csarID
				+ "/Instances/"
				+ this.internalInstanceID + "/history", false);
		
		int size = correlationIDStringArrays.size();
		System.out.println("Plans in history: " + size);
		
		// there is one or more PublicPlan in History, thus the BUILD is done
		if (size > 0) {
			System.out.println("There are " + size + " plans in history");
			
			List<String> correlationList = new ArrayList<String>();
			
			// get the CorrelationIDs
			for (int itr = 0; itr < size; itr++) {
				String res = correlationIDStringArrays.get(itr)[0];
				System.out.println(res);
				correlationList.add(res);
			}
			
			// sort, so the first one is the build plan (because of timestamp)
			Collections.sort(correlationList);
			
			String buildCorrelation = correlationList.get(0);
			
			System.out.println("build correlation: " + buildCorrelation);
			
			// calculate the date of invocation
			long millis = Long.parseLong(buildCorrelation.substring(0, buildCorrelation.indexOf("-")));
			System.out.println(millis);
			Date date = new Date(millis);
			SimpleDateFormat formatter = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
			this.invocationDate = formatter.format(date);
			System.out.println(this.invocationDate);
			
			// get the PublicPlan
			this.publicPlan = client.getPublicPlanFromHistory(this.csarID, this.internalInstanceID, buildCorrelation);
			System.out.println(this.publicPlan.getPlanID());
		}
		
		return "success";
	}
	
	public String getCsarID() {
	
		return this.csarID;
	}
	
	public String getInternalInstanceID() {
	
		return this.internalInstanceID;
	}
	
	public String getInvocationDate() {
	
		return this.invocationDate;
	}
	
	public PublicPlan getPublicPlan() {
	
		return this.publicPlan;
	}
	
	public void setCsarID(String csarID) {
	
		this.csarID = csarID;
	}
	
	public void setInternalInstanceID(String internalInstanceID) {
	
		this.internalInstanceID = internalInstanceID;
	}
	
	public void setInvocationDate(String invocationDate) {
	
		this.invocationDate = invocationDate;
	}
	
	public void setPublicPlan(PublicPlan publicPlan) {
	
		this.publicPlan = publicPlan;
	}
	
}
