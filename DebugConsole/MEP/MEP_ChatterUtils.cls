//
//This class provides utility methods for Chatter
//
//Author: Gennadiy Pervukhin
public with sharing class MEP_ChatterUtils
{

	//chatter group have limit for name (40 symbols), if event name length less them 40 symbols then event name will be shortened.
	public static String generateChatterGroupName(String eventName) {
    	if (eventName.length() > 40) {
    		String[] partsName = eventName.split(' ');
    		if (partsName.size() > 1) {
    			String chatterGroupName = '';
    			for (Integer i = partsName.size() - 1; i >= 0; i-- ) {
    				if (partsName[i].toLowerCase().equals('fidelity') 
    					|| partsName[i].toLowerCase().equals('meeting')) {
    					continue;
    				}
    				
    				if (chatterGroupName.length() + partsName[i].length() + 1 <= 40) {
    					chatterGroupName = partsName[i] + ' ' + chatterGroupName;
    				} else {
    					return chatterGroupName;
    				}
    			}
    		} else {
    			return eventName.substring(40);
    		}
    	}
    	return eventName;
    }
}