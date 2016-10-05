//
//  TestServiceViewController.m
//  APIServiceAgent
//
//  Created by Tung Duong Thanh on 8/8/16.
//  Copyright © 2016 GEM. All rights reserved.
//

#import "TestServiceViewController.h"
#import "GEMServiceAPIAgent.h"

@interface TestServiceViewController ()

@property (nonatomic, weak) IBOutlet UITextField *textField;
- (IBAction)done:(id)sender;

@end

@implementation TestServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.text = @"57a83bb0110000bd0f1d44d4";
    
    [self done:self.textField];
}

- (void)done:(id)sender {
    [self.view endEditing:YES];
    
    NSMutableURLRequest *request = [GEMServiceAPIAgent getUnauthorizedRequestWithPath:self.textField.text params:nil error:nil];
    [GEMServiceAPIAgent startRequest:request expectedResponseClass:[NSDictionary class] completion:^(id response, NSError *error) {        
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            NSString *message = [NSString stringWithFormat:@"%@", response];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Response" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

@end
