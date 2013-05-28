//
//  ViewController.h
//  Note
//
//  Created by Yu Yichen on 5/23/13.
//  Copyright (c) 2013 Yu Yichen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>


@interface ViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
- (IBAction)resign:(UIBarButtonItem *)sender;
@property (weak, nonatomic,readwrite) IBOutlet UITextView *textField;
- (IBAction)linkButton:(UIBarButtonItem *)sender;

@property (weak, nonatomic,readwrite) IBOutlet UIView *helperView;

- (IBAction)save:(UIButton *)sender;
- (IBAction)photo:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property EKEventStore *eventStore;
@property UIWindow *window;


@end
