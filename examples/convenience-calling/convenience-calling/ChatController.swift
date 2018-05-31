//
//  ChatController.swift
//  convenience-calling
//
//  Created by Eric Giannini on 5/30/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import UIKit
import NexmoConversation

class ChatController: UIViewController {
    
    // conversation for passing client
    var conversation: Conversation?
    
    // textView for displaying chat
    @IBOutlet weak var textView: UITextView!
    
    // textField for capturing text
    @IBOutlet weak var textField: UITextField!
    
    @IBAction internal func disable() {
        
        conversation?.audio.disable()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // sendBtn for sending text
    @IBAction func sendBtn(_ sender: Any) {
        
        do {
            // send method
            try conversation?.send(textField.text!)
            
        } catch let error {
            print(error)
        }
        
    }
    
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
        
        do {
            try conversation?.audio.enable()
            sender.titleLabel?.text = "🔇"
        } catch {
            conversation?.audio.disable()
            sender.titleLabel?.text = "🔈"
        }
        
    }
    
    @IBAction func reject() {
        call.reject()
    }
    
    @IBAction func answer() {
        call.answer(onSuccess: {
            // code here
        }, onFailure: { error in
            // code here
        })
    }
    
    @IBAction func hangUp() {
        call.hangUp(onSuccess: {
            // code here
        }, onFailure: { error in
            // code here
        })
    }
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidload()
        
        // a handler for updating the textView with TextEvents
        conversation?.events.newEventReceived.addHandler { event in
            guard let event = event as? TextEvent, event.isCurrentlyBeingSent == false else { return }
            guard let text = event.text else { return }
            
            self.textView.insertText(" \(text) \n ")
        }
        
        try client.media.inboundCalls.subscribe(onSuccess: { call in
            
            // Here you configure code for all incoming calls.
            
            let alert = UIAlertController(title: "Someone is calling you.", message: "Are you going to answer?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Answer", comment: "Default action"), style: .default, handler: { _ in
                //
                
                NSLog("The \"OK\" alert occured.")
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        })
        
    }

    // MARK: - Audio Methods
    private func setupAudio() {
        do {
            let session = AVAudioSession.sharedInstance()
            
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            session.requestRecordPermission { _ in }
        } catch  {
            print(error)
        }
    }
    
    private func enable() {
        do {
            try self.conversation?.audio.enable()
        } catch let error {
            self.getView.state.text = "failed: \(error)"
        }
    }
    
       // MARK: - Call Convenience Methods
    
    private func call() {
        
        do {
            let users = ["user1", "user2"]
            
            try client.media.call(users, onSuccess: { result in
                // code here
                // result contains Call object and any errors from requesting invites for users
            }, onError: { networkError in
                // code here
            })
        } catch let error {
            // code here
        }
        
    }
    
}
