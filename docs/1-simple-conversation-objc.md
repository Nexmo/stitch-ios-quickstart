# Getting Started with the Nexmo Stitch iOS SDK in Objective-C

In this getting started guide we'll demonstrate how to build a simple conversation app with IP messaging using the Nexmo Stitch iOS SDK but with interoperability in Objective-C.

## 1 - Concepts & Setup 

Please see the Swift [guide](https://developer.nexmo.com/stitch/in-app-messaging/guides/1-simple-conversation) for an introduction to concepts and setting up a JSON web token for the Nexmo dashboard.

## 2 - Create the iOS App

With the basic setup in place we can now focus on the client-side application.

### 2.1 Start a new project

Open Xcode and start a new project. We'll name it "simple-conversation-objc".  

## Interoperability with Objective-C

While the Swift iOS SDK is written in Swift, there is a support for interoperability in Objective-C. 

### Making the Swift Classes available to Objective-C Files

The process of setting up interoperability in Objective-C is identical for nearly all environments. 

1. Open up the Objective-C project. 
2. Add a new Swift file to the project. In the menu select File>New>File…. Select Swift File instead of a Cocoa Touch File. 
3. Name the file `Stitch-Swift`.
4. A dialogue box will appear in Xcode so please make sure to select "Create Bridging Header".
5. Go to your project's "Build Settings" and switch to "All" instead of "Basic", which is the default option. Under "Packaging" turn on  "Defines Module" by chaning "No" to "Yes". Changing this parameter enables us to use Swift classes inside of Objective-C files.
6. Inside of "Build Settings" make sure to look for "Product Module Name" in the "Packaging" section so that you can copy the "Product Module Name" exactly. 

### 2.2 Adding the Nexmo iOS Conversation SDK to Cocoapods

Navigate to the project's root directory in the Terminal. Run: `pod init`. Open the file entitled `PodFile`. Configure its specifications accordingly: 

```bash
# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

source "https://github.com/Nexmo/PodSpec.git"
source 'git@github.com:CocoaPods/Specs.git'

target 'simple-conversation-objc' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod "Nexmo-Stitch", :git => "https://github.com/nexmo/conversation-ios-sdk.git", :branch => "master" # development
end
```

## Accessing a Swift Class in Objective-C

To start programming in Objective-C with the Stitch Swift iOS SDk, add a CocoaTouch class called `LoginVC` as a subclass of UIViewController. Program the interface file in the following way:

1. Import the Stitch iOS SDK in the interface file.
2. In the interface file's interface add a property for the client. 

Your code should look like this: 

```Objective-C
@import Stitch;

@interface LoginVC : UIViewController

@property (retain, nonatomic) NXMConversationClient *client;

@end
```

Program the implementation file in the following way: 

1. Import the LoginVC interface file. 
2. Synthesize the client. 
3. Initialize the client after the controller's view is loaded into memory. 

Your code should look like this: 


```Objective-C
#import "LoginVC.h"

@interface LoginVC ()

@end

@implementation LoginVC

@synthesize client;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    client = [NXMConversationClient instance];
}

@end
```

### 2.4 Creating the login layout
Let's layout the login functionality. Set constraints on the top & leading attributes of an instance of UIButton with a constant HxW at 71x94 to the top of the Bottom Layout Guide + 20 and the leading attribute of `view` + 16. This is our login button. Reverse leading to trailing for another instance of UIButton with the same constraints. This our chat button. Set the text on these instances accordingly. Add a status label centered horizontally & vertically. Finally, embedd this scene into a navigation controller. Control drag from the chat button to scene assigned to the chat controller, naming the segue `chatView`. 


### 2.5 - Create the Login Functionality

Below `UIKit` let's import the `NexmoConversation`. Next we setup a custom instance of the `ConversationClient` and saving it as a member variable in the view controller. 

```Swift
    /// Nexmo Conversation client
    let client: ConversationClient = {
        return ConversationClient.instance
    }()
```

We also need to wire up the buttons in `LoginViewController.swift` Don't forget to replace `USER_JWT` with the JWT generated from the Nexmo CLI in [step 1.6](#16---generate-a-user-jwt).

```Swift
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
        
        performSegue(withIdentifier: "chatView", sender: nil)
    }
```

### 2.6 Stubbed Out Login

Next, let's stub out the login workflow.

Create an authenticate struct with a member set as `userJWT`. For now, stub it out to always return the vaue for `USER_JWT`. 

```Swift
// a stub for holding the value for private.key 
struct Authenticate {

    static let userJWT = ""
    
}
```

After the user logs in, they'll press the "Chat" button which will take them to the ChatViewController and let them begin chatting in the conversation we've already created.

### 2.5 Navigate to ChatViewController

As we mentioned above, creating a conversation results from a call to the the new() method. In the absence of a server we’ll ‘simulate’ the creation of a conversation within the app when the user clicks the chatBtn.

When we construct the segue for `ChatViewController`, we pass the first conversation so that the new controller. Remember that the `CONVERSATION_ID` comes from the id generated in [step 1.3](#13---create-a-conversation).

```Swift
    // prepare(for segue:)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // setting up a segue
        let chatVC = segue.destination as? ChatController
        
        // passing a reference to the conversation
        chatVC?.conversation = client.conversation.conversations.first


    }
```

### 2.6 Create the Chat layout

We'll make a `ChatActivity` with this as the layout. Add an instance of UITextView, UITextField, & UIButton.Set the constraints on UITextView with setting its constraints: .trailing = trailingMargin, .leading = Text Field.leading, .top = Top Layout Guide.bottom, .bottom + 15 = Text Field.top. Set the leading attribute on the Text Field to = leadingMargin and its .bottom attribute + 20 to Bottom Layout Guide's top attribute. Set the Button's .trailing to trailingMargin + 12 and its .bottom attribute + 20 to the Bottom Layout Guide's .top attribute. 


### 2.7 Create the ChatActivity

Like last time we'll wire up the views in `ChatViewController.swift` We also need to grab the reference to `conversation` from the incoming view controller.

```Swift

import UIKit
import NexmoConversation

class ChatController: UIViewController {
    
    // conversation for passing client
    var conversation: Conversation?
    
    // textView for displaying chat
    @IBOutlet weak var textView: UITextView!
    
    // textField for capturing text
    @IBOutlet weak var textField: UITextField!
    
}

```

### 2.8 - Sending `text` Events

To send a message we simply need to call `send()` on our instance of `conversation`. `send()` takes one argument, a `String message`.

```Swift
    // sendBtn for sending text
    @IBAction func sendBtn(_ sender: Any) {
        
        do {
            // send method
            try conversation?.send(textField.text!)
            
        } catch let error {
            print(error)
        }
        
    }
```

### 2.9 - Receiving `text` Events

In `viewDidLoad()` we want to add a handler for handling new events like the TextEvents we create when we press the send button. We can do this like so:

```Swift
        // a handler for updating the textView with TextEvents
        conversation?.events.newEventReceived.addHandler { event in
            guard let event = event as? TextEvent, event.isCurrentlyBeingSent == false else { return }
            guard let text = event.text else { return }

            self.textView.insertText("\n \n \(text) \n \n")
        }
```

## 3.0 - Trying it out

After this you should be able to run the app and send messages.

![Hello world!](http://recordit.co/1Gqo2J5rfn)

##### Footnotes 
<a name="myfootnote1">1</a>: Since MacOS is a UNIX based OS, the best practice for installation is to avoid `sudo`. Node.js requires `sudo` but [Homebrew](https://brew.sh/), the missing package manager for macOS, does not. Additionally, the `$PATH` (i.e., to the Node executable) is automatically defined.  
