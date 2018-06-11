## Sending members Push Notifications with the Nexmo Stitch iOS Conversation SDK

You have already implemented multiple features with which to stitch together a conversation: initializing an instance of our client, creating a conversation, adding members, displaying conversations' history, or enabling audio. Let's add push notifications now! 

Push Notification depend on Apple Push Notification's service (a.k.a. _APNS_). It is a robust, secure, and highly efficient service for app developers to propagate information throughout a network of interconnected iOS devices, especially those connected to the Stitch iOS SDK. Push Notifications therefore rely almost entirely upon APNS. 

In this tutorial we will configure: an APNS certificate in keychain, uploading/downloading an iOS Push Notification certificate, toggling permissions in Xcode, setting up the Stitch iOS SDK within the sample app and sending out our first Push Notification!  
 
 
## 1 - Setup

The Nexmo iOS Conversation SDK utilizes JSON web tokens (i.e., JWTs) to for contextual, omnichannel, artificially intelligent in-app endpoints. While artificial intelligence is still in the process of being developed, IP Message, for instance, is only one of the many channels that literally plug into an app integrated with the Nexmo iOS Conversation SDK. While the sky is the limit, let's start from ground zero to create a Nexmo application. 

_Note: The steps within this section can all be done dynamically via server-side logic. But in order to get the client-side functionality we're going to manually run through setup._

### 1.1 - Create a Nexmo application

Create an application within the Nexmo platform.

```bash
$ nexmo app:create "Conversation iOS App" http://example.com/answer http://example.com/event --type=rtc --keyfile=private.key
```

Nexmo Applications contain configuration for the application that you are building. The output of the above command will be something like this:

```bash
Application created: aaaaaaaa-bbbb-cccc-dddd-0123456789ab
No existing config found. Writing to new file.
Credentials written to /path/to/your/local/folder/.nexmo-app
Private Key saved to: private.key
```

The first item is the Application ID and the second is a private key that is used generate JWTs that are used to authenticate your interactions with Nexmo. You should take a note of it. We'll refer to this as `YOUR_APP_ID` later.


### 1.2 - Create a Conversation

Create a conversation within the application:

```bash
$ nexmo conversation:create display_name="Nexmo Chat"
```

The output of the above command will be something like this:

```sh
Conversation created: CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab
```

That is the Conversation ID. Take a note of it as this is the unique identifier for the conversation that has been created. We'll refer to this as YOUR_CONVERSATION_ID later.

### 1.3 - Create a User

Create a user who will participate within the conversation.

```bash
$ nexmo user:create name="jamie"
```

The output will look as follows:

```sh
User created: USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab
```

Take a note of the `id` attribute as this is the unique identifier for the user that has been created. We'll refer to this as `YOUR_USER_ID` later.

### 1.4 - Add the User to the Conversation

Finally, let's add the user to the conversation that we created. Remember to replace `YOUR_CONVERSATION_ID` and `YOUR_USER_ID` values.

```bash
$ nexmo member:add YOUR_CONVERSATION_ID action=join channel='{"type":"app"}' user_id=YOUR_USER_ID
```

The output of this command will confirm that the user has been added to the "Nexmo Chat" conversation.

```sh
Member added: MEM-aaaaaaaa-bbbb-cccc-dddd-0123456789ab
```

You can also check this by running the following request, replacing `YOUR_CONVERSATION_ID`:

```bash
$ nexmo member:list YOUR_CONVERSATION_ID -v
```

Where you should see a response similar to the following:

```sh
name                                     | user_id                                  | user_name | state  
---------------------------------------------------------------------------------------------------------
MEM-aaaaaaaa-bbbb-cccc-dddd-0123456789ab | USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab | jamie     | JOINED
```

### 1.5 - Generate a User JWT

Generate a JWT for the user and take a note of it. Remember to change the `YOUR_APP_ID` value in the command.

```bash
$ USER_JWT="$(nexmo jwt:generate ./private.key sub=jamie exp=$(($(date +%s)+86400)) acl='{"paths": {"/v1/sessions/**": {}, "/v1/users/**": {}, "/v1/conversations/**": {}}}' application_id=YOUR_APP_ID)"
```

*Note: The above command saves the generated JWT to a `USER_JWT` variable. It also sets the expiry of the JWT to one day from now.*

You can see the JWT for the user by running the following:

```bash
$ echo $USER_JWT
```

### 1.6 The Nexmo Conversation API Dashboard 

If you would like to double check any of the JWT credentials, navigate to [your-applications](https://dashboard.nexmo.com/voice/your-applications) where you can see a table with three entries respectively entitled "Name", "Id", or "Security settings". Under the menu options for "Edit" next to "Delete", you can take a peak at the details of the applications such as "Application name", "Application Id", etc... 


## 2 - Sending the APNS Certificate to Nexmo, the Vonage API Platform

There are series of steps to take in order to send the APNS Certificate to Nexmo 

### 2.0 Creating the push token

Here we want to create the push token. 

```bash
// Create push token
hexdump -ve '1/1 "%.2x"' < applecert.p12 > applecert.pfx.hex
hextoken=cat applecert.pfx.hex
```

### 2.1 Upload push token

With the JWT, which as assigned to `USER_JWT` in step 1.5, allowing us to access to Nexmo,  our next step is to upload the push certificate. 

```bash
// Upload
curl -v -X PUT \
-H "Authorization: Bearer $USER_JWT \
-H "Content-Type: application/json" \
-d "{\"token\":\"$hextoken\"}" \
https://api.nexmo.com/v1/applications/$appid/push_tokens/ios
```

### 2.2 Retrieve push token

Here we are going to retrieve the push token. 

```bash
// Retrieve push token for testing
curl -H "Authorization: Bearer $jwt_dev" 
-H "Content-Type: application/json" 
https://api.nexmo.com/v1/applications/$appid/push_tokens/ios
```

## 3 - iOS App

Create a new Single View Application. Navigate to `Main.storyboard`. Inside of the `ViewController.swift` scene, add a text field above a button. Center both in the view vertically and horizontally. Navigate to the project folder. While pressing shift + option + command, click on `ViewController.swift`. Configure the panes to display both simultaneously in the editor. Control drag from the text field to `ViewController.swift` to create an outlet called `textField`. Control drag from the button to create an action called `sendBtn`. 

## 4 - Requesting Permissions in `Info.plist`

Apple requires developers to request permission from users for Push Notifications. In order to request permission, we have to configure a value for a key in the `Info.plist`. You can do it in one of two ways. You can do it directly by avigating to `Info.plist`, selecting `Show Raw Keys & Values`, and adding a key `UIBackgroundModes` with a value as `remote-notifications`, as such:  

```xml
<dict>
<key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
    </array>
```

Alternatively, you can do the following: **Targets** -> **Your App** -> **Capabilities** -> **Background Modes** and check Remote notifications. 

![Remotenotifications.png](./Remotenotifications.png)

Given the way the iOS Push Notification work, it’s critical for the user to grant your app permission on the first pass. If the user taps “Don’t Allow”, it takes multiple taps within the Settings app to re-grant permission, making it extremely unlikely, and practically irreversible so many developers layer a recovable request prior to displaying Apple's irrevocable one. 

### 4.1 Registering for Remote Notifications

As soon as the `Info.plist` is configured, we have to register for remote notifications with Apple's method called `registerForRemoteNotifications`. Since Push Notifications run disrupt an app's User Interface, registration needs to happen on the main thread. To register on the main thread we pass `registerForRemoteNotifications` as an argument in the `async().` method on `.main` property for `DispatchQueue`:

```swift
DispatchQueue.main.async(execute: UIApplication.shared.registerForRemoteNotifications)
```
### 4.2 Registering Device Token with the SDK

After the functionality for registering remote notifications is integrated, we program `.didRegisterForRemoteNotificationsWithDeviceToken` to pass the device token to the SDK: 

```swift
// MARK:
// MARK: Notification

func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
client.appLifecycle.push.registeredForRemoteNotifications(with: deviceToken)
}
```

## 5 Configuring the Stitch iOS SDK within the iOS App 

The last step is to configure the app to respond to requests for Push Notifications. Drop either of the following lines of code inside of `viewDidLoad(:)` in `ViewController.swift`:

```swift
// listen for push notifications
ConversationClient.instance.appLifecycle.notifications.subscribe(onSuccess: { notification in
// code here
})

```
You can also subscribe to events for push notifications through the `.receiveRemoteNotifications` property here: 

```
ConversationClient.instance.appLifecycle.receiveRemoteNotification.subscribe(onSuccess: { notification in
// code here
})
```

## 5.1 Configuring `sendBtn`

In `ViewController.swift` drop in an instance of `ConversationClient` so that we can send messages. 

```
 /// Nexmo Conversation client
    let client: ConversationClient = {
        return ConversationClient.instance
    }()
```
Next we configure our `sendBtn` to send messages through our `ConversationClient`:

```
    // sendBtn for sending text
    @IBAction func sendBtn(_ sender: Any) {
        
        do {
            // send method
            try client.conversation?.send(textField.text!)
            
        } catch let error {
            print(error)
        }
        
    }
```

Finally, we need to listen for text updates so we are adding a handler to `viewDidLoad(:)`:

```
    // a handler for updating the textView with TextEvents
    client.conversation?.events.newEventReceived.addHandler { event in
        guard let event = event as? TextEvent, event.isCurrentlyBeingSent == false else { return }
        guard let text = event.text else { return }

        self.textView.insertText("\n \n \(text) \n \n")
    }
```

## 6 Sending a push notification 
In the `payload` variable of this POST request we can put together a message that will displayed in the push notification: 

```bash
curl -v -X POST \
   -H "Authorization: Bearer $jwt_user" \
   -H "Content-Type: application/json" \
   -d "{\"device_type\": \"ios\", \
           \"device_token\":\"$regtoken\", \
           \"application_id\":\"$appid\", \
           \"payload\": {\"aps\":{\"alert\":\"Push data\"}}}" \
   http://qa1.internal:3150/v1/push/notify
```
After sending the POST request we should be able to see the displayable message in a push notification. 

## 6 Trying it out 

Return the Nexmo dashboard. After sending out a remote notification we should a dialog box push down from the top of the interface with our message! 

There we go! Apple's APNS is all ready to go. Since APNS is a new feature inside of the app, a new build needs to be uploaded to the App Store through iTunesConnect for this feature to work on anything but the test app. 


