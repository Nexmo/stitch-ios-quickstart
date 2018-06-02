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

### 1.1 Modify the ChatController with `.storyboard` files 
To modify the `.storyboard` to accomodate a call convenience method, let's perform the following changes: 

- Inside of the scene for `ChatViewController.swift` add an instance of `UIBarButtonItem` to the upper right hand corner of the `UINavigationController`. 

- Control drag from the instance to the `ChatViewController.swift` to create an action we will program later. 

### 1.2 Call Emoji! 📞

With the `UIBarButtonItem` properly laid out in `.storyboard` the next step is to configure its UI with a Call Emoji! 📞

- Under the attributes inspector in the utilities menu change the `UIBarButtonItem`'s System Item to Custom. 
- Inside of the Bar Item's properties, select title. 
- Inside of the Bar Item's title property add a 📞!

### 1.3 ☎️ `call` convenience method 

How will we configure the `UIBarButton`'s action? We will configure it with our `call` convenience method, which is built on top of our existing architecture for the `client. We access call functionality through class called `media`. In the `media` class there is a single method for handling calls, called `call`. There were no puns intended here! ;) 


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

The method is really simple. It takes an array of users. It handles connecting with each one of the elements in the user array. Before we program it for real. Let's make sure our UI for chat is setup. 

## 2.0 

To ensure the chat is setup, we will configure an instance of `UITableView` to handle messages in the chat. To implement the `UITableView`, take the following steps: 

- Add an instance of `UITableView` to the scene for `ChatViewController` in `.storyboard`
- Control drag to create an reference in `ChatViewController`
- Inside of `ChatViewController`'s `viewDidLoad(:)` configure both the `dataSource` and `delegate` properties on our reference to `tableView` to `.self`. 
- Last but no least we will add an extension to ensure confirmity to the required methods:

```
extension ChatController : UITableViewDataSource {
    
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
``` 
With our chat set up, we are ready to move onto setting up the call method. 

## 2.0 -  📞 + ☎️ equals a call

```
       // MARK: - Call Convenience Method
    private func call() {
        
        let callAlert = UIAlertController(title: "Call", message: "Who would you like to call?", preferredStyle: .sheet)
        
        conversation?.members.forEach{ member in
            callAlert.addAction(UIAlertAction(title: member.user.username, style: .default, handler: {
                
                    client.media.call(member.user.username, onSuccess: { result in
                        // if you would like to display a UI for calling...
                    }, onError: { networkError in
                        // if you would like to display a log for error...
                    })
                
            }))
        }
        
        self.present(alert, animated: true, completion: nil)

    }
    
}
```