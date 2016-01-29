private let _singleton = PrivateBrowsing()

class PrivateBrowsing {
    class var singleton: PrivateBrowsing {
        return _singleton
    }

    var isOn = false

    var nonprivateCookies = [NSHTTPCookie: Bool]()

    func enter() {
        isOn = true

        NSURLCache.sharedURLCache().memoryCapacity = 0;
        NSURLCache.sharedURLCache().diskCapacity = 0;

        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                nonprivateCookies[cookie] = true
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cookiesChanged:", name: NSHTTPCookieManagerCookiesChangedNotification, object: nil)
    }

    func exit() {
        if !isOn {
            return
        }

        isOn = false

        BraveApp.setupCacheDefaults()
        NSNotificationCenter.defaultCenter().removeObserver(self)

        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                if nonprivateCookies[cookie] == nil {
                   storage.deleteCookie(cookie)
                }
            }
        }

        NSUserDefaults.standardUserDefaults().synchronize()
        nonprivateCookies = [NSHTTPCookie: Bool]()
    }

    @objc func cookiesChanged(info: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        var newCookies = [NSHTTPCookie]()
        if let cookies = storage.cookies {
            for cookie in cookies {
                if let readOnlyProps = cookie.properties {
                    var props = readOnlyProps as [String: AnyObject]
                    let discard = props[NSHTTPCookieDiscard] as? String
                    if discard == nil || discard! != "TRUE" {
                        props.removeValueForKey(NSHTTPCookieExpires)
                        props[NSHTTPCookieDiscard] = "TRUE"
                        storage.deleteCookie(cookie)
                        if let newCookie = NSHTTPCookie(properties: props) {
                            newCookies.append(newCookie)
                        }
                    }
                }
            }
        }
        for c in newCookies {
            storage.setCookie(c)
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cookiesChanged:", name: NSHTTPCookieManagerCookiesChangedNotification, object: nil)
    }
}
