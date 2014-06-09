//deprecate 05/09/2012 SLegostaev
public abstract class MEP_BaseChatterFilter implements MEP_ChatterFilter {
	
	public static final Integer DEFAULT_PAGE_SIZE = MEP_ApplicationSettings.getIntegerValue('DEFAULT_PAGE_SIZE');
	public static final String CREATED_DATE_SORT = 'CreatedDateDesc';
	public static final String LAST_MODIFIED_DATE_SORT = 'LastModifiedDateDesc';
	
	public Integer pageSize {get;set;}
	public String sortBy {get;set;}
	public String nextPage {get;set;}
	
	public MEP_BaseChatterFilter() {
		initPageSize();
		initSort();
	}
	
	public virtual void initPageSize() {
		pageSize = DEFAULT_PAGE_SIZE;
	}
	
	public virtual void initSort() {
		sortBy = CREATED_DATE_SORT;
	}
	
	public virtual String getParametersString() {
		return 'pageSize=' + pageSize + '&sort=' + sortBy;
	}
}