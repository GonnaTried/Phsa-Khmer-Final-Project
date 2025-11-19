package com.phaskhmer.st25.spring_boot.controller.payment;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import java.net.URI;

@RestController
public class RedirectController {

    // Define your App's Custom URI Scheme for Deep Linking
    // This must match what you configure in your Flutter/Native project setup
    private static final String APP_SCHEME = "phsakhmer://";
    private static final String REDIRECT_PATH = "checkout/status";
    private static final String WEB_BASE_URL = "http://localhost:5000";

    /**
     * Handles the success return from Stripe Checkout and redirects to the Flutter app.
     * @param sessionId The Stripe session ID passed back by Stripe.
     */
    @GetMapping("/payment-return")
    public ResponseEntity<Void> handleRedirect(
            @RequestParam("session_id") String sessionId,
            // Add a client parameter to detect if it came from a web browser (see previous advice)
            @RequestParam(value = "client", defaultValue = "mobile") String clientType) {

        String redirectUrl;

        // Check if the request should return to the web app
        // NOTE: In a real environment, you might use request headers (User-Agent)
        // or a client parameter passed during Stripe session creation.
        if (clientType.equalsIgnoreCase("web")) {
            // For Flutter Web, redirect to the URL path (using the #/ hash fragment if using path routing)
            redirectUrl = WEB_BASE_URL + "/#/" + REDIRECT_PATH + "?session_id=" + sessionId;
        } else {
            // Mobile (Deep Link)
            redirectUrl = APP_SCHEME + REDIRECT_PATH + "?session_id=" + sessionId;
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setLocation(URI.create(redirectUrl));
        return new ResponseEntity<>(headers, HttpStatus.SEE_OTHER);
    }

    @GetMapping("/payment-cancel")
    public ResponseEntity<Void> handleCancel() {
        // 1. Construct the Deep Link URL for cancellation
        // Example: myapp://payment/cancel
//        String deepLinkUrl = APP_SCHEME + CANCEL_PATH;

        // 2. Prepare the HTTP Headers for Redirection
        HttpHeaders headers = new HttpHeaders();
//        headers.setLocation(URI.create(deepLinkUrl));

        // 3. Return the Redirect Response
        return new ResponseEntity<>(headers, HttpStatus.SEE_OTHER);
    }
}