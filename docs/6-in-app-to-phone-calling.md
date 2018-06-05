# Nexmo In-App to Phone Calling!

## What is an NCCO? 

## Configuring the UI

## Programming the methods

```
 // TODO: STEP 1
 import Stitch
```

 ```
 // TODO: STEP 2
 private var call: Call?
 ```
 
 ```
    // MARK:
    // MARK: Lifecycle
    
    // TODO: STEP 3
    override func viewDidLoad() {
        super.viewDidLoad()
        ConversationClient.configuration = Configuration.init(with: .info)
       ConversationClient.instance
           .login(with: "JWT_TOKEN")
           .subscribe()
             }
 ```
 
 ```   
    // MARK:
    // MARK: Action
        
    // TODO: STEP 4
   @IBAction
   func makeCall() {
       guard let number = textfield.text else { return }
        
       ConversationClient.instance.media.callPhone(number, onSuccess: { result in
           self.call = result.call
            
            print("DEMO - Created call")
        }) { error in
            print("DEMO - Failed to make call: \(error)")
        }
     }  
 ``` 


```
   // TODO: STEP 5
     @IBAction
     func hangup() {
         call?.hangUp(onSuccess: {
             print("DEMO - Hangup call successful")
         })
     }
```

# Try it out! 

After you've followed along with this quickstart, you will be able to make a call to a PSTN phone. Don't forget to include the country code when you make a call! For example if you're calling a phone number in the USA, the phone number will need to begin with a 1. When calling a phone number in Great Britain the phone number will need to be prefixed with 44.

## Where next?
 
You can view the source code for this [quickstart on GitHub]()