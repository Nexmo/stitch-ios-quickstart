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

Configure your own layout for login with: 

1. an instance of UIButton called `loginBtn`
2. an instance of UIButton called `chatBtn`
3. an instance of UILabel called `statusLbl`
4. an instance of UINavigationController embedded in the scene for what is assigned to the LoginVC. 

### 2.5 - Create the Login Functionality

Below `UIKit` let's import the `Stitch`. Next we setup a custom instance of the `ConversationClient` and saving it as a member variable in the view controller. 

```Objective-C
- (IBAction)loginBtn:(id)sender {
    
    NSString *token = @"Replace me with token";
    
    __weak LoginVC *weakSelf = self;
    
    [client loginWith: token : ^(enum NXMLoginResult result) {
        
        switch (result) {
                
            case NXMLoginResultSuccess:
                
                weakSelf.statusLbl.text = @"Logged in";
                
                if (weakSelf.client.account.user != NULL) {
                    NSLog(@"DEMO - login successful and here is our %@", weakSelf.client.account.user);
                }
                
                break;
                
            default:
                
                weakSelf.statusLbl.hidden = NO;
                
                NSString *reason = @"";
                
                if (result == NXMLoginResultFailed) {
                    reason = @"failed";
                } else if (result == NXMLoginResultInvalidToken) {
                    reason = @"invalid token";
                } else if (result == NXMLoginResultSessionInvalid) {
                    reason = @"session token";
                } else if (result == NXMLoginResultExpiredToken) {
                    reason = @"expired token";
                } else if (result == NXMLoginResultUserNotFound) {
                    reason = @"user not found";
                } else {
                    reason = @"unknown";
                }
                
                NSLog(@"DEMO - login unsuccessful with %@", reason);
                
                break;
        }
        
    }];
}
```

In the interface file add the following property for the status label:

```Objective-C
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
``` 
Return to the implementation file to create the functionality for the `chatBtn`. 

```Objective-C
- (IBAction)chatBtn:(id)sender {
    
    NSString *aConversation = @"aConversation";
    
    __weak LoginVC *weakSelf = self;
    
    [[client conversation] newWith: aConversation shouldJoin: YES :^(NXMConversation * success) {
        //Execute come upon completion
    } onError: ^(NSError * error) {
        
        NSLog(@"Error: %@", error);
        
        if (weakSelf.client.account.user == nil) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"LOGIN" message: @"The `.user` property on self.client.account is nil" preferredStyle: UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler: nil];
            
            [alert addAction: action];
            
            [self presentViewController: alert animated: YES completion: nil];
            
            NSLog(@"DEMO - chat self.client.account.user is nil");
            
            return;
        }
        
        NSLog(@"DEMO - chat creation unsuccessful with %@", error.localizedDescription);
        
    } onComplete:^{
        //Execute code upon completion
    }];
    
    [self performSegueWithIdentifier:@"chatView" sender: nil];
}
```

### 2.5 Navigate to ChatViewController

As we mentioned above, creating a conversation results from a call to the the new() method. In the absence of a server we’ll ‘simulate’ the creation of a conversation within the app when the user clicks the chatBtn.

When we construct the segue for `ChatViewController`, we pass the first conversation so that the new controller. Remember that the `CONVERSATION_ID` comes from the id generated in [step 1.3](#13---create-a-conversation).

```Objective-C 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    ChatVC *chatVC = segue.destinationViewController;
    chatVC.conversation = client.conversation.conversations.conversationsObjc.firstObject;
    //    NXMConversationCollection *conversations = client.conversation.conversations;
    //    chatVC.conversation = [conversations indexWithSafe: conversations.startIndex];
}
```

### 2.6 Create the Chat layout


Configure your own layout for chat with: 

1. an instance of UITextView called `textView`
2. an instance of UITextField called `textField`
3. an instance of UIButton called `sendBtn`


### 2.7 Create the ChatVC

Like last time we'll wire up the views in ChatVC. We also need to grab the reference to `conversation` from the incoming view controller.

```Objective-C
#import <UIKit/UIKit.h>
@import Stitch;

@interface ChatVC : UIViewController

@property (retain, nonatomic) NXMConversation *conversation;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
```

### 2.8 - Sending `text` Events

To send a message we simply need to call `send()` on our instance of `conversation`. `send()` takes one argument, a `String message`.

```Objective-C
- (IBAction)sendBtn:(id)sender {
    
    NSString *text = _textField.text ;
    
    if (text.length > 0) {
        [conversation sendText: text error: NULL];
    }
}
```

### 2.9 - Receiving `text` Events

In `viewDidLoad()` we want to add a handler for handling new events like the TextEvents we create when we press the send button. We can do this like so:

```Objective-C 
NXMEventCollection *events = [conversation events];
    
NXMEventBase *baseEvent = [events indexWithSafe:[events startIndex]];
    
[baseEvent isCurrentlyBeingSent];
```

## 3.0 - Trying it out

After this you should be able to run the app and send messages.

## What's next? 

Click [here](https://github.com/Nexmo/stitch-ios-quickstart/tree/master/examples/simple-conversation/simple-conversation-objc), if you would like to compare your codebase with the codebase for this quick start.