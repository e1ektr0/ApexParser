/*
*	Author: SLegostaev
*	Using for filtring of chatter messages
*/
public with sharing class MEP_ChatterMessagesFilter implements MEP_ChatterFilter {
	
	public static final Integer DEFAULT_PAGE_SIZE = MEP_ApplicationSettings.getIntegerValue('DEFAULT_PAGE_SIZE');
	public static final String CREATED_DATE_SORT = 'CreatedDateDesc';
	public static final String LAST_MODIFIED_DATE_SORT = 'LastModifiedDateDesc';
	
	public Integer pageSize {get;set;}
	public String sortBy {get;set;}
	public String nextPage {get;set;}
	public String searchText {get;set;}
	
	public MEP_ChatterMessagesFilter() {
		initPageSize();
		initSort();
	}

	public MEP_ChatterMessagesFilter(Integer pageSize) {
		this.pageSize = pageSize;
		initSort();
	}
	
	public void initPageSize() {
		pageSize = DEFAULT_PAGE_SIZE;
	}
	
	public void initSort() {
		sortBy = CREATED_DATE_SORT;
	}
	
	public String getParametersString() {
		String str = 'pageSize=' + pageSize + '&sort=' + sortBy;
		if (!MEP_StringUtils.isNullOrEmpty(nextPage)) {
			String[] params = nextPage.split('\\?');
			if (params.size() == 2) {
				str = params[1];
			}
		}

		if (searchText != null) {
			if (searchText.startsWith('#')) {
				searchText = searchText.replaceFirst('#', '%23');
			}
			return str += '&q=' + searchText;
			
		}
		return str;
	}
}