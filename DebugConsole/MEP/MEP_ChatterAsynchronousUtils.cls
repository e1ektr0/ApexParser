//
//This class contains methods which call methods from 'MEP_ChatterDAO' asynchronously
//
//Author: Gennadiy Pervukhin
public with sharing class MEP_ChatterAsynchronousUtils
{
	//
	//Private static methods
	//
	private static MEP_OAuthHolder deserializeAuthHolder(String serializedAuthHolder)
	{
		MEP_OAuthHolder authHolder;
		try
        {
        	authHolder = (MEP_OAuthHolder)JSON.deserialize(
            	serializedAuthHolder, MEP_OAuthHolder.class);
        }
        catch (JSONException e)
        {
            authHolder = null;
            System.debug(e.getMessage());
        }
        
        return authHolder;
	}
	
	@future (callout=true)
	private static void createFeedForGroupAsynchronously(String groupId, String feedText,
		String serializedAuthHolder)
	{
		MEP_OAuthHolder authHolder = deserializeAuthHolder(serializedAuthHolder);
		if (authHolder == null)
		{
			authHolder = MEP_OAuthHolder.createForSystemUser();
		}
		
		MEP_FeedDTO mepFeed = MEP_ChatterFeedUtils.createMepFeed(feedText);
		MEP_ChatterDAO.createNewFeedForGroup(groupId, mepFeed, authHolder);
	}
	//
	
	
	public static void createFeedForGroup(String groupId, String feedText, MEP_OAuthHolder authHolder)
	{
		try
		{
			if (!MEP_StringUtils.isNullOrEmpty(groupId) && !MEP_StringUtils.isNullOrEmpty(feedText)
				&& authHolder != null && authHolder.isStateCorrect)
			{
				createFeedForGroupAsynchronously(groupId, feedText, JSON.serialize(authHolder));
			}
			else
			{
				System.debug(LoggingLevel.WARN, 'MEP_ChatterAsynchronousUtils: incorrect parameters');
			}
			
		}
		catch (System.LimitException e)
		{
			System.debug(LoggingLevel.WARN, 'MEP_ChatterAsynchronousUtils: ' + e.getMessage());
		}
		catch (System.Exception e)
		{
			System.debug(LoggingLevel.WARN, 'MEP_ChatterAsynchronousUtils: ' + e.getMessage());
		}
	}
	
	public static void createFeedForGroupBySystem(String groupId, String feedText)
	{
		try
		{
			if (!MEP_StringUtils.isNullOrEmpty(groupId) && !MEP_StringUtils.isNullOrEmpty(feedText))
			{
				createFeedForGroupAsynchronously(groupId, feedText, null);
			}
			else
			{
				System.debug(LoggingLevel.WARN, 'MEP_ChatterAsynchronousUtils: incorrect parameters');
			}
		}
		catch (System.LimitException e)
		{
			System.debug('MEP_ChatterAsynchronousUtils: ' + e.getMessage());
		}
		catch (System.Exception e)
		{
			System.debug('MEP_ChatterAsynchronousUtils: ' + e.getMessage());
		}
	}
}