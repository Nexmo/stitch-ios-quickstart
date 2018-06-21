//
//  LoginVC.m
//  inviting-members-objc
//
//  Created by Eric Giannini on 6/18/18.
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
    
    NSLog(@"DEMO - login button pressed.");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                                                                   message:@"This is an alert."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    __weak LoginVC *weakSelf = self;
    
    UIAlertAction *user1Action = [UIAlertAction actionWithTitle:NSLocalizedString(@"jamie", comment: @"First User")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            
                                                            NSLog(@"The \"First User\" is here!");
                                                            
                                                            NSString *token = @"Replace me with first user token.";
                                                            
                                                            [weakSelf loginUserWithToken:token];
                                                        }];
    
    UIAlertAction *user2Action = [UIAlertAction actionWithTitle:NSLocalizedString(@"alice", comment: @"Second User")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            
                                                            NSLog(@"The \"Second User\" is here!");
                                                            
                                                            NSString *token = @"Replace me with second user token.";
                                                            
                                                            [weakSelf loginUserWithToken:token];
                                                        }];
    
    [alert addAction:user1Action];
    [alert addAction:user2Action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)chatBtn:(id)sender {
    
    NSString *aConversation = @"aConversation";
    
    __weak LoginVC *weakSelf = self;
    
    [[client conversation] newWith: aConversation shouldJoin: YES :^(NXMConversation * success) {
        //Nothing to do
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
        //Nothing to do
    }];
    
    [self performSegueWithIdentifier:@"chatView" sender: nil];
}

- (void)loginUserWithToken:(NSString *)token {
    
    [self.client loginWith:token :^(enum NXMLoginResult result) {
        
        switch (result) {
                
            case NXMLoginResultSuccess:
                
                NXMUser *user = weakSelf.client.account.user;
                
                if (user != nil) {
                    NSLog(@"DEMO - login successful and here is our %@", user);
                    
                    // whenver the conversations array is modified
                    //Missing Part
                    //                    [self.client.conversation ];
                    
                    
                    NSMutableArray *joinedConversations = [NSMutableArray new] ;
                    
                    // figure out which conversation a member has joined
                    for (NXMConversation *conversation in [self.client.conversation.conversations conversationsObjc]) {
                        
                        for (NXMMember *member in [[conversation members] membersObjc]) {
                            
                            if (member.user.isMe == YES) { //&& ([member state] == JOINED)) //Missing Part
                                
                                [joinedConversations addObject:conversation];
                            }
                        }
                    }
                    
                    for (NXMConversation *conversation in joinedConversations) {
                        return NSLog(@"UUID: %@", conversation.uuid);
                    }
                }
                
            default:
                
                self.statusLbl.hidden = NO;
                
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    ChatVC *chatVC = segue.destinationViewController;
    chatVC.conversation = client.conversation.conversations.conversationsObjc.firstObject;
    //    NXMConversationCollection *conversations = client.conversation.conversations;
    //    chatVC.conversation = [conversations indexWithSafe: conversations.startIndex];
}


@end
