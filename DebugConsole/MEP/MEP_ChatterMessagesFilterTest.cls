@isTest
public with sharing class MEP_ChatterMessagesFilterTest 
{
	private static testMethod void test_MEP_ChatterMessagesFilter_EmptyConstructor()
	{
		MEP_ChatterMessagesFilter filter = new MEP_ChatterMessagesFilter();
		System.assertEquals(filter.pageSize,MEP_ChatterMessagesFilter.DEFAULT_PAGE_SIZE);
		System.assertEquals(filter.sortBy,MEP_ChatterMessagesFilter.CREATED_DATE_SORT);
	}
	
	private static testMethod void test_MEP_ChatterMessagesFilter()
	{
		Integer pageSize = 40;
		MEP_ChatterMessagesFilter filter = new MEP_ChatterMessagesFilter(pageSize);
		System.assertEquals(filter.pageSize,pageSize);
		System.assertEquals(filter.sortBy,MEP_ChatterMessagesFilter.CREATED_DATE_SORT);
	}
	private static testMethod void test_MEP_ChatterMessagesFilter_getParametersString()
	{
		MEP_ChatterMessagesFilter filter = new MEP_ChatterMessagesFilter();
		filter.nextPage = 'test1\\?test2';
		filter.searchText = '#xxx';
		String result = filter.getParametersString();
		System.assertEquals(result,'test2&q=%23xxx');
		filter.searchText = null;
		result = filter.getParametersString();
		System.assertEquals(result,'test2');
	}
}