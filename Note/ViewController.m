//
//  ViewController.m
//  Note
//
//  Created by Yu Yichen on 5/23/13.
//  Copyright (c) 2013 Yu Yichen. All rights reserved.
//

#import "ViewController.h"
#import <dropbox/dropbox.h>
#import <EventKit/EventKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>



@interface ViewController ()

@end

@implementation ViewController
@synthesize textField;
@synthesize helperView;
@synthesize imageView;
@synthesize eventStore;
@synthesize window;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    self.textField.inputAccessoryView = self.helperView;
    eventStore=[[EKEventStore alloc]init];
    [eventStore requestAccessToEntityType:EKEntityTypeReminder
                               completion:^(BOOL granted, NSError *error) {
                                   if (!granted)
                                       NSLog(@"Access to store not granted");
                               }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resign:(UIBarButtonItem *)sender {
    
    [self.textField resignFirstResponder];
}



- (void)keyboardWillShow:(NSNotification *)notif
{
    [self.textField setFrame:CGRectMake(5, 5, 310, 240)]; //Or where ever you want the view to go
  
    
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    [self.textField setFrame:CGRectMake(5, 5, 310, 430)]; //return it to its original position
   
}


- (IBAction)linkButton:(UIBarButtonItem *)sender {


        [[DBAccountManager sharedManager] linkFromController:self];
        
}


- (IBAction)save:(UIButton *)sender {
    [self.textField resignFirstResponder];
    
    NSDate *date=[NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSString *formattedDateString = [dateFormatter stringFromDate: date];
    NSString *content=self.textField.text;
    
    if ([content length]>5&&[[content substringWithRange:NSMakeRange(0,5)] isEqualToString:@"TODO:"])

        
    {  EKReminder *reminder = [EKReminder reminderWithEventStore:eventStore];
        
        reminder.title = [content substringFromIndex:5];
        
        reminder.calendar = [eventStore defaultCalendarForNewReminders];
        
        NSError *error = nil;
        
        [eventStore saveReminder:reminder commit:YES error:&error];}
    
    if (self.imageView.image==nil)
    {  NSString *fileNametxt=[NSString stringWithFormat:@"%@%@",formattedDateString,@".txt"];
        DBPath *newPath = [[DBPath root] childPath:fileNametxt];
        
        DBFile *filetxt = [[DBFilesystem sharedFilesystem] createFile:newPath error:nil];
        
        [filetxt writeString:content error:nil];
        
    }
    else
    {
    NSString *fileName=[NSString stringWithFormat:@"%@%@",formattedDateString,@".jpeg"];
    DBPath *newPath = [[DBPath root] childPath:fileName];
   
    DBFile *file = [[DBFilesystem sharedFilesystem] createFile:newPath error:nil];
    
     UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
     UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();

    CGRect myImageArea = CGRectMake(5, 70, 310, 425);
    CGImageRef imageRef = CGImageCreateWithImageInRect([viewImage CGImage], myImageArea);
    UIImage *imageInFrame = [UIImage imageWithCGImage:imageRef];
    
    

    NSData *photoData=UIImageJPEGRepresentation(imageInFrame, 0.8);
//    [file writeData:photoData error:nil];
    
    
    
    
    CGImageSourceRef  source;
    source = CGImageSourceCreateWithData( (__bridge CFDataRef)photoData, NULL);
        NSDictionary *metadata = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
        NSMutableDictionary *metadataAsMutable=[metadata mutableCopy];
        NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
        if(!EXIFDictionary) {
            //if the image does not have an exif dictionary (not all images do), then create one for us to use
            EXIFDictionary = [NSMutableDictionary dictionary];
            NSLog(@"creating exif property dictionary");
        }
        
    [EXIFDictionary setValue:self.textField.text forKey:(NSString *)kCGImagePropertyExifUserComment];
    
        
    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    CFStringRef UTI = CGImageSourceGetType(source);
    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
    CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metadataAsMutable);
    CGImageDestinationFinalize(destination);
               

//        [dest_data writeToFile:file atomically:YES];
        [file writeData:dest_data error:nil];
        
        
        NSLog(@"checking image metadata on clipboard");
        
        
        
        CGImageSourceRef sourceToCheck = CGImageSourceCreateWithData((__bridge CFDataRef)dest_data, NULL);
        NSDictionary *metadataToCheck = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(sourceToCheck,0,NULL);
        
        NSLog(@"%@", metadataToCheck);
    }
    self.textField.text=nil;
    self.imageView.image=nil;
    
   
       
        
     
    
}

- (IBAction)photo:(UIButton *)sender {
    UIImagePickerController *picker=[[UIImagePickerController alloc]init];
    picker.delegate=self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
  
    
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    imageView.image=image;
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}





@end
