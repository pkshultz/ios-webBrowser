//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Peter Shultz on 11/16/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import "BLCWebBrowserViewController.h"
#import "BLCAwesomeFloatingToolbar.h"

#define kBLCWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kBLCWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kBLCWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kBLCWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Refresh command")

@interface BLCWebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate, BLCAwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, strong) UITextField* textField;
@property (nonatomic, strong) BLCAwsomeFloatingToolbar* awesomeToolbar;
@property (nonatomic, strong) UIButton* reloadButton;
@property (nonatomic, assign) NSUInteger frameCount;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;

@end

@implementation BLCWebBrowserViewController



#pragma mark - UIViewController

- (void) loadView
{
    UIView* mainView = [UIView new];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL or search item", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0 alpha:1];
    self.textField.delegate = self;
    self.textField.textAlignment = NSTextAlignmentCenter;
    
    
    self.awesomeToolbar = [[BLCAwsomeFloatingToolbar alloc] initWithFourTitles:@[kBLCWebBrowserBackString, kBLCWebBrowserForwardString, kBLCWebBrowserRefreshString, kBLCWebBrowserStopString]];
    self.awesomeToolbar.delegate = self;
    
    
    
    
    for (UIView* viewToAdd in @[self.webView, self.textField, self.awesomeToolbar])
    {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField* )textField
{
    [textField resignFirstResponder];
    
    NSString* URLString = textField.text;
    NSURL* URL = [NSURL URLWithString:URLString];
    NSRange stringRange = [URLString rangeOfString:@" "];
    
    
    if (stringRange.length > 0)
    {
        
        URLString = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        URLString = [NSString stringWithFormat:@"www.google.com/search?q=%@", URLString];
        
        URL = [NSURL URLWithString:URLString];
        NSURLRequest* request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
    
    
    if (!URL.scheme)
    {
        //This would happen if the user did not type http(s):
        
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    
    if (URL)
    {
        NSURLRequest* request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
    
    return NO;
}

#pragma mark - UIWebViewDelegate

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    self.frameCount++;
    [self updateButtonsAndTitle];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    self.frameCount--;
    [self updateButtonsAndTitle];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code != -999)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message: [error localizedDescription]
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                              otherButtonTitles: nil];
        
        [alert show];
        
    }
    
    [self updateButtonsAndTitle];
    self.frameCount--;
}

#pragma mark - Miscellaneous

- (void) resetWebView
{
    
    [self.webView removeFromSuperview];
    
    UIWebView* newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
    
}

- (void) updateButtonsAndTitle
{
    NSString* webpageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webpageTitle)
    {
        self.title = webpageTitle;
    }
    
    else
    {
        self.title = self.webView.request.URL.absoluteString;
    }
    
    if (self.frameCount > 0)
    {
        [self.activityIndicator isAnimating];
    }
    else
    {
        [self.activityIndicator stopAnimating];
    }
    
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kBLCWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kBLCWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:self.frameCount > 0 forButtonWithTitle:kBLCWebBrowserStopString];
    [self.awesomeToolbar setEnabled:self.webView.request.URL == 0 forButtonWithTitle:kBLCWebBrowserRefreshString];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    // Do any additional setup after loading the view.
}


- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    
    //Calculate some dimensions
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    //Assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 75);
    
}

- (void) floatingToolbar:(BLCAwsomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset
{
    CGPoint startingPoint = toolbar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame))
    {
        toolbar.frame = potentialNewFrame;
    }
}

#pragma mark - BLCAwesomeFloatingToolbarDelegate

- (void) floatingToolbar:(BLCAwsomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title
{
    if ([title isEqual:kBLCWebBrowserBackString])
    {
        [self.webView goBack];
    }
    
    else if ([title isEqual:kBLCWebBrowserForwardString])
    {
        [self.webView goForward];
    }
    
    else if ([title isEqual:kBLCWebBrowserStopString])
    {
        [self.webView stopLoading];
    }
    
    else if ([title isEqual:kBLCWebBrowserRefreshString])
    {
        [self.webView reload];
    }
}


@end
