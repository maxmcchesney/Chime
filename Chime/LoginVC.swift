//
//  LoginVC.swift
//  Chime
//
//  Created by Max McChesney on 3/2/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit



class LoginVC: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpConstraint: NSLayoutConstraint!
    @IBOutlet weak var wordCloudImage: UIImageView!
    @IBOutlet weak var wordCloudChimeImage: UIImageView!    // not doing anything with this

    @IBOutlet weak var fbIcon: UIView!
    @IBOutlet weak var fbLetter: UILabel!
    @IBOutlet weak var fbButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set up custom facebook button
        fbIcon.layer.cornerRadius = 3
        fbButton.layer.cornerRadius = 4
        
        // change textfield placeholder color
        emailField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor(red:0.33, green:0.33, blue:0.33, alpha:0.8)])
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor(red:0.33, green:0.33, blue:0.33, alpha:0.8)])
        
        /////////
        /////////   SHIFT UI WITH KEYBOARD PRESENT
        /////////
        var keyboardHeight: CGFloat = 0
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification!) -> Void in
            if let kbSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {
                // move constraint
                keyboardHeight = kbSize.height
                self.loginBottomConstraint.constant += keyboardHeight
                self.signUpConstraint.constant += keyboardHeight
                // fade out logo image (except "Chime")
                self.wordCloudImage.alpha = 0.05
                // animate constraint
                self.view.layoutIfNeeded()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            // move constraint back
            self.loginBottomConstraint.constant -= keyboardHeight
            self.signUpConstraint.constant -= keyboardHeight
            // fade in logo image
            self.wordCloudImage.alpha = 1.0
            // animate constraint
            self.view.layoutIfNeeded()
        } // end: keyboard shift
        

    }  // end: viewDidLoad

    /////////
    /////////   LOG IN / SIGN UP
    /////////
    @IBAction func loginSignUp(sender: AnyObject) {
        // email / pw field validation
        var fieldValues: [String] = [emailField.text,passwordField.text]
        if find(fieldValues, "") != nil {
            // all fields are not filled in, present alert
            var alertViewController = UIAlertController(title: "Submission Error", message: "Please fill in all fields.", preferredStyle: UIAlertControllerStyle.Alert)
            var defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertViewController.addAction(defaultAction)
            presentViewController(alertViewController, animated: true, completion: nil)
        } else {
            // all fields are filled in, check if user exists
            var userQuery = PFUser.query()
            userQuery.whereKey("email", equalTo: emailField.text)
            
            userQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if objects.count > 0 {
                    // user exists, log in user
                    println("Log In fields good...")
                    self.login()
                } else {
                    // user not found, sign up user
                    println("Sign Up fields good...")
                    self.signUp()
                }
            })
        }
    }  // end: field validation
    
    func login() {
        // log in user
        PFUser.logInWithUsernameInBackground(emailField.text, password:passwordField.text) {
            (user: PFUser!, error: NSError!) -> Void in
            
            if user != nil {
                println("Parse: Login successful. Logged in as \(user.username).")
                // login successful, dismiss loginVC
              //  self.dismissViewControllerAnimated(true, completion: nil)
                
        
                
                if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("navigationC") as? RootNavigationController {
            //          UIApplication.sharedApplication().keyWindow?.rootViewController = vc
                    self.presentViewController(vc, animated: true, completion: nil)
               
                }

            } else {
                // login failed
                println("Parse: Login failed. Error message: \(error)")
                // present alert to user
                var alertViewController = UIAlertController(title: "Log In Error", message: "Our apologies! Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                var defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alertViewController.addAction(defaultAction)
                self.presentViewController(alertViewController, animated: true, completion: nil)
            }
        }
    }  // end: log in
    
    func signUp() {
        // sign up user
        var user = PFUser()
        user.username = emailField.text
        user.password = passwordField.text
        user.email = emailField.text    // ?? not really using this yet
        
        var location:CLLocation = CLLocation()
        
        location = GlobalVariableSharedInstance.currentLocation() as CLLocation
        
        let geoPoint = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) as PFGeoPoint
        
        
        user["location"] = geoPoint
        
        // TODO: add hometown / city to user when signing up..  though maybe just have them enter it.  could present alert asking "is Atlanta your hometown?" and then adding it if they click "yes"
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            if error == nil {
                // sign up successful, dismiss loginVC
                println("Parse: Signup successful. New account created: \(user.username)")
                self.dismissViewControllerAnimated(true, completion: nil)
                
                if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("navigationC") as? RootNavigationController {
                    //          UIApplication.sharedApplication().keyWindow?.rootViewController = vc
                    self.presentViewController(vc, animated: true, completion: nil)
                    
                }

            } else {
                // sign up failed
                let errorString = error.userInfo?["error"] as NSString
                println("Signup failed. Error message: \(errorString)")
                // present alert to user
                var alertViewController = UIAlertController(title: "Sign Up Error", message: "Our apologies! Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                var defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alertViewController.addAction(defaultAction)
                self.presentViewController(alertViewController, animated: true, completion: nil)
                
                
            }
        }
    }  // end: sign up
    
    /////////
    /////////   FACEBOOK LOG IN
    /////////
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        // log in user with Facebook
        println("User requests to log in with Facebook...")
        PFFacebookUtils.logInWithPermissions(["public_profile","email","user_friends"], {
            (user: PFUser!, error: NSError!) -> Void in
            if let user = user {
                if user.isNew {
                    println("User signed up through Facebook successfully. User: \(user)")
                    
                    // if logged in, try and link to existing Parse User
                    // ?? is this in the right place?
                    if !PFFacebookUtils.isLinkedWithUser(user) {
                        PFFacebookUtils.linkUser(user, permissions:nil, {
                            (succeeded: Bool!, error: NSError!) -> Void in
                            if (succeeded != nil) {
                                println("Woohoo, user logged in with Facebook!")
                            }
                        })
                    }
                    
                } else {
                    println("User logged in through Facebook successfully. User: \(user)")
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                println("The user cancelled the Facebook login...")
                println("Facebook error: \(error)")
            }
        })
        
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // dismiss keyboard when user touches outside textfields
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)   // ?? is this necessary
    }

} // end: viewController






