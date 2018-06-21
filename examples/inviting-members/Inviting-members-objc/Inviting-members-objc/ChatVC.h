//
//  ChatVC.h
//  inviting-members-objc
//
//  Created by Eric Giannini on 6/18/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Stitch;

@interface ChatVC : UIViewController

@property (retain, nonatomic) NXMConversation *conversation;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UITextField *textField;


@end

