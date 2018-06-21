//
//  ChatVC.m
//  inviting-members-objc
//
//  Created by Eric Giannini on 6/18/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

#import "ChatVC.h"

@interface ChatVC ()

@end

@implementation ChatVC

@synthesize conversation;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NXMEventCollection *events = [conversation events];
    
    NXMEventBase *baseEvent = [events indexWithSafe:[events startIndex]];
    
    [baseEvent isCurrentlyBeingSent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendBtn:(id)sender {
    
    NSString *text = _textField.text ;
    
    if (text.length > 0) {
        [conversation sendText: text error: NULL];
    }
}

@end

