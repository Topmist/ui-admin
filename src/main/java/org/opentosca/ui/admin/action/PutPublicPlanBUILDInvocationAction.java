package org.opentosca.ui.admin.action;

import java.util.List;

import javax.xml.namespace.QName;

import org.opentosca.model.consolidatedtosca.Parameter;
import org.opentosca.model.consolidatedtosca.PublicPlan;
import org.opentosca.ui.admin.action.client.ContainerClient;

import com.opensymphony.xwork2.ActionSupport;

/**
 * This Action is a PUT invocation of a BUILD PublicPlan.
 * 
 * @author Christian Endres - endrescn@studi.informatik.uni-stuttgart.de
 * 
 */
public class PutPublicPlanBUILDInvocationAction extends ActionSupport {
	
	private static final long	serialVersionUID	= -5469450674071901529L;
	
	private String				csarID;
	private String				planType;
	private String				planID;
	private String				parameters;
	private int					internalID			= 0;
	
	
	@Override
	public String execute() {
	
		// set all the needed informations
		PublicPlan publicPlan = new PublicPlan();
		publicPlan.setCSARID(this.csarID);
		publicPlan.setPlanType(this.planType);
		publicPlan.setInternalPlanID(this.internalID);
		publicPlan.setPlanID(new QName(planID.substring(1, planID.indexOf("}")), planID.substring(planID.indexOf("}") + 1, planID.length())));
		
		// split the parameters, they are stored inside one String due the AJAX
		// call
		for (String str : this.parameters.split("\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$!")) {
			Parameter param = new Parameter();
			String[] str2 = str.split("\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$");
			param.setName(str2[0]);
			param.setValue(str2[1]);
			publicPlan.getInputParameter().add(param);
		}
		
		System.out.println("invoke build plan " + publicPlan.getPlanID().toString());
		
		// PUT
		ContainerClient client = ContainerClient.getInstance();
		List<String> result = client.putPublicPlanBUILDInvocation(publicPlan);
		
		for (String str : result) {
			System.out.println(str);
		}
		
		return result.get(0);
	}
	
	public String getCsarID() {
	
		return this.csarID;
	}
	
	public int getInternalID() {
	
		return this.internalID;
	}
	
	public String getParameters() {
	
		return this.parameters;
	}
	
	public String getPlanID() {
	
		return this.planID;
	}
	
	public String getPlanType() {
	
		return this.planType;
	}
	
	public void setCsarID(String csarID) {
	
		this.csarID = csarID;
	}
	
	public void setInternalID(int internalID) {
	
		this.internalID = internalID;
	}
	
	public void setParameters(String parameters) {
	
		this.parameters = parameters;
	}
	
	public void setPlanID(String planID) {
	
		this.planID = planID;
	}
	
	public void setPlanType(String planType) {
	
		this.planType = planType;
	}
	
}
