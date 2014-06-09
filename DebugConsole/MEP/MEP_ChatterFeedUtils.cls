//
//This class provides utility methods for chatter
//
//Author: Gennadiy Pervukhin
public with sharing class MEP_ChatterFeedUtils
{
	//
	//Public static service methods
	//
	public static String createChatterUserLink(String mepUserFullName)
    {
    	return (MEP_StringUtils.isNullOrEmpty(mepUserFullName) ? '' : '@[' + mepUserFullName + ']');
    }
    
	public static MEP_FeedDTO createMepFeed(String feedText)
	{
		MEP_FeedDTO mf = null;
		if (feedText.contains('@['))
		{
            List<String> segments = getSegments(feedText);
            List<MEP_MessageSegmentDTO> segmentsList = new List<MEP_MessageSegmentDTO>();
            for (String s : segments)
            {
                MEP_MessageSegmentDTO ms = new MEP_MessageSegmentDTO();
                //try to get chatter user by mention
                String chatterUserId = getUserIdByMention(s);
                //if chatter user exists then we use mention else we output segment as a text  
                if (!MEP_StringUtils.isNullOrEmpty(chatterUserId))
                {
                    ms.id = chatterUserId;
                    ms.type = 'mention';
                }
                else
                {
                    ms.type = 'text';
                    ms.text = ' ' + s;
                }
                segmentsList.add(ms);
                
                if (ms.type == 'mention') {
                	MEP_MessageSegmentDTO ms2 = new MEP_MessageSegmentDTO();
                	ms2.type = 'text';
                    ms2.text = ' ';
                    segmentsList.add(ms2);
                }
            }
            mf = new MEP_FeedDTO();
            mf.body = feedText;
            mf.messageSegment = segmentsList;
        }
        else
        {
             mf = new MEP_FeedDTO(feedText, 'Text');
        }
        return mf;
	}
	//
	
	//
	//Private static methods
	//
	private static String getUserIdByMention(String mention)
	{
		if (mention.startsWith('@'))
		{
	        String fullName = mention.replace('@[', '').replaceAll(']', '');
	        List<MEP_USERS__c> u = MEP_MepUserDAO.getMepUsersByPartialNameForChatter(fullName);
	        System.debug('********* ' + u.size());
	        if (u != null && u.size() > 0)
	        {
	            return u.get(0).SALESFORCE_CHATTER_USER_REFERENCE__c;
	        }
		} 
        return null;
    }
    
    private static List<String> getSegments(String feedString)
    {
        String[] strArr = feedString.split(' ');
        String newString = null;
        List<String> ss = new List<String>();
        for (String str : strArr)
        {
            if (str.startsWith('@['))
            {
                if (newString == null)
                {
                    newString = str;
                }
                else
                {
                    ss.add(newString);
                    newString = str;
                }
                
            }
            else if (str.endsWith(']'))
            {
                newString += ' ' + str;
                ss.add(newString);
                newString = null;
            }
            else
            {
                if (newString == null)
                {
                    newString = str;
                }
                else
                {
                    newString += ' ' + str;
                }
            }
        }
        
        if (newString != null)
        {
            ss.add(newString);
        }
        return ss;
    }
    
    
    
    //
    //Tests
    //
    @IsTest
    private static void test_getSegments()
    { 
    	List<String> segments = getSegments('@[FMR, Speaker 1], you have a new task \'Book Travel\' on 2012-08-01 05:00:00');
    	System.debug(segments.size());
    	for (String segment : segments)
    	{
    		System.debug(segment);
    	}
    }
    
    @IsTest
    private static void test_getUserIdByMention()
    { 
    	String userId = getUserIdByMention('@[DEASY, NIALL J.]');
    	System.debug(userId);
    }
	//
}