import Foundation

/*
 Abstract base class for a concurrent operation to be used in an OperationQueue. A concurrent operation is one that
 uses thread concurrency, i.e. it starts a request on one thread and then does something else on another, like an http
 request. Better described as "asynchronous", but that word already refers to something else in Operations context.
 
 The purpose of this class is to create fake KVO calls for isExecuting and isFinished, which for some reason
 Apple's Operation class doesn't properly support.
 */
open class ConcurrentOperation : Operation {
    
    override open var isConcurrent: Bool {
        return true
    }
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    fileprivate var _executing: Bool = false
    override open var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if (_executing != newValue) {
                self.willChangeValue(forKey: "isExecuting")
                _executing = newValue
                self.didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    fileprivate var _finished: Bool = false;
    override open var isFinished: Bool {
        get {
            return _finished
        }
        set {
            if (_finished != newValue) {
                self.willChangeValue(forKey: "isFinished")
                _finished = newValue
                self.didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    /*
     Calling this method at some point in the operation's lifecycle is intensely important or the operations
     will stay in the operation queue forever.
     */
    func completeOperation() {
        
        isExecuting = false
        isFinished  = true

    }
    
    override open func start() {
        
        if (isCancelled) {
            isFinished = true
            return
        }
        
        isExecuting = true
        
        main()
        
    }
    
    @available(*, deprecated: 1.0, message: "ConcurrentOperation never calls completionBlock, even though it is a property of NSOperation") override open var completionBlock: (() -> Void)? {
        set {
            assert(newValue == nil, "We won't ever use this handler")
        }
        get {
            return nil
        }
    }
}

