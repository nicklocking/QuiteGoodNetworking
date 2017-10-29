import Foundation

enum AuthenticationFailureBehaviour {
    case reauthenticate
    case exponentialBackoff
    case retryImmediately
    
}

public protocol AuthenticatedHTTPRequest: class {}

public protocol AuthenticatorDelegate: class {
    
    func pauseHTTPRequests()
    func resumeHTTPRequests()
    
}

/*
 An Authenticator is a class that is responsible for authenticating
 network requests. This class should be subclassed and the key functionality overridden.
 
 */
open class Authenticator {

    weak var delegate: AuthenticatorDelegate?
    
    public init() {
        
    }
    
    /*
     Override this method and make any changes to the HTTP request necessary for it to authenticate,
     i.e. add headers, a query string parameter, etc.
     */
    open func authenticateHTTPRequest(_ authenticatableHTTPRequest: AuthenticatedHTTPRequest) {
        
        guard let _ = authenticatableHTTPRequest as? HTTPRequest else {
            fatalError("Must provide an instance of HTTPRequest.")
        }
        
        // Example:
        // authenticatableHTTPRequest.headers = ["auth-token": "ln34luowkjdn3aui3hda3"]
        
    }
 
    /*
     Override this method to indicate whether an HTTP request was rejected. You might want to check for
     status codes such as 401, 403. It's also possible that HTTP requests might return 200 and show JSON
     indicating reauthentication is necessary.
     */
    open func shouldReauthenticate(_ authenticatableHTTPRequest: AuthenticatedHTTPRequest) -> Bool {
        
        guard let _ = authenticatableHTTPRequest as? HTTPRequest else {
            fatalError("Must provide an instance of HTTPRequest.")
        }
        
        // Example:
        // if [HTTPStatusCode.unauthorized, HTTPStatusCode.forbidden].contains(httpRequest.responseStatusCode) {
        //   delegate?.pauseHTTPRequests()
        //   return true
        // }

        return false
    }
    
    /*
     Override this method to do the work of reauthentication. Although this class does not contain an
     operation queue, HTTP request operation subclasses would work perfectly well to perform any
     reauthentication necessary.
     */
    open func authenticate() {
        
        delegate?.resumeHTTPRequests()
    }
    
}
