public with sharing class MEP_ChatterGroupArchiveManagerImpl implements MEP_ArchiveManager {

	private String groupId;
	private MEP_OAuthHolder holder;
	
	private Pagereference exportPage= Page.MEP_GroupFeedsExportToPDF;
	
	public MEP_ChatterGroupArchiveManagerImpl(String groupId) {
		this.groupId = groupId;
	}
	
	public MEP_ChatterGroupArchiveManagerImpl(String groupId, MEP_OAuthHolder holder) {
		this.groupId = groupId;
		this.holder = holder;
	}
	
	public Blob createArchive() {
		if (groupId != null) {
		 //	exportPage = Page.MEP_GroupFeedsExportToPDF;
			Pagereference page = generateArchive();
			if (page != null) {
			 return page.getContent();
			}
		    System.debug('No archive generated');
		}
		return null;
	}
	
	public Blob createArchiveInPDF() {
		if (groupId != null) {
			//exportPage = Page.MEP_GroupFeedsExportToPDF;
			return generateArchive().getContentAsPdf();
		}
		return null;
	}
	
	private Pagereference generateArchive() {
		exportPage.getParameters().put('groupId', groupId);
		if (holder != null) {
			exportPage.getParameters().put(MEP_CookieManager.ACCESS_TOKEN, holder.oAuthToken);
			exportPage.getParameters().put(MEP_CookieManager.INSTANCE_URL, holder.instanceUrl);
			exportPage.getParameters().put(MEP_CookieManager.MEP_USER_ID, holder.mepUserId);
		} else {
			exportPage.getParameters().put(MEP_CookieManager.ACCESS_TOKEN, MEP_CookieManager.getCookieData(MEP_CookieManager.ACCESS_TOKEN));
			exportPage.getParameters().put(MEP_CookieManager.INSTANCE_URL, MEP_CookieManager.getCookieData(MEP_CookieManager.INSTANCE_URL));
			exportPage.getParameters().put(MEP_CookieManager.MEP_USER_ID, MEP_CookieManager.getCookieData(MEP_CookieManager.MEP_USER_ID));
		}

		return exportPage;
			
	}
	
}