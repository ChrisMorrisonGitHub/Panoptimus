//
//  CMWebAddressBar.h
//  Panoptimus
//
//  Created by Chris Morrison on 31/01/2015.
//  Copyright (c) 2015 Chris Morrison. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

typedef enum __buttonAction
{
    kButtonShouldNavigate,
    kButtonShouldRefresh,
    kButtonShouldStopNavigation
} CMButtonAction;

@interface CMWebAddressBar : NSView <NSTextFieldDelegate>
{
    NSTextField *_addressBar;
    NSButton *_button;
    __weak WebView *_webView;
    id _target;
    SEL _action;
    CMButtonAction _buttonAction;
}

- (NSString *)stringValue;
- (void) setStringValue:(NSString *)aString;
- (id)target;
- (void)setTarget:(id)anObject;
- (SEL)action;
- (void)setAction:(SEL)selector;
- (BOOL)enabled;
- (void)setEnabled:(BOOL)flag;
- (void)setAssociatedWebView:(WebView *)newView;
- (WebView *)associatedWebView;

- (IBAction)_textFieldAction:(id)sender;
- (void)_associatedWebViewDidBegin:(NSNotification *)aNotification;
- (void)_associatedWebViewDidFinish:(NSNotification *)aNotification;

@end
