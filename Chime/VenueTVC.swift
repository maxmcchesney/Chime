//
//  VenueTVC.swift
//  Chime
//
//  Created by Michael McChesney on 3/2/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

class VenueTVC: UITableViewController {
    
    var venues = [[:]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
        tableView.backgroundColor = UIColor.clearColor()

    }

    
    override func viewWillAppear(animated: Bool) {
        
        // unhide the toolbar
        navigationController?.toolbarHidden = false
//        // add the images back to navbar
        for image in navImageViews {
            navigationController?.navigationBar.addSubview(image)
        }
        
        // check if user is logged in already
        checkIfLoggedIn()
        
        /////////
        /////////   PLACEHOLDER INFO
        /////////
        venues = [  // placeholder info
            
            [
                "venueName":"The Family Dog",
                "venueAddress":"1402 North Highland Avenue Northeast, Atlanta, GA 30306",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Hand In Hand",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA 30306",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs"
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Neighbors",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA 30306",
                "deals":[
                    "1 hr":"25% off a PBR"
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Park Tavern",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA 30306",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                    "4 hr":"10% off bar tab"
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Manuel's",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA 30306",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Manuel's",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA 30306",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Manuel's",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA 30306",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Manuel's",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA 30306",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Manuel's",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA 30306",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ]
        ]
        
    }
    
    /////////
    /////////   CHECK IF LOGGED IN / LOG OUT
    /////////
    func checkIfLoggedIn() {
        // check if user is already logged in
        if PFUser.currentUser() != nil {
            // user is already logged in
            println("User is already logged in, presenting venues...")
        } else {
            // no user found, present loginVC
            if let lVC = storyboard?.instantiateViewControllerWithIdentifier("loginVC") as? LoginVC {
                self.presentViewController(lVC, animated: true, completion: nil)
                println("No currentUser found, presenting log in...")
            }
        }
    }
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        // log out user
        println("User logging out...")
        PFUser.logOut()
        checkIfLoggedIn()
    }


    
    /////////
    /////////   CONFIGURE TABLEVIEW
    /////////

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("venueCell", forIndexPath: indexPath) as VenueCell

        // Configure the cell...
        
        // set up the cell coloring
        let lighterColor: UIColor = UIColor(red:0.71, green:0.87, blue:0.55, alpha:0.5)
        let middleColor: UIColor = UIColor(red:0.56, green:0.78, blue:0.35, alpha:0.5)
        let darkerColor: UIColor = UIColor(red:0.43, green:0.62, blue:0.25, alpha:0.5)
        let cellColors = [middleColor, darkerColor, lighterColor]
        cell.backgroundColor = cellColors[indexPath.row % 2]    // change to % 3 for tri-coloring
        cell.tagView.backgroundColor = cellColors[indexPath.row % 2].colorWithAlphaComponent(0.9)
        
        // set cell labels
        let venue = venues[indexPath.row]
        let venueName: String = venue["venueName"] as String
        let venueNeighborhood: String = venue["neighborhood"] as String
        if let deals: [String:String] = venue["deals"] as? [String:String] {
            cell.tagLabel.text = "$\(deals.count + 4)"  // TODO: placeholder $ amount right now
        }
        cell.venueName.text = venueName
        cell.venueNeighborhood.text = venueNeighborhood

        return cell
    }
    
    
    /////////
    /////////   PUSH DETAIL VIEW CONTROLLER WHEN CELL IS SELECTED
    /////////
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println("User has selected a venue, pushing detail view...")
        
        let dVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailVC") as DetailVC
//        dVC.navigationController?.toolbarHidden = true

        self.navigationController?.pushViewController(dVC, animated: true)
        
    }
    
    
    
    

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
