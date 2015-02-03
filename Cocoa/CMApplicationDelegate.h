//
//  CMApplicationDelegate.h
//  Panoptimus
//
//  Created by Chris Morrison on 28/01/2015.
//  Copyright (c) 2015 Chris Morrison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMApplicationDelegate : NSObject <NSApplicationDelegate>
{
    
}

@property (weak) IBOutlet NSWindow *preferencesWindow;
@property (weak) IBOutlet NSToolbar *toolbar;
@property (weak) IBOutlet NSView *generalView;
@property (weak) IBOutlet NSView *searchView;
@property (weak) IBOutlet NSView *securityView;
@property (weak) IBOutlet NSView *applicationsView;
@property (weak) IBOutlet NSView *advancedView;

- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)switchItem:(id)sender;


@end
