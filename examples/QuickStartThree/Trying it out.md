
— Quick Start Three notes : 

- Add the layout from the conversational UI 
- Rebuild the LoginViewController & ChatViewController
- Test the Nexmo CLI commands 
- Invite a member to a conversation 
- Update the iOS app with functionality for fetching conversation history 
- Add the typing indicator 
- Add the reading indicator
- https://developer.nexmo.com/sdk/stitch/ios/Classes/ReceiptRecord/ReceiptState.html
- https://dashboard.nexmo.com/stitch


`client.conversation.conversations` contains a list of conversations

use `client.conversation.conversations.asObservable` to listen for changes in the list i.e inserts or updates

the SDK is always keeping the conversation in sync in the background


after adding the `UITableView` to storyboards, constraining its leading, trailing and top guides to the surrounding Safe Area respectively, add a prototype cell. 

The next step is to create a connection from our instance of `UITableView` to its controller in `ChatViewController.swift` so that we set the `delegate` or `dataSource` properties referentially. With `Main.storyboard` open while simultaneously holding shift option command, click on `ChatViewController.swift` so that it appears in the assistant editor. Control drag from within the body of `UITableView` to `ChatViewController.swift` to declare `tableView` as an outlet as such: 

```
    class ChatViewController: UIViewController {

         @IBOutlet weak var tableView: UITableView!

     }
 
```

Rather than setting the `delegate` or `dataSource` properties through control/dragging, let us set these properties on our reference to `UITableView` programmatically so that no one forgets that they are set to `self` in `viewDidLoad(:)` when we build and run the program! It should look like so: 

``` 

    override func viewDidLoad() {
        super.viewDidLoad()
       
        //
        tableView.delegate = self
        tableView.dataSource = self
        
    }
        
```

You should immediately receive a warning saying that "Type `ChatViewController.swift` does not conform to the protocol `UITableViewDataSource`. If you do, great! It means our instance of `tableView` is configured to its controller. Let's make it conform to the protocol now! 

In order to make it conform to the `UITableViewDataSource` protocol we will make use of one of Swift's powerful features: an `extension`. Down below the class's closing brack for its declaration, declare an extension for `ChatViewController`. Within the extension add the two required methods for data source: `numberOfRows` & `dequeueReusableCellWithIdentifier`. While these have boilerplate code, these will later be configured with properties from our instance of the conversation client. 

## Using more Event Listeners with the Nexmo Stitch In-App Messaging iOS SDK

In this getting started guide we'll demonstrate how to show previous history of a Conversation we created in the [simple conversation](1-simple-conversation.md) getting started guide. From there we'll cover how to show when a member is typing and mark text as being seen.

## Concepts

This guide will introduce you to **States**. We'll be observing different states for receipts: `sending`, `delivered`, and `seen`. We will observe these states so that the UI will be updated reactively. 


### Before you begin


* Ensure you have run through the [the first](1-simple-conversation.md) and [second](2-inviting-members.md) quickstarts.
* Make sure you have two iOS devices to complete this example. They can be two simulators, one simulator and one physical device, or two physical devices.

## 1 - Setup

For this quickstart you won't need to simulate server side events with `curl`. You'll just need to be able to login as both users created in the [first](1-simple-conversation.md) and [second](2-inviting-members.md) quickstarts.

If you're continuing on from the previous guide you may already have a `APP_JWT`. If not, generate a JWT using your Application ID (`YOUR_APP_ID`).

```bash
$ APP_JWT="$(nexmo jwt:generate ./private.key application_id=YOUR_APP_ID exp=$(($(date +%s)+86400)))"
```

You may also need to regenerate the users JWTs. See quickstarts 1 and 2 for how to do so.

## 2 Update the iOS App

We will use the application we already created for quickstarts [1](1-simple-conversation.md) and [2](2-inviting-members.md). With the basic setup in place we can now focus on updating the client-side application. We can leave `LoginViewController.swift` alone. For this demo, we'll solely focus on the `ChatViewController.swift`.

### 2.1 Updating the app layout

We're going to be adding some new elements to our chat app so let's update our layout to reflect them. 

#### 2.1.1 UITableView 

Let us start with a new instance of We are going to add an instance of `UITableView` whose cells will display messages from the chat. In `Main.storyboard` navigate to the `ChatViewController` scene. Delete our instance of `UITextView`. Control drag an instance of `UITableView` onto the  scene. 

We want to set its constraints so that it remains flush with the iOS keyboard. We will set a constraint for its `bottomLayoutGuide` to 145 points away from the bottom of the Safe Area's layout guide. 


#### 2.1.2 UILabel 

Let us added an `UILabel` called `typingIndicator` shortly below the instance of `UITableView`. We'll load the chat history's messages in the `UITableView` and show a message in the `typingIndicator` when a user is typing. 

In the next subsection we program `UITableView`'s required delegate and datasource methods for handling messages displayed in a downwardly cascading row. 


### 2.2 Adding the new UI to the `ChatViewController`

In the previous quick starts we showed messages by adding to a TextView. For this example we'll show you how to use the iOS SDK with an instance of `UITableView`. Let's add our new UI elements to the ChatActivity:

```Swift

```

We'll also need to attach the EventListener. We'll do so in `attachListeners()`

```Swift

```

And since we're attaching the listeners we'll need to remove them as well. Let's do that in the `onPause` part of the lifecycle.

```Swift

```

### 2.3 Creating the ChatAdapter and ViewHolder

A RecyclerView is a UITableView

Our RecyclerView will need a Adapter and ViewHolder. We can use this:

```Swift
```

We'll also need to create a layout for the ViewHolder. Our layout will have a textview to hold the message text. The layout will also have a check mark image that we can make visible or set the visibility to `gone` depending on if the other users of the chat have seen the message or not. The layout will look like so:

```Swift
```

### 2.4 - Show chat history

The chat history should be ready when we start the `ChatViewController.swift` so we'll fetch the history in `LoginViewController.swift` before we fire the intent to start the next activity. We'll modify the `goToConversation()` method in `LoginActivity` to reflect this.

```java
```

Calling `updateEvents()` on a conversation retrieves the event history. You can pass in two `Event` ids into the `updateEvents()` method to tell it to only retrieve events within the timeframe of those IDs.  We'll pass `null` into the first two parameters instead since we want to fetch the whole history of the conversation. Now when we fire the intent and start the `ChatActivity` we'll have the history of the chat loaded into the RecyclerView.

A RecyclerView is a UITableView 

### 2.5 - Adding Typing and Seen Listeners

We can add other listeners just like we added our other Listener. The `startTyping` and `stopTyping` is used to indicate when a user is currently typing or not. The `typingEvent()` is used to listen to typing events sent. Finally, the `seenEvent()` will be used to mark our messages as read. We'll add theses listeners to our `attachListeners()` method.

```Swift
```

We can tell the Conversation SDK when a member is typing using `TextView`'s `addTextChangedListener`. We'll attach a `TextWatcher` to the `chatBox`. In the `afterTextChanged` callback we'll look at the length of the text in the EditText. If the text is greater than 0, we know that the user is still typing. Depending on if the user is typing we'll call `sendTypeIndicator()` with `Member.TYPING_INDICATOR.ON` or `Member.TYPING_INDICATOR.OFF` as an argument. The `sendTypeIndicator` method just fires either `conversation.startTyping()` or `conversation.stopTyping()` By adding a listener to `conversation.typingEvent()` we can then update our `typingNotificationTxt` with the correct message of who's typing or set the message to null if no one is typing.

Finally we'll add a Listener to the `conversation.seenEvent()` so that when an event is marked as seen, we'll update the `ChatAdapter` and show the events as seen in our UI.


### 2.6 - Marking Text messages as seen

We'll only want to mark our messages as read when the other user has seen the message. If the user has the app in the background, we'll want to wait until they bring the app to the foreground and they have seen the text message in the RecyclerView in the `ChatActivity`. To do so, we'll need to mark messages as seen in the `ChatAdapter.` Let's make the following changes to the `ChatAdapter`

a RecyclerView is a UITableView

```Swift
```

We've added `Member self` to our constructor and as a member variable to the `ChatAdapter`. We've also made some changes to the `onBindViewHolder` method. Before we start marking something as read, we want to ensure that we're referring to a `Text` message. That's what the `events.get(position).getType().equals(EventType.TEXT)` check is doing. We only want to mark a message as read if it the sender of the message is not our `self`. That's why `!textMessage.getMember().equals(self)` is there. We also don't want to mark something as read if it's already been marked read. The `memberHasSeen` method looks up all of the `SeenReceipt`s and will only mark the method as read if the current user hasn't created a `SeenReceipt`. Then, we only want to show the `seenIcon` if the message has been marked as read. That's what `!textMessage.getSeenReceipts().isEmpty()` is for.

# Trying it out

Run the apps on both of your emulators. On one of them, login with the username "jamie". On the other emulator login with the username "alice"
Once you've completed this quickstart, you can run the sample app on two different devices. You'll be able to login as a user, join an existing conversation, chat with users, show a typing indicator, and mark messages as read. Here's a gif of our quickstart in action.

![Awesome Chat](http://g.recordit.co/hfTUzwQYNH.gif)

