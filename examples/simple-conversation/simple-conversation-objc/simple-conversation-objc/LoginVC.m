//
//  LoginVC.m
//  simple-conversation-objc
//
//  Created by Eric Giannini on 6/13/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

#import "LoginVC.h"
#import "ChatVC.h"


@interface LoginVC ()

@end

@implementation LoginVC

@synthesize client;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    client = [NXMConversationClient instance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    ChatVC *chatVC = segue.destinationViewController;
    chatVC.conversation = client.conversation.conversations.conversationsObjc.firstObject;
    //    NXMConversationCollection *conversations = client.conversation.conversations;
    //    chatVC.conversation = [conversations indexWithSafe: conversations.startIndex];
}


@end

