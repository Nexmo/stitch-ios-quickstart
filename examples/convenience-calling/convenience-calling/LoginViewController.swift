//
//  LoginViewController.swift
//  convenience-calling
//
//  Created by Eric Giannini on 5/25/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import UIKit
import Stitch

class LoginViewController: UIViewController {
    
    /// Nexmo Conversation client
    let client: ConversationClient = {
        return ConversationClient.instance
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // status label
    @IBOutlet weak var statusLbl: UILabel!
    
    // login button
    @IBAction func loginBtn(_ sender: Any) {
        
        print("DEMO - login button pressed.")
        
        let token = Authenticate.userJWT
        
        print("DEMO - login called on client.")
        
        client.login(with: token).subscribe(onSuccess: {
            
            print("DEMO - login susbscribing with token.")
            self.statusLbl.isEnabled = true
            self.statusLbl.text = "Logged in"
            
            if let user = self.client.account.user {
                print("DEMO - login successful and here is our \(user)")
            } // insert activity indicator to track subscription
            
        }, onError: { [weak self] error in
            self?.statusLbl.isHidden = false
            
            print(error.localizedDescription)
            
            // remove to a function
            let reason: String = {
                switch error {
                case LoginResult.failed: return "failed"
                case LoginResult.invalidToken: return "invalid token"
                case LoginResult.sessionInvalid: return "session invalid"
                case LoginResult.expiredToken: return "expired token"
                case LoginResult.success: return "success"
                default: return "unknown"
                }
            }()
            
            print("DEMO - login unsuccessful with \(reason)")
            
        })
    }
    
    // chat button
    @IBAction func chatBtn(_ sender: Any) {
        
        let aConversation: String = "aConversation"
        _ = client.conversation.new(aConversation, withJoin: true).subscribe(onError: { error in
            
            print(error)
            
            guard self.client.account.user != nil else {
                
                let alert = UIAlertController(title: "LOGIN", message: "The `.user` property on self.client.account is nil", preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alert.addAction(alertAction)
                
                self.present(alert, animated: true, completion: nil)
                
                return print("DEMO - chat self.client.account.user is nil");
                
            }
            
            print("DEMO - chat creation unsuccessful with \(error.localizedDescription)")
            
        })
        
        DispatchQueue.main.async {
        performSegue(withIdentifier: "chatView", sender: nil)
        }
    }
    
    // prepare(for segue:)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // setting up a segue
        let chatVC = segue.destination as? ChatController
        
        // passing a reference to the conversation
        chatVC?.conversation = client.conversation.conversations.first
        
    }
    
    

}


// a stub for holding the value for private.key
struct Authenticate {
    
    static let userJWT = ""
    
    static let anotherUserJWT = ""
    
}


