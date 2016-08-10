//
//  TYMailSender.m
//  BackgroundMailTransfer
//
//  Created by Thabresh on 8/10/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import "TYMailSender.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import "SVProgressHUD.h"

@interface TYMailSender ()<SKPSMTPMessageDelegate>

@end

@implementation TYMailSender

- (void)viewDidLoad {
    [super viewDidLoad];
    self.txtBody.layer.cornerRadius = 10.0f;
    self.txtBody.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.txtBody.layer.borderWidth = 1.0f;
    self.txtBody.text = @"Enter your message";
    self.txtBody.textColor = [UIColor lightGrayColor];
    self.btnSend.layer.cornerRadius = 10.0f;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //fff
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Enter your message"]) {
        self.txtBody.text = @"";
        self.txtBody.textColor = [UIColor blackColor];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Enter your message"] || textView.text.length == 0) {
        self.txtBody.text = @"Enter your message";
        self.txtBody.textColor = [UIColor lightGrayColor];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)clickSend:(id)sender {
    if ([self CheckValidation]) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
        {
            [self ShowAlert:[NSString stringWithFormat:@"Please give the access %@ to turned on",self.txtFrom.text]];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [SVProgressHUD show];
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
        [SVProgressHUD setBackgroundLayerColor:[UIColor clearColor]];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        SKPSMTPMessage *emailMessage = [[SKPSMTPMessage alloc] init];
        emailMessage.fromEmail = self.txtFrom.text; //sender email address
        emailMessage.toEmail =self.txtTo.text;  //receiver email address
        emailMessage.relayHost = @"smtp.gmail.com";
        //emailMessage.ccEmail =@"your cc address";
        //emailMessage.bccEmail =@"your bcc address";
        emailMessage.requiresAuth = YES;
        emailMessage.login = self.txtFrom.text; //sender email address
        emailMessage.pass = self.txtPassword.text; //sender email password
        emailMessage.subject =self.txtSubject.text;
        emailMessage.wantsSecure = YES;
        emailMessage.delegate = self; // you must include <SKPSMTPMessageDelegate> to your class
        NSString *messageBody = self.txtBody.text;
        //for example :   NSString *messageBody = [NSString stringWithFormat:@"Tour Name: %@\nName: %@\nEmail: %@\nContact No: %@\nAddress: %@\nNote: %@",selectedTour,nameField.text,emailField.text,foneField.text,addField.text,txtView.text];
        // Now creating plain text email message
        NSDictionary *plainMsg = [NSDictionary
                                  dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                                  messageBody,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
        emailMessage.parts = [NSArray arrayWithObjects:plainMsg,nil];
        //in addition : Logic for attaching file with email message.
        
        if (chosenImage) {
            NSData *fileData = UIImagePNGRepresentation(chosenImage);
            NSDictionary *fileMsg = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"filename.JPG\"",kSKPSMTPPartContentTypeKey,@"attachment;\r\n\tfilename=\"filename.JPG\"",kSKPSMTPPartContentDispositionKey,[fileData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
            emailMessage.parts = [NSArray arrayWithObjects:plainMsg,fileMsg,nil]; //including plain msg and attached file msg
        }
        [emailMessage send];
    }
}
- (IBAction)ClickAttachemnt:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}
-(BOOL)CheckValidation
{
    if (self.txtFrom.text.length == 0 || self.txtBody.text.length == 0 || self.txtTo.text.length == 0 || self.txtSubject.text.length == 0 || [self.txtBody.text isEqualToString:@"Enter your message"]) {      
        [self ShowAlert:@"Please give the required fields"];
        return false;
    }
    return true;
}
-(void)messageSent:(SKPSMTPMessage *)message{
    [SVProgressHUD dismiss];
    [self ShowAlert:@"Message sent."];
    self.txtSubject.text = nil;
    self.txtBody.text = nil;
    self.txtPassword.text = nil;
    self.txtFrom.text = nil;
    self.txtTo.text = nil;
    chosenImage = nil;
}
// On Failure
-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error{
       [SVProgressHUD dismiss];
    // open an alert with just an OK button
    NSLog(@"delegate - error(%ld): %@", (long)[error code], [error localizedDescription]);
    [self ShowAlert:[error localizedDescription]];
}
-(void)ShowAlert:(NSString*)TitleTxt
{
    [[[UIAlertView alloc] initWithTitle:TitleTxt message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
}
@end
