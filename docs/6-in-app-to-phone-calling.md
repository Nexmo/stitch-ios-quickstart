# Nexmo In-App to Phone Calling!

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