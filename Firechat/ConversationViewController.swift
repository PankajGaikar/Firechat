//
//  ConversationViewController.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 04/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ConversationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var otherUser: NSDictionary = [:];
    var currentUser: NSDictionary = [:];
    var conversationNode = FIRDatabase.database().reference()
    var convoList = NSMutableArray.init()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTxt: UITextField!
    
    
    
    //Add one more child with key of other user
    // Check if node exist for email ID in messages
    // If not, create new node under conversations
    // Add it's key under messages/email id for both users

    

    override func viewDidLoad() {
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 50.0; // set to whatever your "average" cell height is
        
        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            self.currentUser = (snapshot.value as? NSDictionary)!
        }) { (error) in
            print(error.localizedDescription)
        }
        
        let child = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("Messages").child(self.otherUser.object(forKey:"key") as! String)
        
        child.observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.hasChildren())
            {
                print("Item exists\(snapshot.value)")
                
                let response = snapshot.value as! NSDictionary
                
                
                //Add conversation/key path to conversation
                self.conversationNode = FIRDatabase.database().reference().child("Conversations").child(response.object(forKey: "ConvoKey") as! String)
                self.fetch()
            }
            else
            {
                self.conversationNode = FIRDatabase.database().reference().child("Conversations").childByAutoId()
//                self.conversationNode.setValue("ChatHead")
                child.setValue(["ConvoKey": self.conversationNode.key])
                //Add node to user profile
                
                FIRDatabase.database().reference().child("users").child(self.otherUser.object(forKey:"key") as! String).child("Messages").updateChildValues(["ConvoKey": self.conversationNode.key])
                self.fetch()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func fetch()
    {
        self.conversationNode.observe(.childAdded, with: { snapshot in
            
            if snapshot.value is NSNull {

            } else {
                
                let x = snapshot.value as! NSDictionary
                
                self.convoList.insert(x, at: self.convoList.count)
                self.tableView.reloadData()
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func sendMessageAction(_ sender: AnyObject) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.convoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageBundle = self.convoList.object(at: indexPath.row) as! NSDictionary
        
        let sender = messageBundle.object(forKey: "sender") as! String
        if sender == (self.currentUser.object(forKey: "key") as! String)
        {
            let cell: MessageFromMeCell = tableView.dequeueReusableCell(withIdentifier: "Me", for: indexPath) as! MessageFromMeCell
            cell.message.text = messageBundle.object(forKey: "Message") as? String
            return cell
        }
        else
        {
            let cell: MessageFromYouCell = tableView.dequeueReusableCell(withIdentifier: "You", for: indexPath) as! MessageFromYouCell
            cell.message.text = messageBundle.object(forKey: "Message") as? String
            return cell
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let x = textField.text
        
        if (x?.characters.count) != nil {
            let convo = self.conversationNode.childByAutoId()
            print(FIRAuth.auth()?.currentUser?.displayName)
            
            let sender = self.currentUser.object(forKey: "key") as! String
            let message:String = x!
            let timestamp = FIRServerValue.timestamp()
            
            convo.setValue(["sender": sender,
                            "Message": message,
                            "time": timestamp] )
            
            textField.text = ""
        }
        return true
    }
    
}
