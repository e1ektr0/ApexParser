@isTest
private class MEP_ChatterGroupArchiveManagerImplTest 
{
	static testMethod void test_MEP_ChatterGroupArchiveManagerImpl()
	{
		MEP_TestUtils.Autorize();
		MEP_ChatterGroupArchiveManagerImpl managerTest = new MEP_ChatterGroupArchiveManagerImpl('ih3i77rt2b');
		
		System.assert(managerTest.createArchive()!=null);
		System.assert(managerTest.createArchiveInPDF()!=null);
	}
	
	
}