package org.opentosca.ui.admin.action;

import java.util.ArrayList;
import java.util.List;

import org.opentosca.model.consolidatedtosca.PublicPlan;
import org.opentosca.ui.admin.action.client.ContainerClient;

import com.opensymphony.xwork2.ActionSupport;

/**
 * Gathers up a specific PublicPlan from History.
 * 
 * @author Christian Endres - endrescn@studi.informatik.uni-stuttgart.de
 * 
 */
public class GetCSARInstanceOnePlanFromHistoryAction extends ActionSupport {
	
	private static final long	serialVersionUID	= -252865773415470831L;
	private String				csarID;
	private String				internalInstanceID;
	private String				correlationID;
	private List<PublicPlan>	plans				= new ArrayList<PublicPlan>();
	
	
	/**
	 * Gathers up a specific PublicPlan from History.
	 */
	@Override
	public String execute() {
	
		System.out.println("get the plans from history");
		
		ContainerClient client = ContainerClient.getInstance();
		
		// get the PublicPlan
		PublicPlan publicPlan = client.getPublicPlanFromHistory(this.csarID, this.internalInstanceID, this.correlationID);
		
		this.plans.add(publicPlan);
		
		return "success";
	}
	
	public String getCorrelationID() {
	
		return this.correlationID;
	}
	
	public String getCsarID() {
	
		return this.csarID;
	}
	
	public String getInternalInstanceID() {
	
		return this.internalInstanceID;
	}
	
	public List<PublicPlan> getPlans() {
	
		return this.plans;
	}
	
	public void setCorrelationID(String correlationID) {
	
		this.correlationID = correlationID;
	}
	
	public void setCsarID(String csarID) {
	
		this.csarID = csarID;
	}
	
	public void setInternalInstanceID(String internalInstanceID) {
	
		this.internalInstanceID = internalInstanceID;
	}
	
	public void setPlans(List<PublicPlan> plans) {
	
		this.plans = plans;
	}
	
}
