//
//  CMDocument.h
//  Panoptimus
//
//  Created by Chris Morrison on 10/08/2014.
//  Copyright (c) 2014 Chris Morrison. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <WebKit/WebKit.h>
#import <ApplicationServices/ApplicationServices.h>
#import "CMWebAddressBar.h"

@interface CMDocument : NSDocument <NSTextFieldDelegate>
{
    NSMutableArray *_removeList;
    NSImage *_SSLImage;
    NSImage *_noSSLImage;
}

@property (strong) IBOutlet NSButton *backButton;
@property (strong) IBOutlet NSButton *forwardButton;
@property (strong) IBOutlet NSButton *goButton;
@property (strong) IBOutlet NSButton *stopButton;
@property (strong) IBOutlet NSButton *refreshButton;
@property (strong) IBOutlet NSButton *homeButton;
//@property (strong) IBOutlet NSTextField *addressBar;
@property (strong) IBOutlet CMWebAddressBar *addressBar;
@property (strong) IBOutlet NSSearchField *searchBar;
@property (strong) IBOutlet WebView *webView;
@property (strong) IBOutlet NSWindow *ourWindow;
@property (strong) IBOutlet NSTextField *ipAddress;
@property (strong) IBOutlet NSProgressIndicator *progressBar;
@property (strong) IBOutlet NSTextField *elementInfo;
@property (strong) IBOutlet NSButton *sslButton;


- (IBAction)backButtonClicked:(id)sender;
- (IBAction)forwardButtonClicked:(id)sender;
- (IBAction)shouldNavigateToPage:(id)sender;
- (IBAction)stopButtonClicked:(id)sender;
- (IBAction)refreshButtonClicked:(id)sender;
- (IBAction)homeButtonClicked:(id)sender;
- (IBAction)shouldPerformSearch:(id)sender;
- (IBAction)showPageSource:(id)sender;


- (void)setUpUI;

@end
