//
//  LoginController.swift
//  QuickStartTwo
//


import UIKit
import NexmoConversation

class LoginViewController: UIViewController {
    
    /// instance of Nexmo Conversation client
    let client: ConversationClient = {
        
        ConversationClient.configuration = Configuration(with: .info)
        
        return ConversationClient.instance
    }()
    
    // status label
    @IBOutlet weak var statusLbl: UILabel!
    
    // login button
    @IBAction func loginBtn(_ sender: Any) {
        
        print("DEMO - login button pressed.")
        
        let alert = UIAlertController(title: "My Alert", message: "This is an alert.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("jamie", comment: "First User"), style: .`default`, handler: { _ in
            NSLog("The \"First User\" is here!")
            
            let token = Authenticate.userJWT
            
            print("DEMO - login called on client.")
            
            self.client.login(with: token).subscribe(onSuccess: {
                
                if let user = self.client.account.user {
                    print("DEMO - login successful and here is our \(user)")
                    
                    // whenever the conversations array is modified
                    self.client.conversation.conversations.asObservable.subscribe(onNext: { (change) in
                        switch change {
                        case .inserted(let conversation, let reason):
                            switch reason {
                            case .invitedBy:
                                _ = conversation.join().subscribe(onSuccess: { _ in
                                    print("You have joined this conversation: \(conversation.uuid)")
                                }, onError: { (error) in
                                    print(error.localizedDescription)
                                })
                            default:
                                break
                            }
                        default:
                            break
                        }
                    }).disposed(by: self.client.disposeBag)
                    
                    // figure out which conversation a member has joined
                    let joinedConversation = self.client.conversation.conversations.filter({ (conversation) -> Bool in
                        conversation.members.contains(where: { (member) -> Bool in
                            return member.user.isMe && member.state == .joined
                        })
                    })
                    
                    for conversation in joinedConversation {
                        print("DEMO - looping through members' conversations")
                        return print(String(describing: conversation.uuid))
                    }
                    
                } // insert activity indicator to track subscription
                
                print("DEMO - login susbscribing with token.")
                
                
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
                
            }).disposed(by: self.client.disposeBag) // Rx does not maintain a memory reference; to make sure that reference is still in place; keep a reference of this object while I do an operation.
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("alice", comment: "Second User"), style: .default, handler: { (_) in
            NSLog("The \"Second User\" is here!")
            
            let token = Authenticate.anotherUserJWT
            
            print("DEMO - login called on client.")
            
            self.client.login(with: token).subscribe(onSuccess: {
                
                if let user = self.client.account.user {
                    print("DEMO - login successful and here is our \(user)")
                    
                    // whenver the conversations array is modified
                    self.client.conversation.conversations.asObservable.subscribe(onNext: { (change) in
                        switch change {
                        case .inserted(let conversation, let reason):
                            switch reason {
                            case .invitedBy:
                                _ = conversation.join().subscribe(onSuccess: { _ in
                                    print("You have joined this conversation: \(conversation.uuid)")
                                }, onError: { (error) in
                                    print(error.localizedDescription)
                                })
                            default:
                                break
                            }
                        default:
                            break
                        }
                    }).disposed(by: self.client.disposeBag)
                    
                    // figure out which conversation a member has joined
                    let joinedConversation = self.client.conversation.conversations.filter({ (conversation) -> Bool in
                        conversation.members.contains(where: { (member) -> Bool in
                            return member.user.isMe && member.state == .joined
                        })
                    })
                    
                    for conversation in joinedConversation {
                        return print(String(describing: conversation.uuid))
                    }
                    
                } // insert activity indicator to track subscription
                
                print("DEMO - login susbscribing with token.")
                
                
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
                
            }).disposed(by: self.client.disposeBag) // Rx does not maintain a memory reference; to make sure that reference is still in place; keep a reference of this object while I do an operation.
            
        }))
        
        DispatchQueue.main.async {
            
            self.present(alert, animated: true, completion: nil)
        }
        
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
                // UIAlertController warning user to login b/c self.client.account.user is nil.
                
            }
            
            print("DEMO - chat creation unsuccessful with \(error.localizedDescription)")
            
        })
        
        performSegue(withIdentifier: "chatView", sender: nil)
    }
    
    // prepare(for segue:)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let chatVC = segue.destination as? ChatController
        
        chatVC?.conversation = client.conversation.conversations.first
        
        print("How many conversations are there: \(client.conversation.conversations.count)")
        
    }
    
}

// a stub for holding the value for private.key
struct Authenticate {
    
    static let userJWT = ""
    
    static let anotherUserJWT = ""
    
}

