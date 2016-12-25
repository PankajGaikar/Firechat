//
//  FirechatLoadingViewController.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 25/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import Foundation
import UIKit
import Firebase
extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }}

extension UIButton {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.setBackgroundImage(image, for: .normal)
            })
            
        }).resume()
    }}

class FirechatLoadingViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 255.0/255.0, green: 204.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.title = "Firechat"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let viewController: UIViewController;
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if ( FIRAuth.auth()?.currentUser != nil)
        {
            viewController = storyboard.instantiateViewController(withIdentifier: "ActiveConversationsViewController") as! ActiveConversationsViewController
        }
        else
        {
            viewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
