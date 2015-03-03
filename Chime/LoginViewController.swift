//
//  LoginViewController.swift
//  Chime
//
//  Created by Max McChesney on 3/2/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpConstraint: NSLayoutConstraint!
    @IBOutlet weak var wordCloudImage: UIImageView!
    @IBOutlet weak var wordCloudChimeImage: UIImageView!    // not doing anything with this
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                self.wordCloudImage.alpha = 0.1
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
        }
        // end: keyboard shift
        
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
                // login successful
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
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            
            if error == nil {
                // sign up successful
                println("Parse: Signup successful. New account created: \(user.username)")
                
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

} // end: viewController








