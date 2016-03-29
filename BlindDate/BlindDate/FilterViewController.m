//
//  FilterViewController.m
//  BlindDate
//
//  Created by wangbiao on 16/3/29.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "FilterViewController.h"
#import "VerifyHelper.h"
#import "UIViewController+Base.h"

@interface FilterViewController ()

@property (nonatomic, weak) IBOutlet UITextField *sexField;
@property (nonatomic, weak) IBOutlet UITextField *recordField;
@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *ageFields;
@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *heightFields;
@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *salaryFields;
@property (nonatomic, weak) IBOutlet UIView *container;

@end

@implementation FilterViewController

- (void)viewControllerDidShowWithTag:(NSString *)tag data:(NSObject *)data {
    NSDictionary *entries = (NSDictionary *)data;
    [self resetWithData:entries];
}

- (IBAction)okButtonPressed {
    //
    [self.view endEditing:YES];
    
    //
    NSDictionary *data = [self dataFromFields];
    [self.navigationController popViewControllerAnimated:YES data:data];
}

- (IBAction)clearButtonPressed {
    //
    NSArray *subviews = _container.subviews;
    for (UIView *view in subviews) {
        if ([view isKindOfClass:UITextField.class]) {
            UITextField *field = (UITextField *)view;
            field.text = @"";
        }
    }
    
    //
    [self.view endEditing:YES];
}

- (IBAction)textFieldDidEndOnExit:(UITextField *)sender {
    [sender resignFirstResponder];
}

#pragma mark - Private

- (void)resetWithData:(NSDictionary *)data {
    NSString *text = data[@"sex"];
    if (![VerifyHelper isEmptyString:text]) {
        _sexField.text = text;
    }
    
    text = data[@"record"];
    if (![VerifyHelper isEmptyString:text]) {
        _recordField.text = text;
    }
    
    NSNumber *number = data[@"minAge"];
    if (number != nil) {
        [_ageFields[0] setText:[number stringValue]];
    }
    number = data[@"maxAge"];
    if (number != nil) {
        [_ageFields[1] setText:[number stringValue]];
    }
    
    number = data[@"minHeight"];
    if (number != nil) {
        [_heightFields[0] setText:[number stringValue]];
    }
    number = data[@"maxHeight"];
    if (number != nil) {
        [_heightFields[1] setText:[number stringValue]];
    }
    
    number = data[@"minSalary"];
    if (number != nil) {
        [_salaryFields[0] setText:[number stringValue]];
    }
    number = data[@"maxSalary"];
    if (number != nil) {
        [_salaryFields[1] setText:[number stringValue]];
    }
}

- (NSDictionary *)dataFromFields {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    NSString *text = [_sexField text];
    if (![VerifyHelper isEmptyString:text]) {
        if ([text isEqualToString:@"男"] || [text isEqualToString:@"女"]) {
            data[@"sex"] = text;
        }
    }
    
    text = [_recordField text];
    if (![VerifyHelper isEmptyString:text]) {
        data[@"record"] = text;
    }
    
    text = [_ageFields[0] text];
    if (![VerifyHelper isEmptyString:text]) {
        NSInteger number = [text integerValue];
        if (number > 0) {
            data[@"minAge"] = [NSNumber numberWithInteger:number];
        }
    }
    text = [_ageFields[1] text];
    if (![VerifyHelper isEmptyString:text]) {
        NSInteger number = [text integerValue];
        if (number > 0) {
            data[@"maxAge"] = [NSNumber numberWithInteger:number];
        }
    }
    
    text = [_heightFields[0] text];
    if (![VerifyHelper isEmptyString:text]) {
        NSInteger number = [text integerValue];
        if (number > 0) {
            data[@"minHeight"] = [NSNumber numberWithInteger:number];
        }
    }
    text = [_heightFields[1] text];
    if (![VerifyHelper isEmptyString:text]) {
        NSInteger number = [text integerValue];
        if (number > 0) {
            data[@"maxHeight"] = [NSNumber numberWithInteger:number];
        }
    }
    
    text = [_salaryFields[0] text];
    if (![VerifyHelper isEmptyString:text]) {
        NSInteger number = [text integerValue];
        if (number > 0) {
            data[@"minSalary"] = [NSNumber numberWithInteger:number];
        }
    }
    text = [_salaryFields[1] text];
    if (![VerifyHelper isEmptyString:text]) {
        NSInteger number = [text integerValue];
        if (number > 0) {
            data[@"maxSalary"] = [NSNumber numberWithInteger:number];
        }
    }
    
    return data;
}

@end
