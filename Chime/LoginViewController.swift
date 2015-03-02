//
//  LoginViewController.swift
//  GetTurnt
//
//  Created by Max McChesney on 2/12/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var getTurntImage: UIImageView!
    @IBOutlet weak var loginSignUpButton: CustomButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameField.layer.borderWidth = 1
        self.passwordField.layer.borderWidth = 1
        
        self.usernameField.layer.masksToBounds = true
        self.passwordField.layer.masksToBounds = true
        
        checkIfLoggedIn()
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification!) -> Void in
            
            if let kbSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {
                
                self.buttonBottomConstraint.constant = 20 + kbSize.height
                
                self.getTurntImage.alpha = 0.15     // fade out the logo image when keyboard rises
                
                self.usernameField.layer.borderColor = UIColor.grayColor().CGColor
                self.passwordField.layer.borderColor = UIColor.grayColor().CGColor
                
                self.loginSignUpButton.backgroundColor = UIColor.whiteColor()
                self.loginSignUpButton.titleLabel?.textColor = UIColor.grayColor()
                self.loginSignUpButton.layer.borderColor = UIColor.grayColor().CGColor
                
//                self.blurView(UIBlurEffectStyle.Dark)
                
                // used to animate constraint
                self.view.layoutIfNeeded()
                
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            
            self.buttonBottomConstraint.constant = 20
            
            self.loginSignUpButton.titleLabel?.textColor = UIColor.whiteColor()
            self.loginSignUpButton.backgroundColor = UIColor.clearColor()
            self.loginSignUpButton.layer.borderColor = UIColor.whiteColor().CGColor

            self.usernameField.layer.borderColor = UIColor.whiteColor().CGColor
            self.passwordField.layer.borderColor = UIColor.whiteColor().CGColor
            
            self.getTurntImage.alpha = 1.0
            
            // used to animate constraint
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    @IBAction func loginSignUp(sender: AnyObject) {
        
        var fieldValues: [String] = [usernameField.text,passwordField.text]
        
        if find(fieldValues, "") != nil {
            
            // all fields are not filled in
            var alertViewController = UIAlertController(title: "Submission Error", message: "Please fill in all fields.", preferredStyle: UIAlertControllerStyle.Alert)
            
            var defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            
            alertViewController.addAction(defaultAction)
            
            presentViewController(alertViewController, animated: true, completion: nil)
            
        } else {
            
            // all fields are filled in
            
            var userQuery = PFUser.query()
            
            userQuery.whereKey("username", equalTo: usernameField.text)
            
            userQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if objects.count > 0 {
                    
                    println("Login fields good, logging in...")
                    self.login()
                    
                } else {
                    
                    println("Signup fields good, creating new user...")
                    self.signUp()
                    
                }
                
            })
            
        }
    
    }
    
    func login() {
        
        PFUser.logInWithUsernameInBackground(usernameField.text, password:passwordField.text) {
            (user: PFUser!, error: NSError!) -> Void in
            
            if user != nil {
                
                println("Login successful. Logged in as \(user).")
                // Do stuff after successful login.
                
                TurntData.mainData().isLoggedIn = true
                self.checkIfLoggedIn()
                
            } else {
                // The login failed. Check error to see why.
                println("Login failed. Error message: \(error)")
            }
            
        }
        
    }
    
    func signUp() {
        
        var user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
//        user.email = emailField.text
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            
            if error == nil {
                
                println("Signup successful. New account created: \(user)")
                
                TurntData.mainData().isLoggedIn = true
                self.checkIfLoggedIn()
                
                self.usernameField.text = ""
                self.passwordField.text = ""
//                self.emailField.text = ""
                
                // Hooray! Let them use the app now.
                
            } else {
                
                let errorString = error.userInfo?["error"] as NSString
                // Show the errorString somewhere and let the user try again.
                println("Signup failed. Error message: \(errorString)")
                
            }
            
        }
        
    }
    
    func checkIfLoggedIn() {
                
        if TurntData.mainData().isLoggedIn {
            
            var nbc = storyboard?.instantiateViewControllerWithIdentifier("navBarController") as? UINavigationController
            
            UIApplication.sharedApplication().keyWindow?.rootViewController = nbc
            
        }
        
    }

} // END








