//
//  LoginVC.swift
//  Chime
//
//  Created by Max McChesney on 3/2/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit
import AudioToolbox

class LoginVC: UIViewController, FBLoginViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpConstraint: NSLayoutConstraint!
    @IBOutlet weak var wordCloudImage: UIImageView!
    @IBOutlet weak var wordCloudChimeImage: UIImageView!    // not doing anything with this
    @IBOutlet weak var passwordLineView: UIView!
    @IBOutlet weak var emailLineView: UIView!

    @IBOutlet weak var fbIcon: UIView!
    @IBOutlet weak var fbLetter: UILabel!
    @IBOutlet weak var fbButton: UIButton!
    
    @IBOutlet weak var logoContainerView: UIView!
    
    @IBOutlet weak var businessOwnerButton: UIButton!
    
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var signUpButton: DesignableButton!
    @IBOutlet weak var loginButton: DesignableButton!
    
    var loginBottomConstraintOriginal: CGFloat!
    var signUpConstraintOriginal: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        logoContainerView.hidden = true

        loginBottomConstraintOriginal = loginBottomConstraint.constant
        signUpConstraintOriginal = signUpConstraint.constant
        
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
            self.loginBottomConstraint.constant = self.loginBottomConstraintOriginal
            self.signUpConstraint.constant = self.signUpConstraintOriginal
            // fade in logo image
            self.wordCloudImage.alpha = 1.0
            // animate constraint
            self.view.layoutIfNeeded()
        } // end: keyboard shift
        
        // set up animations
        self.emailField.hidden = true

    }  // end: viewDidLoad
    
    override func viewDidAppear(animated: Bool) {
        
        // animations
        
        // animate the text fields from the right
        var scale1 = CGAffineTransformMakeScale(0.5, 0.5)
        var translate1 = CGAffineTransformMakeTranslation(200, 0)
        self.emailField.transform = CGAffineTransformConcat(scale1, translate1)
        self.passwordField.transform = CGAffineTransformConcat(scale1, translate1)
        self.businessOwnerButton.transform = CGAffineTransformConcat(scale1, translate1)
        
        spring(1) {
            
            self.emailField.hidden = false
            self.passwordField.hidden = false
            self.businessOwnerButton.hidden = false
            var scale = CGAffineTransformMakeScale(1, 1)
            var translate = CGAffineTransformMakeTranslation(0, 0)
            self.emailField.transform = CGAffineTransformConcat(scale, translate)
            self.passwordField.transform = CGAffineTransformConcat(scale, translate)
            self.businessOwnerButton.transform = CGAffineTransformConcat(scale, translate)
        }
        
        // animate the facebook button and text field lines from the left
        var scale3 = CGAffineTransformMakeScale(0.5, 0.5)
        var translate3 = CGAffineTransformMakeTranslation(-200, 0)
        self.fbIcon.transform = CGAffineTransformConcat(scale3, translate3)
        self.fbLetter.transform = CGAffineTransformConcat(scale3, translate3)
        self.fbButton.transform = CGAffineTransformConcat(scale3, translate3)
        self.emailLineView.transform = CGAffineTransformConcat(scale3, translate3)
        self.passwordLineView.transform = CGAffineTransformConcat(scale3, translate3)
        self.orLabel.transform = CGAffineTransformConcat(scale3, translate3)
        spring(1) {
            
            self.fbIcon.hidden = false
            self.fbLetter.hidden = false
            self.fbButton.hidden = false
            self.emailLineView.hidden = false
            self.passwordLineView.hidden = false
            self.orLabel.hidden = false
            var scale = CGAffineTransformMakeScale(1, 1)
            var translate = CGAffineTransformMakeTranslation(0, 0)
            self.fbIcon.transform = CGAffineTransformConcat(scale, translate)
            self.fbLetter.transform = CGAffineTransformConcat(scale, translate)
            self.fbButton.transform = CGAffineTransformConcat(scale, translate)
            self.emailLineView.transform = CGAffineTransformConcat(scale, translate)
            self.passwordLineView.transform = CGAffineTransformConcat(scale, translate)
            self.orLabel.transform = CGAffineTransformConcat(scale, translate)
        }
        
        // animate the logo from the bottom
        var scale2 = CGAffineTransformMakeScale(0.5, 0.5)
        var translate2 = CGAffineTransformMakeTranslation(0, 400)
        self.logoContainerView.transform = CGAffineTransformConcat(scale2, translate2)
        
        animationWithDuration(2) {
            self.logoContainerView.hidden = false
            var scale = CGAffineTransformMakeScale(1, 1)
            var translate = CGAffineTransformMakeTranslation(0, 0)
            self.logoContainerView.transform = CGAffineTransformConcat(scale, translate)
        }
        
        // animate the buttons from the bottom
        var scale4 = CGAffineTransformMakeScale(0.5, 0.5)
        var translate4 = CGAffineTransformMakeTranslation(0, 50)
        self.signUpButton.transform = CGAffineTransformConcat(scale4, translate4)
        self.loginButton.transform = CGAffineTransformConcat(scale4, translate4)
        
        animationWithDuration(1) {
            self.signUpButton.hidden = false
            self.loginButton.hidden = false
            var scale = CGAffineTransformMakeScale(1, 1)
            var translate = CGAffineTransformMakeTranslation(0, 0)
            self.signUpButton.transform = CGAffineTransformConcat(scale, translate)
            self.loginButton.transform = CGAffineTransformConcat(scale, translate)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // hide stuff for animations
        logoContainerView.hidden = true
        emailField.hidden = true
        passwordField.hidden = true
        signUpButton.hidden = true
        loginButton.hidden = true
        businessOwnerButton.hidden = true
        fbIcon.hidden = true
        fbButton.hidden = true
        fbLetter.hidden = true
        emailLineView.hidden = true
        passwordLineView.hidden = true
        orLabel.hidden = true
        
    }
    

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
                makeVibrate()
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
        
        GlobalVariableSharedInstance.coreLocationManager.requestAlwaysAuthorization()

        GlobalVariableSharedInstance.coreLocationManager.delegate = self

        location = GlobalVariableSharedInstance.currentLocation() as CLLocation
        
        let geoPoint = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) as PFGeoPoint
        
        user["location"] = geoPoint
        
        // TODO: add hometown / city to user when signing up..  though maybe just have them enter it.  could present alert asking "is Atlanta your hometown?" and then adding it if they click "yes"
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError!) -> Void in
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
                let errorString = error.userInfo?["error"] as! NSString
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
        PFFacebookUtils.logInWithPermissions(["public_profile","email","user_friends"], block: {
            (user: PFUser!, error: NSError!) -> Void in
            if let user = user {
                if user.isNew {
                    println("User signed up through Facebook successfully. User: \(user)")
                    
                    // if logged in, try and link to existing Parse User
                    // ?? is this in the right place?
                    if !PFFacebookUtils.isLinkedWithUser(user) {
                        PFFacebookUtils.linkUser(user, permissions:nil, block:  {
                            (succeeded: Bool, error: NSError!) -> Void in
                            if (succeeded) {
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
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // dismiss keyboard when user touches outside textfields
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)   // ?? is this necessary
    }

} // end: viewController






