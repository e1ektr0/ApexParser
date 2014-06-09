public with sharing class MEP_ChannelFilter {
	public String searchText {get;set;}
	public Integer resultOffset = 0;
	public Integer resultLimit = 25;
	public String userId{get;set;}
	public String userIds{get;set;}
	public MEP_SortingField sortingField{get;set;} 
}