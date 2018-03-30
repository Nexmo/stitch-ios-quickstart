//
//  ChatViewController.swift
//  QuickStartThree
//
//  Created by Eric Giannini on 3/22/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import UIKit
import NexmoConversation

class ChatViewController: UIViewController {
    
    // conversation for passing client
    var conversation: Conversation?
    
    // a set of unique members typing
    private var whoIsTyping = Set<String>()
    
    // tableView for displaying chat
    @IBOutlet weak var tableView: UITableView!
    
    // typingIndicatorLabel for typing indications
    @IBOutlet weak var typyingIndicatorLabel: UILabel!
    
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
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UITableView's delegate
        tableView.delegate = self
        
        //UITableView dataSource
        tableView.dataSource = self
        
        // listen for messages
        conversation!.events.newEventReceived.subscribe(onSuccess: { event in
            if let event = event as? TextEvent, !event.isCurrentlyBeingSent {
                // refresh tableView
                self.tableView.reloadData()
            }
        })
        
        // listen for typing
        conversation!.members.forEach { member in
            member.typing
                .mainThread
                .subscribe(onSuccess: { [weak self] in self?.handleTypingChangedEvent(member: member, isTyping: $0) })
        }
    }
    // a handler for updating the textView with TextEvents
    //        conversation?.events.newEventReceived.subscribe(onSuccess: { event in
    //            guard !event.isCurrentlyBeingSent else { return }
    //
    //            switch event {
    //            case let textEvent as TextEvent:
    //
    //                self.textView.insertText("\n \n \(textEvent.text!) \n \n")
    //
    //            default: break
    //            }
    //        })
    
    
    func refreshTypingIndicatorLabel(){
        if !whoIsTyping.isEmpty {
            var caption = whoIsTyping.joined(separator: ", ")
            
            if whoIsTyping.count == 1 {
                caption += " is typing..."
            } else {
                caption += " are typing..."
            }
            
            DispatchQueue.main.async {
                self.typyingIndicatorLabel.text = caption
            }
            
            
        } else {
            
            DispatchQueue.main.async {
                self.typyingIndicatorLabel.text = ""
            }
        }
    }
    
    
    
    func handleTypingChangedEvent(member: Member, isTyping: Bool) {
        /* make sure it is not this user typing */
        if !member.user.isMe {
            let name = member.user.name
            
            if isTyping {
                whoIsTyping.insert(name)
            } else {
                whoIsTyping.remove(name)
            }
            
            refreshTypingIndicatorLabel()
        }
    }
    
    //        conversation!.events.forEach({ event in
    //
    //            if let event = event as? TextEvent {
    //
    //                print(event.text!)
    //
    //            }
    //        })
    //
    //        conversation!.events.forEach({ event in
    //            print(event)
    //        })
    
    
    
    
    // Do any additional setup after loading the view.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ChatViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        <#code#>
    }
    
}

extension ChatViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation!.events.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellWithIdentifier", for: indexPath)
        
        let message = conversation?.events[indexPath.row] as? TextEvent
        
        cell.textLabel?.text = message?.text
        
        return cell;
    }
}
