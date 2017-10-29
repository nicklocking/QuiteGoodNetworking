What is it?

QuiteGoodNetworking is intended to be an abstraction layer for Alamofire. Alamofire is a great library, but it doesn't really hold the user's hand in terms of creating a truly well-architected networking layer.

Why is it?

If you're like me, you've inherited, or built, many networking layers for your mobile apps over the years. And if you're like me, you start to get a little twitch if you see a class called NetworkManager that's 2000+ lines long, containing hundreds of lines of shoddy, redundant code, with no tests, that barely works, isn't remotely reusable, and explodes if anyone looks at it funny.

I'm an object-oriented developer so I think every HTTP request should be an object. I think operation queues are a great way of dealing with http requests, so QuiteGoodNetworking uses operation queues.

I've also built many networking layers at quite a large scale (millions of MAU), and the main problems I've encountered are:
    * NetworkingManager class expands to thousands of lines, becomes unmanageable.
    * Networking is done on the main thread, crippling performance.
    * Networking is done on background threads, but JSON encoding is done on the main thread, crippling performance.
    * HTTP requests are in a queue, but JSON decoding is so slow that big responses cripple the HTTP request queue, crippling networking performance - your request to refresh the screen you're on can't complete because the request that's doing a big chunk of JSON processing and writing to disk in the background is choking the queue.
    * Authentication is an afterthought and barely works, in addition to not defining behaviours very well - if one request needs re-authentication, are the others paused while this happens? Do the authentication tokens get refreshed on the requests that are in the queue?

What's so good about it?

Key features:
    * Strongly-typed, less prone to errors.
    * Simple, easy to understand. An HTTP request is a class. You instantiate it and enqueue it.
    * Open and adaptable. If you like singletons, subclass `Networking` and make it a singleton! I'm not stopping you (I would if I could, though).
    * Performant - uses two operation queues, one for requests and one for processing responses. This solves a LOT of problems when you have to deal with large chunks of data.
    * Tested - feel free to run the test target in the sample project. It will in all likelihood pass.
    * Supports metrics - 
    
How do I use it?

Here's a complete example, including an app delegate.

    import UIKit
    import QuiteGoodNetworking
    
    // This class represents a specific HTTP request.
    class GoogleHTTPRequest: HTTPRequest {
        override var path = "http://www.google.com"
    }

    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {

        var window: UIWindow?

        let networking = Networking()

        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
            let googleHTTPRequest = GoogleHTTPRequest()
            
            googleHTTPRequest.completion = {(request in)
                print("Request complete!")
            }

            networking.enqueueRequest(googleHTTPRequest)
        
            return true
        }

    }

Good LORD that's simple. It really is quite good.

Isn't this kind of similar to...

If you're thinking this sounds like Moya (https://github.com/Moya/Moya), you're right. Moya is a great library. However, here are the problems I have with Moya and Moya's philosophy:
* When trying to implement it, I couldn't work out a good way of having a configurable base URL without using singletons (I am of the opinion that singletons are garbage).
* I wasn't keen on the enum-based approach - the information for one endpoint is divided into 3 different locations. With a class-based approach, everything you need to know about a single HTTP request is in the same 10-or-so line class.
* Moya's vision document contains "favour explicitly-defined behaviour over default implementations." - I do not agree with this. I prefer convention over configuration.
I am definitely not badmouthing Moya - it is a great library. If you prefer the enum-based approach and like explictly-defined behaviours, it's the networking abstraction library for you.

As such, QuiteGoodNetworking attempts to fix all these problems. It's the result of many years of work building many vaguely similar networking layers for large (10s of millions of users) startups, and is the culmination of all my limited wisdom on the topic.
