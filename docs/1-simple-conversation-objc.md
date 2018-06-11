# Getting Started with the Nexmo Stitch iOS SDK in Objective-C

In this getting started guide we'll demonstrate how to build a simple conversation app with IP messaging using the Nexmo Stitch iOS SDK.

## Concepts & Setup 

Please see the Swift [guide](https://developer.nexmo.com/stitch/in-app-messaging/guides/1-simple-conversation) for an introduction to concepts and setting up a JSON web token for the Nexmo dashboard. 

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

## Accessing a Swift Class in Objective-C

The next step is to import the header "Stitch-Swift.h" in the implementation file `.m` of the class where you would like to access a Swift class in Objective-C. 

The final step in accessibility is making sure to cast the top-level Swift class as an object in Objective-C. There are two ways: 

1. To declare the class with `@objc` as in: `@objc public class myStitchClass`.
2. Or to declare the Swift class as a subclass of NSObject as in: `public class myStitchClass: NSObject {}`. 

##  Integrating Nexmo In-App Messaging

With Stitch Swift classes both available and accessible, the next step is to integrate Stitch features into the Objective-C app. 

## Try it out
After this you should be able to run the app and send messages.



 