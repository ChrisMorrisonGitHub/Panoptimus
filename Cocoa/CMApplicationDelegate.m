//
//  CMApplicationDelegate.m
//  Panoptimus
//
//  Created by Chris Morrison on 28/01/2015.
//  Copyright (c) 2015 Chris Morrison. All rights reserved.
//

#import "CMApplicationDelegate.h"

@implementation CMApplicationDelegate

- (id)init
{
    self = [super init];
    if (self)
    {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    return NSTerminateNow;
}

- (void)awakeFromNib
{
    NSMenu * mainMenu = [NSApp mainMenu];
    NSMenuItem *item = [mainMenu itemWithTitle:@"Panoptimus"];
    [item setTitle:@"Panoptimus Web Browser"];
    
    [self switchItem:nil];
    [_toolbar setSelectedItemIdentifier:@"GeneralItem"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSMenu * mainMenu = [NSApp mainMenu];
    NSMenuItem *item = [mainMenu itemWithTitle:@"Panoptimus"];
    [item setTitle:@"Panoptimus Web Browser"];
    
    // Register the preference defaults early.
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"https://www.startpage.com/do/search?language=english&cat=web&query=%@" forKey:@"SearchURL"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}

- (IBAction)showPreferencesWindow:(id)sender
{
    [_preferencesWindow makeKeyAndOrderFront:self];
}

- (IBAction)switchItem:(id)sender
{
    if ((sender == nil) || ([[sender itemIdentifier] isEqualToString:@"GeneralItem"] == YES))
    {
        [_preferencesWindow setContentView:_generalView];
        [_generalView setHidden:NO];
        return;
    }
    if ([[sender itemIdentifier] isEqualToString:@"SearchItem"] == YES)
    {
        [_preferencesWindow setContentView:_searchView];
        [_searchView setHidden:NO];
        return;
    }
    if ([[sender itemIdentifier] isEqualToString:@"SecurityItem"] == YES)
    {
        [_preferencesWindow setContentView:_securityView];
        [_securityView setHidden:NO];
        return;
    }
    if ([[sender itemIdentifier] isEqualToString:@"ApplicationsItem"] == YES)
    {
        [_preferencesWindow setContentView:_applicationsView];
        [_applicationsView setHidden:NO];
        return;
    }
    if ([[sender itemIdentifier] isEqualToString:@"AdvancedItem"] == YES)
    {
        [_preferencesWindow setContentView:_advancedView];
        [_advancedView setHidden:NO];
        return;
    }
}
@end
