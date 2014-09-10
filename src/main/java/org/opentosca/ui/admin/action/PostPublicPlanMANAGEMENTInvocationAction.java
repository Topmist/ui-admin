package org.opentosca.ui.admin.action;

import java.util.List;

import javax.xml.namespace.QName;

import org.opentosca.model.consolidatedtosca.Parameter;
import org.opentosca.model.consolidatedtosca.PublicPlan;
import org.opentosca.ui.admin.action.client.ContainerClient;

import com.opensymphony.xwork2.ActionSupport;

/**
 * POST of a OTHERMANAGEMENT PublicPlan.
 * 
 * @author Christian Endres - endrescn@studi.informatik.uni-stuttgart.de
 * 
 */
public class PostPublicPlanMANAGEMENTInvocationAction extends ActionSupport {
	
	private static final long	serialVersionUID	= -5469450674071901529L;
	
	private String				csarID;
	private String				planType			= "OTHERMANAGEMENT";
	
	private String				planID;
	
	private String				parameters;
	
	private int					internalID			= -1;
	private String				internalInstanceID;
	
	
	@Override
	public String execute() {
	
		// set the needed informations
		PublicPlan publicPlan = new PublicPlan();
		publicPlan.setCSARID(this.csarID);
		publicPlan.setPlanType(this.planType);
		publicPlan.setInternalPlanID(this.internalID);
		publicPlan.setPlanID(new QName(this.planID));
		publicPlan.setInternalInstanceInternalID(Integer.parseInt(this.internalInstanceID));
		
		// extract the parameters
		for (String str : this.parameters.split("\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$!")) {
			Parameter param = new Parameter();
			String[] str2 = str.split("\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$\\$");
			param.setName(str2[0]);
			if (str2.length == 2) {
				param.setValue(str2[1]);
			} else {
				param.setValue("");
			}
			
			publicPlan.getInputParameter().add(param);
		}
		
		// post
		ContainerClient client = ContainerClient.getInstance();
		List<String> result = client.postInstanceManagementInvocation(publicPlan, Integer.parseInt(this.internalInstanceID));
		
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
	
	public String getInternalInstanceID() {
	
		return this.internalInstanceID;
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
	
	public void setInternalInstanceID(String internalInstanceID) {
	
		this.internalInstanceID = internalInstanceID;
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
