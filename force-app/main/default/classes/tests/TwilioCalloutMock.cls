/**
 * TwilioCalloutMock - Mock implementation for Twilio API callouts
 * Used in test classes to simulate HTTP responses from Twilio
 * 
 * TODO: Implement this mock class to simulate Twilio API responses for testing
 */
@IsTest
public class TwilioCalloutMock implements HttpCalloutMock {
    private Integer statusCode;
    private String responseBody;
    private Boolean throwException;
    private String exceptionMessage;
    
    /**
     * Constructor to initialize with specific status code and response body
     * @param statusCode HTTP status code to return
     * @param responseBody JSON body to return
     */
    public TwilioCalloutMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
        this.throwException = false;
        this.exceptionMessage = null;
    }
    
    /**
     * Constructor to create a mock that throws an exception
     * @param exceptionMessage The exception message to throw
     */
    public TwilioCalloutMock(String exceptionMessage) {
        this.throwException = true;
        this.exceptionMessage = exceptionMessage;
        this.statusCode = 0;
        this.responseBody = null;
    }
    
    /**
     * Creates an exception-throwing mock with default message
     * @return TwilioCalloutMock An instance that will throw an exception
     */
    public static TwilioCalloutMock createExceptionMock() {
        return new TwilioCalloutMock('Mock HTTP callout exception');
    }
    
    /**
     * Implementation of the HttpCalloutMock interface
     * @param request The HttpRequest being processed
     * @return HttpResponse A predefined response with the configured status code and body
     * @throws CalloutException If this mock is configured to throw an exception
     */
    public HttpResponse respond(HttpRequest request) {
        if (throwException) {
            throw new CalloutException(exceptionMessage);
        }
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody(responseBody);
        return response;
    }
} 