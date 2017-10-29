import Foundation
import Alamofire

/*
This class exists to hold all the persistent application state like downloaders, networking queues, etc.
*/
@objc class System: NSObject {
 
    static let gotUserNotification = "gotUserNotification"
    
    // MARK: Setup
    
    var crashAndMemoryIssueDetector: CrashAndMemoryIssueDetector
    var shouldShowPushPromptForNextLaunch: Bool
    var promptingForLocationPermission: Bool
    var didOpenFromPushNotification = false
    var programmaticAds: ProgrammaticAds?
    let analytics = Analytics()
    var launch: Launch
    var inputLanguage = WDevice.inputLanguage()
    var actionOwner = ActionOwner()
    
    /*
     We require the crash and memory issue detector to be passed in so Fabric gets set up before CoreData,
     so we catch any CoreData setup crashes.
     */
    @objc required init(crashAndMemoryIssueDetector: CrashAndMemoryIssueDetector, launchOptions: [NSObject: AnyObject]) {

        self.crashAndMemoryIssueDetector = crashAndMemoryIssueDetector
        self.shouldShowPushPromptForNextLaunch = true
        self.promptingForLocationPermission = false
        self.launch = Launch(launchOptions: launchOptions as [NSObject : AnyObject])

        super.init()
        
        // This throws an error if any UIKit stuff is accessed from background threads in
        // debug mode, which is forbidden.
        #if DEBUG
            UIView.toggleMainThreadChecking()
        #endif
     
        reachabilityManager?.listener = { _ in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: System.reachabilityStatusChangedNotification), object: nil)
        }
        reachabilityManager?.startListening()
        
        NotificationCenter.default.addObserver(self, selector: #selector(System.applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        handleApplicationDidBecomeActive()
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {

        handleApplicationDidBecomeActive()

    }
    
    func handleApplicationDidBecomeActive() {
        
        WRemote.shared().handleApplicationDidBecomeActive()
        fetchInfoNeededForAppDidBecomeActive()
        
    }

    var user: WUser? {
        didSet {
            gotUser()
        }
    }
    
    func gotUser() {
        
        if let uid = user?.uid {
            WSettingsManager.setUid(uid)
        }
        NotificationCenter.default.post(name: Notification.Name(System.gotUserNotification), object: nil)
        
        if let fetchDiscoverCategoriesEndpointRequest = FetchDiscoverCategoriesEndpointRequest(junkParameter: true) {
            system().endpointRequestOperationQueue.addOperation(fetchDiscoverCategoriesEndpointRequest)
        }
        
        system().endpointRequestOperationQueue.addOperation(FetchDiscoverFeaturedFeedsEndpointRequest())
        system().endpointRequestOperationQueue.addOperation(FetchImageCampaign())
        
        var isReinstall = true
        if let localUser = user {
            isReinstall = localUser.isReinstall
        }
        
        system().endpointRequestOperationQueue.addOperation(UpdateUserEndpointRequest(scrollID: nil, onlyFirstPage: true, updateLanguage: false, isReinstall:isReinstall))
        
        if programmaticAds == nil {
            programmaticAds = ProgrammaticAds()
        }
        
        if whisperUploader == nil {
            whisperUploader = WhisperUploader()
        }
        
        if heartbeat == nil {
            heartbeat = Heartbeat()
        }
        
    }
    
    func fetchInfoNeededForAppDidBecomeActive() {
        guard let user = user, let userAccount = user.userAccount, let _ = userAccount.sessionToken else {
            return
        }
        
        if promptingForLocationPermission || shouldShowPushPromptForNextLaunch {
            shouldShowPushPromptForNextLaunch = false;
            promptingForLocationPermission = false;
            WAppDelegate.shared().registerForRemoteNotifications();
        }
        
        endpointRequestOperationQueue.addOperation(FetchUserSettingsEndpointRequest())
        endpointRequestOperationQueue.addOperation(FetchUserFeedsEndpointRequest())
        endpointRequestOperationQueue.addOperation(FetchImageCampaign())
    }
    
    func cancelAllRequestsAndOperations() {
        endpointRequestOperationQueue.cancelAllOperations()
        conversationResponseProcessingOperationQueue.cancelAllOperations()
        responseProcessingOperationQueue.cancelAllOperations()
    }
    
    // MARK: Networking
    
    static let reachabilityStatusChangedNotification = "reachability_status_changed"
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "whisper.sh")
    // AlamoFire's reachability has no objective-c availability.
    var isInternetReachable:Bool {
        get {
            return reachabilityManager?.isReachable ?? false
        }
    }
    
    let responseProcessingOperationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    
    let conversationResponseProcessingOperationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()

    var whisperUploader: WhisperUploader?
    
    var heartbeat: Heartbeat?

    let imageCache = ImageCache()
    
    let endpointRequestOperationQueue = OperationQueue()
    
    let alamofireSessionManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30

        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    // MARK: CoreData
    
    var mostRecentlyViewedFeedID: String? {
        didSet {
            guard let feedID = mostRecentlyViewedFeedID else {
                return
            }
            MagicalRecord.save({ (context) in
                if let feed = TribeFeed.mr_findFirst(byAttribute: TribeFeed.idKey, withValue: feedID, in: context) {
                    feed.lastReadTimestamp = Date()
                }
            })
        }
    }
    
    let coreData = CoreData()
    
    // MARK: Metrics
    
    let feedItemViewTracking = FeedItemViewTracking()
    
    let appForegroundTracker = AppForegroundTracker()
    
    // MARK: AVPlayer
    
    var playerViewController = PlayerViewController()
}
