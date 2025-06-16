/**
 * TwilioService - Core class for Twilio SMS integration
 * Handles sending and retrieving SMS messages via Twilio API
 */
public with sharing class TwilioService {
    
    @TestVisible
    private static Twilio_Config__mdt CONFIG = Twilio_Config__mdt.getInstance('Default');

    /**
     * Send an SMS message via Twilio
     * @param toNumber - Recipient phone number (E.164 format)
     * @param messageBody - SMS message content
     * @param fromNumber - Optional sender phone number (defaults to DEFAULT_FROM_NUMBER)
     * @return TwilioResponse containing status and message details
     */
    public static TwilioResponse sendSMS(String toNumber, String messageBody) {
        
        // Prepare request parameters
        Map<String, String> params = new Map<String, String> {
            'To' => toNumber,
            'From' => CONFIG.Default_From_Number__c,
            'Body' => messageBody
        };
        
        HttpResponse response = makeHttpRequest('POST', '/Messages.json', params);
        return parseResponse(response);
    }
    
    /**
     * Retrieve SMS messages from Twilio
     * @param limit - Maximum number of messages to retrieve (default: 20)
     * @return TwilioResponse containing status and list of messages
     */
    public static TwilioResponse getMessages(Integer pageLimit) {
        if (pageLimit == null || pageLimit <= 0) {
            pageLimit = 20;
        }
        
        Map<String, String> params = new Map<String, String> {
            'PageSize' => String.valueOf(pageLimit)
        };
        
        HttpResponse response = makeHttpRequest('GET', '/Messages.json', params);
        return parseResponse(response);
    }
    
    /**
     * Common method to make HTTP requests to Twilio API
     */
    private static HttpResponse makeHttpRequest(String method, String endpoint, Map<String, String> params) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(CONFIG.Base_URL__c + endpoint);
        request.setMethod(method);
        
        // Add Basic Auth header for Twilio authentication
        String authString = CONFIG.Account_SID__c + ':' + CONFIG.Auth_Token__c;
        Blob headerValue = Blob.valueOf(authString);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        
        // Set timeout to avoid long-running callouts
        request.setTimeout(20000); // 20 seconds timeout
        
        // Add parameters to request
        if (method == 'GET') {
            String queryParams = '';
            for (String key : params.keySet()) {
                if (queryParams != '') {
                    queryParams += '&';
                }
                queryParams += key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8');
            }
            if (queryParams != '') {
                String endpoint1 = request.getEndpoint();
                request.setEndpoint(endpoint1 + '?' + queryParams);
            }
        } else {
            // For POST and PUT requests, use form URL encoded format
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String requestBody = '';
            for (String key : params.keySet()) {
                if (requestBody != '') {
                    requestBody += '&';
                }
                requestBody += key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8');
            }
            request.setBody(requestBody);
        }
        
        try {
            Logger.info('Sending request to: ' + request.getEndpoint()).addTag('Twilio');
            Logger.info('With method: ' + method).addTag('Twilio');
            if (method != 'GET') {
                Logger.info('Request body: ' + request.getBody()).addTag('Twilio');
            }
            
            HttpResponse response = http.send(request);
            Logger.info('Response status code: ' + response.getStatusCode()).addTag('Twilio');
            Logger.info('Response body: ' + response.getBody()).addTag('Twilio');
            
            return response;
        } catch (Exception e) {
            Logger.error('Error making HTTP request: ' + e.getMessage()).addTag('Twilio');
            // Handle exceptions
            HttpResponse errorResponse = new HttpResponse();
            errorResponse.setStatusCode(500);
            errorResponse.setBody('{"error": "' + e.getMessage() + '"}');
            return errorResponse;
        }
    }
    
    /**
     * Parse HTTP response from Twilio
     */
    private static TwilioResponse parseResponse(HttpResponse response) {
        TwilioResponse twilioResponse = new TwilioResponse();
        twilioResponse.statusCode = response.getStatusCode();
        twilioResponse.body = response.getBody();
        twilioResponse.success = (response.getStatusCode() >= 200 && response.getStatusCode() < 300);
        
        return twilioResponse;
    }
}