# Nexmo In-App Call States 

In this quick start we are going to explain call statuses for _outgoing calls_ like 
 started, ringing, answered, rejected, busy, unanswered, timeout, failed, complete, machine. Since everyone is familiar with the phone, these concepts are pretty straightforward. We won't waste anytime explaining them but we will briefly mention what they signify. After explaining what they signify we  will cover how to subscribe to changes in state in an app that has implemented that Nexmo In-App Calling features with its iOS SDK. 🙌

# What do the call states signify?

Every Nexmo In-App call has a status value that signifies the current state of a call. Since call status is subject to change in real time, there must be a way to track these changes. Nexmo In-App Calling States help us keep track of these changes! 🎉 🎉 🎉 And there a lot of states! 

### States

Here is a handy dandy table with a brief list of all states: 

- **started** : Platform has initiated the call
- **ringing** : Caller has joined and pending for at least one more to join
- **answered** : The user has answered your call
- **rejected** : The call was rejected
- **busy**: Caller is busy
- **unanswered**: The call was canceled from the called before an answer
- **timeout**: User did not answer your call with ringing_timer seconds
- **failed**: The call failed to complete
- **complete**: Platform has terminated this call after the call was successfully answered
- **machine**: Platform detected an answering machine

These states are valid for all 1:1 cal combinations such as (IP-IP, IP - PSTN, PSTN - IP, etc...). Since these states are straightforward let's demonstrate how to subscribe to changes in state in an iOS app. 

## 1.0 Setting up the iOS app 

In order to subscribe to call events, our app will need to be able to make out outgoing calls. We will subscribe to changes in the state of the outgoing call in the usual way. We will 

## 2.0 Subscribing to a State Changes & Retrieval

The first step is to import the Stitch iOS SDK. 

```Swift 
import Stitch
``` 

The second step is to empty initialize a private instance of the `call` object so that we can use it later to set up a call. 

``` 
private var call: Call()
``` 

The third step is to subscribe to the call states on the `call` object.


```Swift 
call.memberState.subscribe { state in }
``` 

The fifth step is to program the User Interface to execute code after a change of state is logged.

 ```Swift
call.memberState.subscribe { state in
	switch state {
		case .ringing(let member):
		    break
		case .answered(let member):
		    break
		case .rejected(let member):
		    break
		case .hangUp(let member):
		    break
		}
	}
```

## Try it out 

You should be able to log various changes of state after making a call so that you can execute dynamic views in the the UI of your apps with Nexmo In-App Phone Calling. 

## Disclaimer 

While Nexmo, the Vonage API Platform strives to provide the best possible access how so ever it may be, we little to no control over assuring the accuracy of the changes in state, all of which depend in the largest part upon the carriers themselves, mostly separate legal entities with whom we share a business interest. More specifically, a state change may indeed be busy but is relayed as rejected. Accordingly, Nexmo, the Vonage API Platform disclaims any liablity to or for inaccurate or inacurrately conveyed states. 