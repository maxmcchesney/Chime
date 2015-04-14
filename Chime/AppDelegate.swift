//
//  AppDelegate.swift
//  Chime
//
//  Created by Michael McChesney on 3/2/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // SET UP PARSE
//        Parse.enableLocalDatastore()
        Parse.setApplicationId("z0bdi9xmTkF8b4bbk7Gx9OrH6z7jtZkaJVxU71Yx", clientKey: "Y1H4v6hl3dN79M2VJQZFUlR4Jn2DRQZJMsqurT4o")
        PFFacebookUtils.initializeFacebook()
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        
        /////////
        /////////   NOTIFICATIONS (for timer)
        /////////
        
        // actions
        var firstAction = UIMutableUserNotificationAction()
        firstAction.identifier = "CLAIM_DEAL"
        firstAction.title = "🍻 CLAIM"
        
        firstAction.activationMode = UIUserNotificationActivationMode.Foreground
        firstAction.destructive = false
        firstAction.authenticationRequired = false

        var secondAction = UIMutableUserNotificationAction()
        secondAction.identifier = "IGNORE_DEAL"
        secondAction.title = "😢 IGNORE"
        
        secondAction.activationMode = UIUserNotificationActivationMode.Background
        secondAction.destructive = true
        secondAction.authenticationRequired = false
        
        
        // category
        let firstCategory = UIMutableUserNotificationCategory()
        firstCategory.identifier = "FIRST_CATEGORY"
        
        let defaultActions: NSArray = [firstAction, secondAction]
        let minimalActions: NSArray = [firstAction, secondAction]
        
        firstCategory.setActions(defaultActions as [AnyObject], forContext: UIUserNotificationActionContext.Default)
        firstCategory.setActions(minimalActions as [AnyObject], forContext: UIUserNotificationActionContext.Minimal)
        
        let categories = NSSet(object: firstCategory)
        
        // should I add .Sound to notification type?
        let types: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let mySettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: categories as Set<NSObject>)
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        // set badge icon to 0
        application.applicationIconBadgeNumber = 0
        
//        println("Local Notification ran! ::: \(notification)")
        // notify the rest of the app that a notification was received...
        NSNotificationCenter.defaultCenter().postNotificationName("dealActivated", object: self, userInfo: notification.userInfo)
        
    }
    
    // handle user actions from local notification
    func application(application: UIApplication,
        handleActionWithIdentifier identifier: String?,
        forLocalNotification notification: UILocalNotification,
        completionHandler: (() -> Void)) {
            
            if identifier == "CLAIM_DEAL" {
                println("User selected 'Claim Deal' from local notification.")
                // take user to active venue detailVC (use notification center)
            }
            
            completionHandler()
    }

    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject?) -> Bool {
            return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication,
                withSession:PFFacebookUtils.session())
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
        
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Facebook event logging
        FBAppEvents.activateApp()
//        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())

        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

