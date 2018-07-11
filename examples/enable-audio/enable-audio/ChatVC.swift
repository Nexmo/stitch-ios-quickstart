//
//  ChatVC.swift
//  enable-audio
//
//  Created by Eric Giannini on 7/10/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import UIKit
import Stitch
import AVFoundation

class ChatVC: UIViewController {


    var conversation: Conversation?
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conversation?.events.newEventReceived.subscribe(onSuccess: { event in
            guard let event = event as? TextEvent, event.isCurrentlyBeingSent == false else { return }
            guard let text = event.text else { return }
            
            self.textView.insertText(" \(text) \n ")
        })
    }
    
    @IBAction func sendBtn(_ sender: Any) {
        
        do {
            // send method
            try conversation?.send(textField.text!)
            
        } catch let error {
            print(error)
        }
        
    }
    
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
            try self.conversation?.media.enable()
        } catch let error {
            self.textView.text = "failed: \(error)"
        }
    }
    
    @IBAction internal func disable() {
        conversation?.media.disable()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
        
        do {
            try conversation?.media.enable()
            sender.titleLabel?.text = "🔇"
        } catch {
            conversation?.media.disable()
            sender.titleLabel?.text = "🔈"
        }
        
    }
}
