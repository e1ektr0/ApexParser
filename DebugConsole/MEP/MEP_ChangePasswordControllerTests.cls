@isTest
private class MEP_ChangePasswordControllerTests {
   	
   	static testMethod void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        MEP_ChangePasswordController controller = new MEP_ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';   
        System.assertEquals(controller.changePassword(),null);                           
    }   
}