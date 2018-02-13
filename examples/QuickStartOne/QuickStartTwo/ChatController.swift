//
//  ChatController.swift
//  QuickStartTwo
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
    
    // sendBtn for sending text
    @IBAction func sendBtn(_ sender: Any) {
        
        do {
            // send method
            try conversation?.send(textField.text!)
            
        } catch let error {
            print(error)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // a handler for updating the textView with TextEvents
        conversation?.newEventReceived.addHandler { event in
            guard let event = event as? TextEvent, event.isCurrentlyBeingSent == false else { return }
            guard let text = event.text else { return }
            
            self.textView.insertText("\n \n \(text) \n \n")
        }
    }
}

