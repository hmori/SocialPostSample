//
//  SPViewController.m
//  SocialPostSample
//
//  Created by Hidetoshi Mori on 12/10/04.
//  Copyright (c) 2012年 Hidetoshi Mori. All rights reserved.
//

#import "SPViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface SPViewController ()
@property (weak, nonatomic) IBOutlet UITextView *accountTextView;
- (IBAction)showAccounts:(UIButton *)sender;
- (IBAction)twitterButtonAction:(UIButton *)sender;
- (IBAction)facebookButtonAction:(UIButton *)sender;
- (IBAction)weiboButtonAction:(UIButton *)sender;
- (IBAction)twitterRequestButtonAction:(UIButton *)sender;
- (IBAction)facebookRequestButtonAction:(UIButton *)sender;
- (IBAction)weiboRequestButtonAction:(UIButton *)sender;
- (void)checkAccounts;
- (void)addAccountText:(NSString *)text;
- (void)compose:(NSString *)serviceType;
@end

@implementation SPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIButton actions

- (IBAction)showAccounts:(UIButton *)sender {
    [self checkAccounts];
}

- (IBAction)twitterButtonAction:(UIButton *)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        [self compose:SLServiceTypeTwitter];
    }
}

- (IBAction)facebookButtonAction:(UIButton *)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        [self compose:SLServiceTypeFacebook];
    }
}

- (IBAction)weiboButtonAction:(UIButton *)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
        [self compose:SLServiceTypeSinaWeibo];
    }
}

- (IBAction)twitterRequestButtonAction:(UIButton *)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore
         requestAccessToAccountsWithType:accountType
         options:nil
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
                 if (accountArray.count > 0) {
                     NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
                     NSDictionary *params = [NSDictionary dictionaryWithObject:@"SLRequest post test." forKey:@"status"];
                     
                     SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                             requestMethod:SLRequestMethodPOST
                                                                       URL:url
                                                                parameters:params];
                     [request setAccount:[accountArray objectAtIndex:0]];
                     [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                         NSLog(@"responseData=%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                     }];
                 }
             }
         }];
    }
}

- (IBAction)facebookRequestButtonAction:(UIButton *)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"276821738996235", ACFacebookAppIdKey,
                                 [NSArray arrayWithObjects:@"public_actions", @"publish_stream", @"offline_access", nil], ACFacebookPermissionsKey,
                                 ACFacebookAudienceOnlyMe, ACFacebookAudienceKey,
                                 nil];
        [accountStore
         requestAccessToAccountsWithType:accountType
         options:options
         completion:^(BOOL granted, NSError *error) {
             NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
             for (ACAccount *account in accountArray) {
                 
                 NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/feed", [[account valueForKey:@"properties"] valueForKey:@"uid"]] ;
                 NSURL *url = [NSURL URLWithString:urlString];
                 NSDictionary *params = [NSDictionary dictionaryWithObject:@"SLRequest post test." forKey:@"message"];
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                         requestMethod:SLRequestMethodPOST
                                                                   URL:url
                                                            parameters:params];
                 [request setAccount:account];
                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                     NSLog(@"responseData=%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                 }];
             }
         }];
    }
}

- (IBAction)weiboRequestButtonAction:(UIButton *)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
        [accountStore
         requestAccessToAccountsWithType:accountType
         options:nil
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
                 if (accountArray.count > 0) {
                     NSURL *url = [NSURL URLWithString:@"https://api.weibo.com/2/statuses/update.json"];
                     NSDictionary *params = [NSDictionary dictionaryWithObject:@"SLRequest post test." forKey:@"status"];
                     SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo
                                                             requestMethod:SLRequestMethodPOST
                                                                       URL:url
                                                                parameters:params];
                     [request setAccount:[accountArray objectAtIndex:0]];
                     [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                         NSLog(@"responseData=%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                     }];
                 }
             }
         }];
    }
}


#pragma mark - Private methods

- (void)checkAccounts {
    __block __weak SPViewController *weakSelf = self;
    ACAccountType *accountType;
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore
         requestAccessToAccountsWithType:accountType
         options:nil
         completion:^(BOOL granted, NSError *error) {
             NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
             for (ACAccount *account in accountArray) {
                 NSString *text = [NSString stringWithFormat:@"\nTwitter:%@", [account description]];
                 [weakSelf performSelectorOnMainThread:@selector(addAccountText:)
                                            withObject:text
                                         waitUntilDone:YES];
             }
         }];
    }
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"276821738996235", ACFacebookAppIdKey,
                                 [NSArray arrayWithObjects:@"public_actions", @"publish_stream", @"offline_access", nil], ACFacebookPermissionsKey,
                                 ACFacebookAudienceFriends, ACFacebookAudienceKey,
                                 nil];
        [accountStore
         requestAccessToAccountsWithType:accountType
         options:options
         completion:^(BOOL granted, NSError *error) {
             NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
             for (ACAccount *account in accountArray) {
                 NSString *text = [NSString stringWithFormat:@"\nFacebook:%@", [account description]];
                 [weakSelf performSelectorOnMainThread:@selector(addAccountText:)
                                            withObject:text
                                         waitUntilDone:YES];
             }
         }];
    }
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
        accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
        [accountStore
         requestAccessToAccountsWithType:accountType
         options:nil
         completion:^(BOOL granted, NSError *error) {
             NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
             for (ACAccount *account in accountArray) {
                 NSString *text = [NSString stringWithFormat:@"\nWeibo:%@", [account description]];
                 [weakSelf performSelectorOnMainThread:@selector(addAccountText:)
                                            withObject:text
                                         waitUntilDone:YES];
             }
         }];
    }
}

- (void)addAccountText:(NSString *)text {
    NSString *string = [NSString stringWithFormat:@"%@\n%@", self.accountTextView.text, text];
    [self.accountTextView setText:string];
}


- (void)compose:(NSString *)serviceType {
    SLComposeViewController *composeCtl = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    
    [composeCtl setInitialText:@"Post Test from iOS6."];
    [composeCtl addURL:[NSURL URLWithString:@"http://d.hatena.ne.jp/h_mori/"]];
    [composeCtl setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString *message = nil;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                message = @"Cancelled !";
                break;
            case SLComposeViewControllerResultDone:
                message = @"Success !";
                break;
            default:
                break;
        }
        [[[UIAlertView alloc] initWithTitle:@"Post test"
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil] show];
    }];
    
    [self presentViewController:composeCtl animated:YES completion:nil];
}

@end
