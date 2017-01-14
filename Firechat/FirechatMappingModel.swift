//
//  FirechatMappingModel.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 09/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import Foundation

class FirechatMappingModel: NSObject {
    func mapUserObject(user: NSDictionary) -> FirechatContact
    {
        let contact = FirechatContact.init();
        contact.emailID = user.value(forKey: FirechatEmailString) as! String
        contact.username = user.value(forKey: FirechatUserNameString) as! String
        contact.userKey = user.value(forKey: FirechatKeyString) as! String
        let convoKeys: NSDictionary = (user.value(forKey: FirechatMessagesString) != nil) ? user.value(forKey: FirechatMessagesString) as! NSDictionary : NSDictionary.init()
        contact.convoKeys = convoKeys.allValues as NSArray
        contact.userPhotoURI = user.value(forKey: FirechatUserPhotoString) as! String
        if (user.value(forKey: FirechatStatusString) != nil){
            contact.status = user.value(forKey: FirechatStatusString) as! String
        }
        return contact
    }
}
