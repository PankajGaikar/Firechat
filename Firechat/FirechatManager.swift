//
//  FirechatManager.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 08/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class FirechatManager: NSObject
{
    var databaseReference: FIRDatabaseReference;
    var messagesReference: FIRDatabaseReference;
    var usersReference: FIRDatabaseReference;
    var user: FIRUser;
    var currentUser: FirechatContact = FirechatContact();
    var activeConvoWithUser: FirechatContact = FirechatContact()
    var conversationNode : FIRDatabaseReference;

    static let sharedManager = FirechatManager()

    private override init() {
        FIRDatabase.database().persistenceEnabled = true
        databaseReference = FIRDatabase.database().reference()
        databaseReference.keepSynced(true)
        user = (FIRAuth.auth()?.currentUser)!;
        messagesReference = databaseReference.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("Messages")
        usersReference = databaseReference.child("users")
        conversationNode = messagesReference
        super.init()
        fetchContactForKey(contactKey: self.user.uid) { (contact) in
            self.currentUser = contact
        }
    }
    
    //@TODO: Remove duplicate method
    func fetchUser(userKey: (String), CompletionHandler: @escaping (FirechatContact) -> ())
    {
        self.usersReference.child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            CompletionHandler(FirechatMappingModel.init().mapUserObject(user: snapshot.value as! NSDictionary))
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func fetchActiveConvoContactKeys(CompletionHandler: @escaping (NSDictionary) -> ())
    {
        self.messagesReference.observe(.value, with: { snapshot in
            if(snapshot.hasChildren())
            {
                let response = snapshot.value as! NSDictionary
                CompletionHandler(response)
            }
        })
    }
    
    func fetchContactForKey(contactKey: (String), CompletionHandler: @escaping (FirechatContact) -> () )
    {
        let ref = FIRDatabase.database().reference().child("users").child(contactKey)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.hasChildren())
            {
                let contact: FirechatContact = FirechatMappingModel.init().mapUserObject(user: snapshot.value as! NSDictionary)
                CompletionHandler(contact)
            }
        })
    }
    
    func fetchAllContacts(CompletionHandler: @escaping (NSArray) -> () )
    {
        self.usersReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let allContactsDictionary = snapshot.value as! NSDictionary
            let allContacts = NSMutableArray.init()
            let keysArray: NSArray = allContactsDictionary.allKeys as NSArray
            for index in 0 ..< keysArray.count
            {
                let contact = allContactsDictionary.object(forKey: keysArray.object(at: index)) as! NSDictionary
                allContacts.add(FirechatMappingModel.init().mapUserObject(user: contact))
            }
            CompletionHandler(allContacts as NSArray)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func checkIfConversationNodeExist(user: FirechatContact, CompletionHandler: @escaping (Bool) -> () )
    {
        self.activeConvoWithUser = user;
        let node = self.messagesReference;
        node.child(user.userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.hasChildren())
            {
                print("Item exists\(snapshot.value)")
                let response = snapshot.value as! NSDictionary
                self.conversationNode = FIRDatabase.database().reference().child("Conversations").child(response.object(forKey: "ConvoKey") as! String)
            }
            else
            {
                self.conversationNode = FIRDatabase.database().reference().child("Conversations").childByAutoId()
                node.child(user.userKey).setValue(["ConvoKey": self.conversationNode.key])
                //Add node to user profile
                FIRDatabase.database().reference().child("users").child(user.userKey).child("Messages").child(self.currentUser.userKey).updateChildValues(["ConvoKey": self.conversationNode.key])
            }
            self.startObservingActiveConvo()
            CompletionHandler(true)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func startObservingActiveConvo()
    {
        self.conversationNode.observe(.childAdded, with: { snapshot in
            if snapshot.hasChildren() {
                let message = snapshot.value as! NSDictionary
                let notificationName = Notification.Name("activeConvoObserver")
                NotificationCenter.default.post(name: notificationName, object: message)
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    func removeActiveConvoObserver()
    {
        self.conversationNode.removeAllObservers()
    }
    
    func sendNewMessage( message: (String))
    {
        let convo = self.conversationNode.childByAutoId()
        print(FIRAuth.auth()?.currentUser?.displayName)
        
        let sender = self.currentUser.userKey
        let timestamp = FIRServerValue.timestamp()
        convo.setValue(["sender": sender,
                        "Message": message,
                        "time": timestamp] )
        self.messagesReference.child(self.activeConvoWithUser.userKey).updateChildValues(["LastMessage": message])
        FIRDatabase.database().reference().child("users").child(self.activeConvoWithUser.userKey).child("Messages").child(self.currentUser.userKey).updateChildValues(["LastMessage": message])

    }
}
