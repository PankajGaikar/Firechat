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
    var user: FIRUser;
    
    static let sharedManager = FirechatManager()

    private override init() {
        FIRDatabase.database().persistenceEnabled = true
        self.databaseReference = FIRDatabase.database().reference()
        self.user = (FIRAuth.auth()?.currentUser)!;
        self.messagesReference = self.databaseReference.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("Messages")
        
       super.init()
    }

    func fetchActiveConvoContactKeys(CompletionHandler: @escaping (NSArray) -> ())
    {
        self.messagesReference.observe(.value, with: { snapshot in
            if(snapshot.hasChildren())
            {
                let response = snapshot.value as! NSDictionary
                CompletionHandler(response.allKeys as NSArray)
            }
        })
    }
    
    func fetchContactForKey(contactKey: (String), CompletionHandler: @escaping (NSDictionary) -> () )
    {
        let ref = FIRDatabase.database().reference().child("users").child(contactKey)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            CompletionHandler(snapshot.value as! NSDictionary)
        })
    }
}
