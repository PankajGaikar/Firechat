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
    var usersInfo: NSArray = NSArray();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirechatManager.sharedManager.fetchAllContacts { (array) in
            self.usersInfo = array
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersInfo.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactDetailCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactDetailCell
        
        let contact = self.usersInfo.object(at: indexPath.row) as! FirechatContact
        
        cell.contactName.text = contact.username
        cell.statusLabel?.text = contact.emailID
        cell.profileImage?.imageFromServerURL(urlString: contact.userPhotoURI)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "StartNewConversation", sender: self.usersInfo.object(at: indexPath.row))
        self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count)! - 2)
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ConversationsViewController
        destinationVC.otherUser = sender as! FirechatContact
    }
}
