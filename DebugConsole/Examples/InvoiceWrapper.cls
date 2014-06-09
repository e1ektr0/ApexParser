/**
 * @Author          : Bhushan Adhikari (Innoveer Solutions) <bhushan.adhikari@cloudsherpas.com>
 * @Date Created    : March 21, 2013     
 * @Description     : This Class serves as wrapper class for storing Invoice Territory Reps Id, Region and  Role. 
 *					  This class is being referred in InvoiceTriggerHelper Class.
 */
public class InvoiceWrapper {
	//sotres Invoice Rep Id
	public id territoryRepid; 
	//stores Invoice id
  	public id invid;
  	//stores Invoice rep region
  	public String territoryRepReg;
  	//stores Invoice rep role
  	public String territoryRepRole;
	
	public InvoiceWrapper(id territoryRepid, id invid, String territoryRepReg, String territoryRepRole ){
	  	this.territoryRepid = territoryRepid;
	  	this.Invid = invid;
	  	this.territoryRepReg = territoryRepReg;
	  	this.territoryRepRole = territoryRepRole;  	
  	}
}