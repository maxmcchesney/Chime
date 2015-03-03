//
//  VenueTVC.swift
//  Chime
//
//  Created by Michael McChesney on 3/2/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

class VenueTVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // set up navbar
        var nav = self.navigationController?.navigationBar

        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
//        nav?.layer.bounds.width = 
        
        let width = UIScreen.mainScreen().bounds.width
        let height: CGFloat = 64.0
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, width, height - 22))
            imageView.contentMode = .Bottom
            
            let image = UIImage(named: "navBar-2x.png")
            imageView.image = image
            
            navigationItem.titleView = imageView

    }
    
    override func viewWillAppear(animated: Bool) {
        // check if user is logged in already
        checkIfLoggedIn()
    }
    
    func checkIfLoggedIn() {
        // check if user is already logged in
        if PFUser.currentUser() != nil {
            // user is already logged in
            println("App loaded: user is already logged in, presenting venues...")
        } else {
            // no user found, present loginVC
            if let lVC = storyboard?.instantiateViewControllerWithIdentifier("loginVC") as? LoginVC {
                self.presentViewController(lVC, animated: true, completion: nil)
                println("App loaded: no currentUser found, presenting log in...")
            }
        }
    }
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        // log out user
        PFUser.logOut()
        checkIfLoggedIn()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
