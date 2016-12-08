//
//  ShowAllProfilesViewController.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 03/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import UIKit
import FirebaseDatabase



class ShowAllProfilesViewController: UITableViewController
{
    var usersInfo: NSDictionary = [:];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRDatabase.database().reference().keepSynced(true)
        
        FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            self.usersInfo = (snapshot.value as? NSDictionary)!
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersInfo.allKeys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactDetailCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactDetailCell
        
        let indexKey: NSArray = self.usersInfo.allKeys as NSArray;
        let dictionary: NSDictionary = self.usersInfo.object(forKey: indexKey.object(at: indexPath.row)) as! NSDictionary
        
        cell.contactName.text = dictionary.object(forKey: "username") as! String?
        cell.statusLabel?.text = dictionary.object(forKey: "email") as! String?
        cell.profileImage?.imageFromServerURL(urlString: dictionary.object(forKey: "userPhoto") as! String)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexKey: NSArray = self.usersInfo.allKeys as NSArray;
        self.performSegue(withIdentifier: "StartNewConversation", sender: self.usersInfo.object(forKey: indexKey.object(at: indexPath.row)))
        
        self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count)! - 2)
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ConversationsViewController
        destinationVC.otherUser = sender as! NSDictionary
    }
}
