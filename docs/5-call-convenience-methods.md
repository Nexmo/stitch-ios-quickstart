## Getting Started with the Nexmo Conversation iOS SDK

In this getting started guide we'll cover adding call methods to the Conversation we created in the [simple conversation with audio](/stitch/in-app-messaging/guides/4-enable-audio/swift) getting started guide. We'll deal with member call events that trigger on the application and call state events that trigger on the Call object.

The main difference between using these Call convenience methods and enabling and disabling the audio in the previous quickstart is that these methods do a lot of the heavy lifting for you. By calling a user directly, a new conversation is created, and users are automatically invited to the new conversation with audio enabled. This can make it easier to start a separate direct call to a user or start a private group call among users.

## Concepts

This guide will introduce you to the following concepts.

- **Calls** - calling an User in your application without creating a Conversation first
- **Call Events** - CallEvent event that fires on an `ConversationClient` or `Call`


### Before you begin
- Ensure you have run through the [previous guide](/stitch/in-app-messaging/guides/4-enable-audio/swift) 

### 1.0 - Updating iOS App

We will use the application we already created for [the first audio getting started guide](/stitch/in-app-messaging/guides/4-enable-audio/swift). All the basic setup has been done in the previous guides and should be in place. We can now focus on updating the client-side application.

### 1.1 Adding a CallViewController with `.storyboard` files 

### 1.2 Initiating a call 

Pass a list of users to initiate a call object:

```swift
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
``` 

## 2.0 - Subscribing to call events

To get given a Call object for all incoming calls, there is a Swift closure with `call` as its object. 

```swift
try client.media.inboundCalls.subscribe(onSuccess: { call in })
```

## Receive an incoming call 

You could do any number of things after getting a given Call object. You could show CallKit. You could show a customized user interface. Or you could just show an alert like we do to receive an incoming call. 

```swift
try client.media.inboundCalls.subscribe(onSuccess: { call in

// Here you configure code for all incoming calls. 

let alert = UIAlertController(title: "Someone is calling you.", message: "Are you going to answer?", preferredStyle: .alert) 

alert.addAction(UIAlertAction(title: NSLocalizedString("Answer", comment: "Default action"), style: .default, handler: { _ in 
// 

NSLog("The \"OK\" alert occured.")

}))

self.present(alert, animated: true, completion: nil)    

})
```

Since we will be tapping into protected device functionality we will have to ask for permission. We will update our `.plist` as well as display an alert. After permissions we will add AVFoundation class, set up audio from within the SDK and add a speaker emoji for our UI 🔈

## Reject an incoming call 

optional `onError:` can be called

```swift
call.reject()
```


### 2.1 Receive a PSTN Phone Call via Stitch

After you've set up you're app to handle incoming calls, you can follow the PSTN to IP tutorial published on our blog. Now you can make PSTN Phone Calls via the Nexmo Voice API and receive those calls via the Stitch SDK.

### 2.2 Answer an incoming call 

`onSuccess:` will be called when call has been answered

```swift
call.answer(onSuccess: {
    // code here              
}, onFailure: { error in
    // code here
})
``` 

### 2.3 - Let users hang up on a call 

`onSuccess` is called when the call has successfully hung up. 

```swift
call.hangUp(onSuccess: {
    // code here
}, onFailure: { error in
    // code here
})
```



## 3.0 - Open the app on two devices

Now run the app on two devices (make sure they have a working mic and speakers!), making sure to login with the user name `jamie` in one and with `alice` in the other. Call one from the other, accept the call and start talking. You'll also see events being logged Logcat.