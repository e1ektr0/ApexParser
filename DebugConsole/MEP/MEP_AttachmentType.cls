public with sharing class MEP_AttachmentType
{
	//
	//Constants
	//
	public static final String WORD = 'word';
	public static final String EXCEL = 'excel';
	public static final String PDF = 'pdf';
	public static final String UNKNOWN = 'unknown';
	//
	
	public static final Map<String, String> extensionTypeMappings;
	
	static
	{ 
		extensionTypeMappings = new Map<String, String>();
		
		extensionTypeMappings.put('doc', WORD);
		extensionTypeMappings.put('docx', WORD);
		extensionTypeMappings.put('odt', WORD);
		
		extensionTypeMappings.put('xls', EXCEL);
		extensionTypeMappings.put('xlsx', EXCEL);
		extensionTypeMappings.put('ods', EXCEL);
		
		extensionTypeMappings.put('pdf', PDF);
	}
}