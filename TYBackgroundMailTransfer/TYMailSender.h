//
//  TYMailSender.h
//  BackgroundMailTransfer
//
//  Created by Thabresh on 8/10/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYMailSender : UITableViewController<UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImage *chosenImage;
}
@property (weak, nonatomic) IBOutlet UITextField *txtFrom;
@property (weak, nonatomic) IBOutlet UITextField *txtTo;
@property (weak, nonatomic) IBOutlet UITextField *txtSubject;
@property (weak, nonatomic) IBOutlet UITextView *txtBody;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@end
