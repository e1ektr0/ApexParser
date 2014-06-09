public with sharing class MEP_AttachmentUtils
{
	//
	//Public static methods
	//
	public static String formatFileSize(Integer sizeInBytes)
	{
		String[] units = new String[] {'B', 'KB', 'MB', 'GB'};
		
		Double convertedSize = sizeInBytes;
		Integer unitIndex;
		for (unitIndex = 0; unitIndex < units.size(); unitIndex++)
		{
			if (convertedSize > 1024)
			{
				convertedSize /= 1024.0;
			}
			else
			{
				break;
			}
		}
		
		//round double to the number with 2 digits in a fractional part.
		//I add 0 to avoid the problem when convertedSize = 0,
		//in this case 0/100.0 gives '0E+1' instead of '0'
		return (Math.round(100 * convertedSize) / 100.0 + 0) + ' ' + units[unitIndex];
	}
	
	public static String getFileType(String fullFileName)
	{
		if (MEP_StringUtils.isNullOrEmpty(fullFileName))
		{
			return MEP_AttachmentType.UNKNOWN;
		}
		
		//extract extension from the file name
		String extension = null;
		Integer indexOfLastPoint = fullFileName.lastIndexOf('.');
		if (indexOfLastPoint != -1)
		{
			extension = fullFileName.substring(indexOfLastPoint + 1).toLowerCase();
		}
		
		//get file type by extension
		String fileType = MEP_AttachmentType.extensionTypeMappings.get(extension);
		if (MEP_StringUtils.isNullOrEmpty(fileType))
		{
			fileType = MEP_AttachmentType.UNKNOWN;
		}
		
		return fileType; 
	}
	//
	
	
	
	//
	//Tests
	//
	@IsTest
	private static void test_getFileSize()
	{
		System.assertEquals('2 KB', formatFileSize(2048));
		System.assertEquals('64 KB', formatFileSize(65536));
		System.assertEquals('2 MB', formatFileSize(2097152));
	}
	
	@IsTest
	private static void test_getFileType()
	{
		//WRONG DATA
		System.assertEquals(MEP_AttachmentType.UNKNOWN, getFileType(null));
		
		//GOOD DATA
		System.assertEquals(MEP_AttachmentType.WORD, getFileType('test.doc'));
		System.assertEquals(MEP_AttachmentType.EXCEL, getFileType('test.xls'));
		System.assertEquals(MEP_AttachmentType.PDF, getFileType('test.pdf'));
		System.assertEquals(MEP_AttachmentType.UNKNOWN, getFileType('test.avi'));
	}
	
}