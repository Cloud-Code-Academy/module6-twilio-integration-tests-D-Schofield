/**
 * TwilioServiceTest - Test class for TwilioService
 * @see TwilioService
 * 
 * TODO: Implement test methods to verify the functionality of the TwilioService class
 */
@IsTest
private class TwilioServiceTest {
    
    /**
     * Helper method to setup test configuration in each test method
     */
    private static void setupConfig() {
        // Create Custom Metadata Type record for testing
        Twilio_Config__mdt testConfig = new Twilio_Config__mdt(
        	MasterLabel = 'Default',
        	Account_SID__c = 'ACmock1234567890abcdef1234567890abc',
        	Auth_Token__c = 'mock_auth_token_1234567890abcdef',
        	Default_From_Number__c = '+15551234567',
        	Base_URL__c = 'https://api.twilio.com/2010-04-01/Accounts/'
        );
        // Set the configuration for testing - must be in same transaction as test
        TwilioService.CONFIG = testConfig;
    }   
    
    /**
     * Test the sendSMS method with a valid request
     * 
     * TODO: Implement this test method to verify that sending an SMS works correctly
     */
    @IsTest
    static void testSendSMS() {
        // Setup config in same transaction as test
        setupConfig();
        
        String toNumber = '+15551234567';
        String messageBody = 'Test message from Salesforce';
        
        // Setup mock callout response
        String mockResponse = '{"sid":"SM123456789abcdef123456789abcdef12","status":"sent","body":"Test message from Salesforce","to":"+15551234567","from":"+15551234567"}';
        Test.setMock(HttpCalloutMock.class, new TwilioCalloutMock(200, mockResponse));
        
        // Execute the test
        Test.startTest();
        TwilioResponse response = TwilioService.sendSMS(toNumber, messageBody);
        Test.stopTest();
        
        // Verify results
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual(200, response.statusCode, 'Status code should be 200');
        Assert.isTrue(response.body.contains('SM123456789abcdef123456789abcdef12'), 'Response should contain Message SID');
        Assert.isTrue(response.body.contains('sent'), 'Response should contain sent status');
    }
    
    /**
     * Test the sendSMS method with an error response
     * 
     * TODO: Implement this test method to verify error handling in sendSMS
     */
    @IsTest
    static void testSendSMSError() {
        // Setup config in same transaction as test
        setupConfig();
        
        String toNumber = '+15551234567';
        String messageBody = 'Test message from Salesforce';
        
        // Setup mock callout response with error
        String errorResponse = '{"code":21211,"message":"The \'To\' number +15551234567 is not a valid phone number.","more_info":"https://www.twilio.com/docs/errors/21211","status":400}';
        Test.setMock(HttpCalloutMock.class, new TwilioCalloutMock(400, errorResponse));
        
        // Execute the test
        Test.startTest();
        TwilioResponse response = TwilioService.sendSMS(toNumber, messageBody);
        Test.stopTest();
        
        // Verify results
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.areEqual(400, response.statusCode, 'Status code should be 400');
        Assert.isTrue(response.body.contains('21211'), 'Response should contain error code');
        Assert.isTrue(response.body.contains('not a valid phone number'), 'Response should contain error message');
        
        String errorMessage = response.getErrorMessage();
        Assert.isNotNull(errorMessage, 'Error message should be extracted');
    }
    
    /**
     * Test the getMessages method
     * 
     * TODO: Implement this test method to verify the getMessages functionality
     */
    @IsTest
    static void testGetMessages() {
        // Setup config in same transaction as test
        setupConfig();
        
        // Setup mock callout response with message list
        String mockResponse = '{"messages":[{"sid":"SM123456789abcdef123456789abcdef12","status":"sent","body":"Test message 1","to":"+15551234567","from":"+15551234567"},{"sid":"SM987654321fedcba987654321fedcba98","status":"delivered","body":"Test message 2","to":"+15557654321","from":"+15551234567"}],"page":0,"page_size":20}';
        Test.setMock(HttpCalloutMock.class, new TwilioCalloutMock(200, mockResponse));
        
        // Execute the test
        Test.startTest();
        TwilioResponse response = TwilioService.getMessages(10);
        Test.stopTest();
        
        // Verify results
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual(200, response.statusCode, 'Status code should be 200');
        Assert.isTrue(response.body.contains('messages'), 'Response should contain messages array');
        Assert.isTrue(response.body.contains('SM123456789abcdef123456789abcdef12'), 'Response should contain first message SID');
        Assert.isTrue(response.body.contains('SM987654321fedcba987654321fedcba98'), 'Response should contain second message SID');
    }
    
    /**
     * Test the getMessages method with null/invalid limit
     * 
     * TODO: Implement this test method to verify handling of edge cases
     */
    @IsTest
    static void testGetMessagesWithInvalidLimit() {
        // Setup config in same transaction as test
        setupConfig();
        
        // Setup mock callout response
        String mockResponse = '{"messages":[],"page":0,"page_size":20}';
        Test.setMock(HttpCalloutMock.class, new TwilioCalloutMock(200, mockResponse));
        
        Test.startTest();
        
        // Execute the test with null limit
        TwilioResponse responseNull = TwilioService.getMessages(null);
        
        // Execute the test with negative limit
        TwilioResponse responseNegative = TwilioService.getMessages(-5);
        
        // Execute the test with zero limit
        TwilioResponse responseZero = TwilioService.getMessages(0);
        
        Test.stopTest();
        
        // Verify results - all should default to 20 and be successful
        Assert.areEqual(true, responseNull.success, 'Response with null limit should be successful');
        Assert.areEqual(200, responseNull.statusCode, 'Status code should be 200 for null limit');
        
        Assert.areEqual(true, responseNegative.success, 'Response with negative limit should be successful');
        Assert.areEqual(200, responseNegative.statusCode, 'Status code should be 200 for negative limit');
        
        Assert.areEqual(true, responseZero.success, 'Response with zero limit should be successful');
        Assert.areEqual(200, responseZero.statusCode, 'Status code should be 200 for zero limit');
    }
    
    /**
     * Test exception handling in makeHttpRequest
     * 
     * TODO: Implement this test method to verify exception handling
     */
    @IsTest
    static void testMakeHttpRequestException() {
        // Setup config in same transaction as test
        setupConfig();
        
        // Setup mock that throws exception
        Test.setMock(HttpCalloutMock.class, TwilioCalloutMock.createExceptionMock());
        
        // Execute the test
        Test.startTest();
        TwilioResponse response = TwilioService.sendSMS('+15551234567', 'Test message');
        Test.stopTest();
        
        // Verify results
        Assert.areEqual(false, response.success, 'Response should indicate failure');
        Assert.areEqual(500, response.statusCode, 'Status code should be 500 for exception');
        Assert.isTrue(response.body.contains('Mock HTTP callout exception'), 'Response should contain exception message');
        Assert.isTrue(response.body.contains('error'), 'Response body should contain error field');
    }
}