class ChangeNicknameEndpointRequest: EndpointRequest {
    
    var nickname: String
    
    required init(nickname: String) {
        self.nickname = nickname
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/user/update_nickname"
        
        httpMethod = .post
        
        defaultFailureMessage = NSLocalizedString("Sorry, we're having some trouble changing your nickname. Try again soon!", comment: "")
        
        failureHTTPCodeToMessage = [
            400: NSLocalizedString("The nickname you entered violates our terms of service. Please choose another one.", comment: ""),
        ]

    }
    
    override func parameters() -> NetworkDictionary {
        return super.parameters() + ["nickname":nickname]
    }
    
}
