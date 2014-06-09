/*
*	Author: SLegostaev
*	Class using when user to logging to application and get error of auth 
*/
public with sharing class MEP_AuthException extends Exception {
	
	@isTest
	private static void testMepException() {
		String exceptionMessage = 'test exception';
		try {
			throw new MEP_AuthException(exceptionMessage);
			System.assert(false);
		} catch (MEP_AuthException e) {
			System.assertEquals(exceptionMessage, e.getMessage());
			System.assert(true);
		}
	}
}