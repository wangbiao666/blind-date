//
//  EditViewController.m
//  BlindDate
//
//  Created by wangbiao on 16/3/28.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "EditViewController.h"
#import "UserInfo.h"
#import "ConversionHelper.h"
#import "UIHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "VerifyHelper.h"
#import "User.h"
#import "URLMacro.h"
#import "UtilsMacro.h"
#import "AFNetworkingHelper.h"

@interface EditViewController () <UITextViewDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *headImage;
@property (nonatomic, strong) UserInfo *object;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *fields;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _textView.textContainerInset = UIEdgeInsetsMake(0, -4, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

- (void)viewControllerDidShowWithTag:(NSString *)tag data:(NSObject *)data {
    //
    NSDictionary *entries = (NSDictionary *)data;
    self.object = entries[@"object"];
    _imageView.image = entries[@"head"];
    
    //
    [self reload:_object];
}

- (IBAction)headTapped {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    //
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction *action) {
                                                             [self openCamera];
                                                         }];
    [sheet addAction:cameraAction];
    
    //
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从相册选择"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            [self openPhotoLibrary];
                                                        }];
    [sheet addAction:photoAction];
    
    //
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [sheet addAction:cancelAction];
    
    //
    [self presentViewController:sheet animated:YES completion:nil];
}

- (IBAction)saveButtonPressed {
    NSString *text = [_fields[0] text];
    if ([VerifyHelper isEmptyString:text]) {
        [UIHelper showTipsWithText:@"昵称不能为空" inView:self.view];
        return;
    }
    
    [UIHelper showLoadingInView:self.view];
    
    if (_headImage != nil) {
        //
        User *user = [User currentUser];
        NSString *filename = [NSString stringWithFormat:@"%@.jpg", user.username];
        NSString *urlString = [NSString stringWithFormat:@"%@%@", kURLTypeFileUploadPrefix, filename];
        NSData *data = UIImageJPEGRepresentation(_headImage, 1.0);
        
        AFNetworkingHelper *helper = [AFNetworkingHelper defaultHelper];
        [helper uploadWithURLString:urlString data:data success:^(NSURLResponse *response, id object) {
            NSString *photo = object[@"url"];
            if (photo != nil) {
                NSString *urlString = [kURLTypeFileDownloadPrefix stringByAppendingString:photo];
                [self commitWithPhotoURLString:urlString];
            } else {
                [self commitWithPhotoURLString:nil];
            }
        } failure:^(NSURLResponse *response, NSError *error) {
            [UIHelper dismissLoadingInView:self.view];
            [UIHelper showErrorWithText:@"网络异常，请稍候重试" inView:self.view];
        }];
    } else {
        [self commitWithPhotoURLString:nil];
    }
}

- (IBAction)textFieldDidEndOnExit:(UITextField *)field {
    NSInteger index = [_fields indexOfObject:field];
    if (index < _fields.count - 1) {
        UITextField *nextField = _fields[index + 1];
        [nextField becomeFirstResponder];
    } else {
        [_textView becomeFirstResponder];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *type = info[UIImagePickerControllerMediaType];
    if ([type isEqual:(NSString *)kUTTypeImage]) {
        UIImage *editedImage = info[UIImagePickerControllerEditedImage];
        self.headImage = [self shrinkImage:editedImage size:CGSizeMake(100, 100)];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if (_headImage != nil) {
            _imageView.image = _headImage;
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)registerNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:)
                   name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)sender {
    NSDictionary *info = sender.userInfo;
    CGRect bounds = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIView *inputField = [self firstResponder];
    CGRect rect = [inputField convertRect:inputField.bounds toView:_scrollView];
    rect.origin.y += 8;
    
    void(^animations)(void) = ^{
        //
        UIEdgeInsets insets = _scrollView.contentInset;
        insets.bottom = bounds.size.height;
        _scrollView.contentInset = insets;
        
        //
        [_scrollView scrollRectToVisible:rect animated:NO];
    };
    
    if (duration > 0) {
        NSInteger value = [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        UIViewAnimationOptions options = (value << 16);
        [UIView animateWithDuration:duration delay:0 options:options
                         animations:animations completion:nil];
    } else {
        animations();
    }
}

- (void)keyboardWillHide:(NSNotification *)sender {
    NSDictionary *info = sender.userInfo;
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    void(^animations)(void) = ^{
        //
        UIEdgeInsets insets = _scrollView.contentInset;
        insets.bottom = 0;
        _scrollView.contentInset = insets;
        
        //
        _scrollView.contentOffset = CGPointMake(0, 0);
    };
    
    if (duration > 0) {
        NSInteger value = [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        UIViewAnimationOptions options = (value << 16);
        [UIView animateWithDuration:duration delay:0 options:options
                         animations:animations completion:nil];
    } else {
        animations();
    }
}

- (void)reload:(UserInfo *)object {
    NSString *nickname = [ConversionHelper stringWithString:object.nickname defaultValue:@""];
    NSString *sex = [ConversionHelper stringWithString:object.sex defaultValue:@""];
    NSString *record = [ConversionHelper stringWithString:object.record defaultValue:@""];
    NSString *marital = [ConversionHelper stringWithString:object.marital defaultValue:@""];
    NSString *address = [ConversionHelper stringWithString:object.address defaultValue:@""];
    NSString *contact = [ConversionHelper stringWithString:object.contact defaultValue:@""];
    NSString *introduce = [ConversionHelper stringWithString:object.introduce defaultValue:@""];
    
    [_fields[0] setText:nickname];
    [_fields[1] setText:sex];
    [_fields[2] setText:record];
    [_fields[3] setText:object.salary];
    [_fields[4] setText:object.age];
    [_fields[5] setText:object.height];
    [_fields[6] setText:marital];
    [_fields[7] setText:address];
    [_fields[8] setText:contact];
    [_textView setText:introduce];
}

- (UIView *)firstResponder {
    if ([_textView isFirstResponder]) {
        return _textView;
    } else {
        for (UITextField *field in _fields) {
            if ([field isFirstResponder]) {
                return field;
            }
        }
    }
    return nil;
}

- (void)openCamera {
    [self getMediaFromSourceWithType:UIImagePickerControllerSourceTypeCamera];
}

- (void)openPhotoLibrary {
    [self getMediaFromSourceWithType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)getMediaFromSourceWithType:(UIImagePickerControllerSourceType)type {
    NSArray *types = [UIImagePickerController availableMediaTypesForSourceType:type];
    if ([UIImagePickerController isSourceTypeAvailable:type] && types.count > 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = types;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = type;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        NSString *text;
        
        if (type == UIImagePickerControllerSourceTypeCamera) {
            text = @"拍照功能不可用";
        } else {
            text = @"相册不可以访问";
        }
        
        [UIHelper showTipsWithText:text inView:self.view];
    }
}

- (UIImage *)shrinkImage:(UIImage *)original size:(CGSize)size {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    uint32_t info = kCGImageAlphaPremultipliedFirst;
    
    CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, info);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(context, rect, original.CGImage);
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    UIImage *finalImage = [UIImage imageWithCGImage:shrunken];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(shrunken);
    
    return finalImage;
}

- (void)commitWithPhotoURLString:(NSString *)urlString {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (urlString != nil) {
        params[@"photo"] = urlString;
    }
    
    params[@"objectId"] = _object.objectId;
    params[@"nickname"] = [_fields[0] text];
    params[@"sex"] = [_fields[1] text];
    params[@"record"] = [_fields[2] text];
    
    int number = [[_fields[3] text] intValue];
    if (number > 0) {
        params[@"salary"] = [NSNumber numberWithInt:number];
    }
    
    number = [[_fields[4] text] intValue];
    if (number > 0) {
        params[@"age"] = [NSNumber numberWithInt:number];
    }
    
    number = [[_fields[5] text] intValue];
    if (number > 0) {
        params[@"height"] = [NSNumber numberWithInt:number];
    }
    
    params[@"marital"] = [_fields[6] text];
    params[@"address"] = [_fields[7] text];
    params[@"contact"] = [_fields[8] text];
    params[@"introduce"] = [_textView text];
    
    AFNetworkingHelper *helper = [AFNetworkingHelper defaultHelper];
    [helper sendRequestWithURLString:kURLTypePublish parameters:params
                             success:^(NSURLSessionDataTask *task, NSDictionary *response) {
                                 [UIHelper dismissLoadingInView:self.view];
                                 NSInteger code = [response[@"code"] integerValue];
                                 if (code == 200) {
                                     //
                                     NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                                     [center postNotificationName:kNofiticationTypeReset object:nil];
                                     
                                     //
                                     NSDictionary *data = @{@"isMe": @YES, @"objectId": _object.objectId};
                                     [self.navigationController popViewControllerAnimated:YES data:data];
                                 } else {
                                     [UIHelper showErrorWithText:response[@"msg"] inView:self.view];
                                 }
                             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 [UIHelper dismissLoadingInView:self.view];
                                 [UIHelper showErrorWithText:@"网络异常，请稍候重试" inView:self.view];
                             }];
}

@end
