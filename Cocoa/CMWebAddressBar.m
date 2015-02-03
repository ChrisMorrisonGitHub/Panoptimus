//
//  CMWebAddressBar.m
//  Panoptimus
//
//  Created by Chris Morrison on 31/01/2015.
//  Copyright (c) 2015 Chris Morrison. All rights reserved.
//

#import "CMWebAddressBar.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 5.0
#define BUTTON_WIDTH  32.00
#define CERT_AREA     60.00
#define DEFAULT_WIDTH 200.00
#define MAX_HEIGHT    22.00
#define BORDER_WIDTH  1.00
#define ICON_PADDING  3.00

@implementation CMWebAddressBar

- (id)init
{
    self = [super init];
    if (self)
    {
        _target = nil;
        _action = nil;
        // Action buttons
        _buttonAction = kButtonShouldNavigate;
        _button = [[NSButton alloc] initWithFrame:NSMakeRect(0, ICON_PADDING, ([self bounds].size.height - (ICON_PADDING * 2)), ([self bounds].size.height - (ICON_PADDING * 2)))];
        [_button setImage:[NSImage imageNamed:NSImageNameFollowLinkFreestandingTemplate]];
        [_button setBordered:NO];
        [_button setImagePosition:NSImageOnly];
        [_button setButtonType:NSMomentaryChangeButton];
        [self addSubview:_button];
        [_button setHidden:NO];
        [self setFrameSize:NSMakeSize(DEFAULT_WIDTH, MAX_HEIGHT)];
        [self setWantsLayer:YES];
        [[self layer] setMasksToBounds:YES];
        [[self layer] setCornerRadius:CORNER_RADIUS];
        _addressBar = [[NSTextField alloc] initWithFrame:NSMakeRect(0, (BORDER_WIDTH + 1), (DEFAULT_WIDTH - (CERT_AREA + BUTTON_WIDTH)), (MAX_HEIGHT - (BORDER_WIDTH * 4)))];
        [_addressBar setBordered:NO];
        NSFont *font = [_addressBar font];
        NSFont *newFont = [NSFont fontWithName:[font fontName] size:[font pointSize] + 1];
        [_addressBar setFont:newFont];
        [_addressBar setTarget:self];
        [_addressBar setAction:@selector(_textFieldAction:)];
        [self addSubview:_addressBar];
        [_addressBar setDelegate:self];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    if (frameRect.size.height != MAX_HEIGHT) frameRect.size.height = MAX_HEIGHT;
    self = [super initWithFrame:frameRect];
    if (self)
    {
        _target = nil;
        _action = nil;
        // Action buttons
        _buttonAction = kButtonShouldNavigate;
        _button = [[NSButton alloc] initWithFrame:NSMakeRect(0, ICON_PADDING, ([self bounds].size.height - (ICON_PADDING * 2)), ([self bounds].size.height - (ICON_PADDING * 2)))];
        [_button setImage:[NSImage imageNamed:NSImageNameFollowLinkFreestandingTemplate]];
        [_button setBordered:NO];
        [_button setImagePosition:NSImageOnly];
        [_button setButtonType:NSMomentaryChangeButton];
        [self addSubview:_button];
        [_button setHidden:NO];
        [self setWantsLayer:YES];
        [[self layer] setMasksToBounds:YES];
        [[self layer] setCornerRadius:CORNER_RADIUS];
        _addressBar = [[NSTextField alloc] initWithFrame:NSMakeRect(0, (BORDER_WIDTH + 1), (frameRect.size.width - (CERT_AREA + BUTTON_WIDTH)), (MAX_HEIGHT - (BORDER_WIDTH * 4)))];
        [_addressBar setBordered:NO];
        NSFont *font = [_addressBar font];
        NSFont *newFont = [NSFont fontWithName:[font fontName] size:[font pointSize] + 1];
        [_addressBar setFont:newFont];
        [_addressBar setTarget:self];
        [_addressBar setAction:@selector(_textFieldAction:)];
        [self addSubview:_addressBar];
        [_addressBar setDelegate:self];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [_addressBar setFrame:NSMakeRect(CERT_AREA, (BORDER_WIDTH + 1), ([self bounds].size.width - (CERT_AREA + BUTTON_WIDTH)), ([self bounds].size.height) - (BORDER_WIDTH * 4))];
    [_button setFrameOrigin:NSMakePoint([self bounds].size.width - ((BUTTON_WIDTH / 2) + [_button bounds].size.width / 2), ICON_PADDING)];
    
    [NSGraphicsContext saveGraphicsState];
    [[NSColor textBackgroundColor] setFill];
    NSRectFill([self bounds]);
    NSBezierPath *borderRect = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds, 0.5, 0.5) xRadius:CORNER_RADIUS yRadius:CORNER_RADIUS];
    [borderRect setLineWidth:1.0];
    [[NSColor windowFrameColor] setStroke];
    [borderRect stroke];
    NSRect iRect = [self bounds];
    iRect.origin.x += CERT_AREA;
    iRect.size.width = [_addressBar frame].size.width;
    NSBezierPath *lines = [NSBezierPath bezierPathWithRect:NSInsetRect(iRect, -0.5, -0.5)];
    [lines stroke];
    [NSGraphicsContext restoreGraphicsState];
}

- (NSString *)stringValue
{
    return  [_addressBar stringValue];
}

- (void) setStringValue:(NSString *)aString
{
    [_addressBar setStringValue:aString];
}

- (id)target
{
    return _target;
}

- (void)setTarget:(id)anObject
{
    _target = anObject;
}

- (SEL)action
{
    return _action;
}

- (void)setAction:(SEL)selector
{
    _action = selector;
}

- (BOOL)enabled
{
    return [_button isEnabled];
}

- (void)setEnabled:(BOOL)flag
{
    [_addressBar setEditable:flag];
    [_button setEnabled:flag];
}

- (IBAction)_textFieldAction:(id)sender
{
    [NSApp sendAction:_action to:_target from:self];
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    [_button setImage:[NSImage imageNamed:NSImageNameFollowLinkFreestandingTemplate]];
    _buttonAction = kButtonShouldStopNavigation;
}

- (void)setAssociatedWebView:(WebView *)newView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _webView = newView;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_associatedWebViewDidBegin:) name:WebViewProgressStartedNotification object:_webView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_associatedWebViewDidFinish:) name:WebViewProgressFinishedNotification object:_webView];
}

- (WebView *)associatedWebView
{
    return _webView;
}

- (void)_associatedWebViewDidBegin:(NSNotification *)aNotification
{
    [_button setImage:[NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate]];
    _buttonAction = kButtonShouldStopNavigation;
}

- (void)_associatedWebViewDidFinish:(NSNotification *)aNotification
{
    [_button setImage:[NSImage imageNamed:NSImageNameRefreshTemplate]];
    _buttonAction = kButtonShouldRefresh;
}

@end
