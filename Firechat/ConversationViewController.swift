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
    
    var otherUser: FirechatContact = FirechatContact();
    var currentUser: FirechatContact = FirechatContact();
    var conversationNode = FIRDatabase.database().reference()
    var convoList = NSMutableArray.init()

    @IBOutlet weak var otherUserButton: UIButton!
    @IBOutlet weak var rightNavbarImage: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTxt: UITextField!
    
    override func viewDidLoad() {
        self.title = self.otherUser.username
        self.otherUserButton.setBackgroundImage(UIImage.init(named: "user_placeholder.png"), for: .normal)
        self.currentUser = FirechatManager.sharedManager.currentUser
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 50.0;
        
        let child = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("Messages").child(self.otherUser.userKey)
        
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
                
                FIRDatabase.database().reference().child("users").child(self.otherUser.userKey).child("Messages").updateChildValues(["ConvoKey": self.conversationNode.key])
                self.fetch()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func fetch()
    {
        self.conversationNode.observe(.childAdded, with: { snapshot in
            
            if snapshot.hasChildren() {
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
        if sender == (self.currentUser.userKey)
        {
            let cell: MessageFromMeCell = tableView.dequeueReusableCell(withIdentifier: "Me", for: indexPath) as! MessageFromMeCell
            cell.message.text = messageBundle.object(forKey: "Message") as? String
            cell.profileImage.imageFromServerURL(urlString: self.currentUser.userPhotoURI)
            return cell
        }
        else
        {
            let cell: MessageFromYouCell = tableView.dequeueReusableCell(withIdentifier: "You", for: indexPath) as! MessageFromYouCell
            cell.message.text = messageBundle.object(forKey: "Message") as? String
            cell.profileImage.imageFromServerURL(urlString: self.otherUser.userPhotoURI)
            return cell
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let x = textField.text
        
        if (x?.characters.count) != nil {
            let convo = self.conversationNode.childByAutoId()
            print(FIRAuth.auth()?.currentUser?.displayName)
            
            let sender = self.currentUser.userKey
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
