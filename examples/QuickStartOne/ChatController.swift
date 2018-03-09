//
//  ChatController.swift
//  QuickStartOne
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
        conversation?.events.newEventReceived.subscribe(onSuccess: { event in
            guard !event.isCurrentlyBeingSent else { return }
            
            switch event {
            case let textEvent as TextEvent:
              
                self.textView.insertText("\n \n \(textEvent.text!) \n \n")
                
            default: break
            }
        })
    }
}
