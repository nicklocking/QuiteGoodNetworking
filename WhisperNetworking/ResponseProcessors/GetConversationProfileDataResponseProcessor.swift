class GetConversationProfileDataResponseProcessor: CoreDataResponseProcessor {
    
    let conversationManagedObjectID: NSManagedObjectID
    
    required init(conversationManagedObjectID: NSManagedObjectID) {
        self.conversationManagedObjectID = conversationManagedObjectID
        super.init()
    }
    
    @available(*, deprecated: 1.0, message: "init not implemented; causes fatalError")
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        if
            let responseDictionary = responseDictionary(),
            let conversation = Conversation.mr_findFirst(with: NSPredicate(format: "self == %@", conversationManagedObjectID), in: localContext)
        {
            conversation.setValuesForKeysWithJSONDictionary(responseDictionary)
        }
    }
    
}
