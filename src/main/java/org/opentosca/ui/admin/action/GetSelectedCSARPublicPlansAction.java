package org.opentosca.ui.admin.action;

import java.util.ArrayList;
import java.util.List;

import org.opentosca.model.consolidatedtosca.PublicPlan;
import org.opentosca.ui.admin.action.client.ContainerClient;

import com.opensymphony.xwork2.ActionSupport;

/**
 * Gets the PublicPlans of a specific type (BUILD, OTHERMANAGEMENT, TERMINATION)
 * of a CSAR.
 * 
 * @author Christian Endres - endrescn@studi.informatik.uni-stuttgart.de
 * 
 */
public class GetSelectedCSARPublicPlansAction extends ActionSupport {
	
	private static final long	serialVersionUID	= -1306906449002508071L;
	
	private String				selectedCSAR		= "";
	private String				planType			= "";
	private List<PublicPlan>	publicPlans			= new ArrayList<PublicPlan>();
	// the PublicPlan ID
	private int					internalID			= -1;
	
	
	@Override
	public String execute() {
	
		ContainerClient client = ContainerClient.getInstance();
		
		// the PublicPlan-ID, if set to -1 the get all PublicPlans of the type
		if (this.internalID == -1) {
			
			// get the links to the PublicPlans (contains the PublicPlan ID)
			List<String[]> value = client.getLinksFromUri(ContainerClient.BASEURI
					+ "/CSARs/"
					+ this.selectedCSAR
					+ "/PublicPlans/"
					+ this.planType, false);
			
			int size = value.size();
			
			if (size > 0) {
				// means there are #size PublicPlans
				System.out.println("There are " + size
						+ " PublicPlans for CSAR " + this.selectedCSAR);
				
				for (int itr = 0; itr < size; itr++) {
					
					// get each PublicPlan
					String res = value.get(itr)[1];
					int id = Integer.parseInt(res.substring(res.lastIndexOf("/") + 1));
					PublicPlan plan = client.getPublicPlans(this.selectedCSAR, this.planType, id);
					
					// store the PublicPlan to the return list
					this.publicPlans.add(plan);
				}
			}
		} else {
			// get a specific PublicPlan
			this.publicPlans.add(client.getPublicPlans(this.selectedCSAR, this.planType, this.internalID));
		}
		
		return "success";
	}
	
	public int getInternalID() {
	
		return this.internalID;
	}
	
	public String getPlanType() {
	
		return this.planType;
	}
	
	public List<PublicPlan> getPublicPlans() {
	
		return this.publicPlans;
	}
	
	public String getSelectedCSAR() {
	
		return this.selectedCSAR;
	}
	
	public void setInternalID(int internalID) {
	
		this.internalID = internalID;
	}
	
	public void setPlanType(String planType) {
	
		this.planType = planType;
	}
	
	public void setPublicPlans(List<PublicPlan> publicPlans) {
	
		this.publicPlans = publicPlans;
	}
	
	public void setSelectedCSAR(String selectedCSAR) {
	
		this.selectedCSAR = selectedCSAR;
	}
}
