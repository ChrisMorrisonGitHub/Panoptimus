//
//  CMDocument.m
//  Panoptimus
//
//  Created by Chris Morrison on 10/08/2014.
//  Copyright (c) 2014 Chris Morrison. All rights reserved.
//

#import "CMDocument.h"

@implementation CMDocument

- (id)init
{
    self = [super init];
    if (self)
    {
        _removeList = [[NSMutableArray alloc] initWithCapacity:10];
        _SSLImage = [NSImage imageNamed:NSImageNameLockLockedTemplate];
        _noSSLImage = [NSImage imageNamed:NSImageNameLockUnlockedTemplate];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"CMDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [_webView setApplicationNameForUserAgent:@"Panoptimus Web Browser"];
    
    [self setDisplayName:@"Panoptimus Web Browser"];
    
    [_addressBar setTarget:self];
    [_addressBar setAction:@selector(shouldNavigateToPage:)];
    [_addressBar setAssociatedWebView:_webView];
    
    // Set up proxy
    
    NSURL *url = [NSURL URLWithString:@"http://api.ipify.org?format=text"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if ([data length] > 0 && error == nil)
        {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [_ipAddress setStringValue:string];
        }
    }];
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (BOOL)isDocumentEdited
{
    return NO;
}

- (NSWindow *)windowForSheet
{
    return [self ourWindow];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableData *data = nil;
    NSError *error = nil;
    
    if ([typeName isEqualToString:@"public.html"] == YES)
    {
        data = [[NSMutableData alloc] init];
        [data setData:[[[_webView mainFrame] dataSource] data]];
    }
    else if ([typeName isEqualToString:@"com.apple.webarchive"] == YES)
    {
        data = [[NSMutableData alloc] init];
        [data setData:[[[[_webView mainFrame] dataSource] webArchive] data]];
    }
    else
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Unsupported data request." forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"PanoptimusWebBrowserDomain" code:1 userInfo:dict];
        if (outError != NULL) *outError = error;
    }
    
    return data;
}

- (IBAction)saveDocumentAs:(id)sender
{
    [self runModalSavePanelForSaveOperation:NSSaveToOperation delegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:NULL];
}

- (void)document:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo
{
    [self setDisplayName:[_webView mainFrameTitle]];
    [[self ourWindow] setTitle:[_webView mainFrameTitle]];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    if ([typeName isEqualToString:@"public.html"] == YES)
    {
        [[_webView mainFrame] loadData:data MIMEType:@"text/html" textEncodingName:@"UTF8" baseURL:nil];
        return YES;
    }
    
    return NO;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    if ([typeName isEqualToString:@"public.html"] == NO)
    {
        return NO;
    }
    
    [self setDisplayName:@"Panoptimus Web Browser"];
    if (((url == nil) || ([url host] == nil)) || ([[url host] isEqualToString:@""] == YES))
    {
        url = [NSURL URLWithString:@"about:blank"];
        [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    NSString *path = ([url path] == nil) ? @"" : [url path];
    NSURLComponents *components = [[NSURLComponents alloc] init];
    [components setScheme:@"http"];
    [components setHost:[url host]];
    [components setPath:path];
    [components setQuery:[url query]];
    url = [components URL];
    
    [_progressBar setHidden:NO];
    [_progressBar setDoubleValue:0.0];
    [_addressBar setStringValue:[url absoluteString]];
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
    [self setUpUI];
    [_stopButton setEnabled:YES];
    
    return YES;
}

- (IBAction)backButtonClicked:(id)sender
{
    [_webView goBack];
    [self setUpUI];
}

- (IBAction)forwardButtonClicked:(id)sender
{
    [_webView goForward];
    [self setUpUI];
}

- (IBAction)shouldNavigateToPage:(id)sender
{
    [_goButton setEnabled:NO];
    [self navigateToAddress:[_addressBar stringValue]];
    [self setUpUI];
}

- (IBAction)stopButtonClicked:(id)sender
{
    [_webView stopLoading:self];
    [self setUpUI];
    [_goButton setEnabled:YES];
}

- (IBAction)refreshButtonClicked:(id)sender
{
    [[_webView mainFrame] reload];
    [self setUpUI];
}

- (IBAction)homeButtonClicked:(id)sender
{
}

- (IBAction)shouldPerformSearch:(id)sender
{
    [self performSearch:[_searchBar stringValue]];
}

- (void)navigateToAddress:(NSString *)address
{
    NSURL *url = nil;
    NSString *_allowedChars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz:/%.,?=&#";
    NSCharacterSet *allowedChars = [NSCharacterSet characterSetWithCharactersInString:_allowedChars];
    NSURLComponents *components = nil;
    BOOL (^CheckAddress)(NSString *) = ^(NSString * address)
    {
        for (NSInteger idx = 0; idx < [address length]; idx++)
        {
            if ([allowedChars characterIsMember:[address characterAtIndex:idx]] == NO) return NO;
        }
        return YES;
    };
    
    if ((address == nil) || ([address isEqualToString:@""] == YES))
    {
        url = [NSURL URLWithString:@"about:blank"];
        [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
    }
    else
    {
        address = [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if (CheckAddress(address) == YES)
    {
        NSRange scheme = [address rangeOfString:@"://"];
        if (scheme.location == NSNotFound) address = [NSString stringWithFormat:@"https://%@", address];
        url = nil;
        components = [NSURLComponents componentsWithString:address];
        if ([components host] != nil)
        {
            [components setScheme:@"https"];
            [components setHost:[[components host] lowercaseString]];
            url = [components URL];
        }
    }
    else
    {
        url = nil;
    }
    
    if (url != nil)
    {
        [self readFromURL:url ofType:@"public.html" error:nil];
        return;
    }
    
    [self performSearch:address]; // url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.startpage.com/do/search?language=english&cat=web&query=%@", [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

- (void)performSearch:(NSString *)searchTerm
{
    if ((searchTerm == nil) || ([searchTerm isEqualToString:@""] == YES)) return;
    
    searchTerm = [searchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [_searchBar setStringValue:searchTerm];
    [[self ourWindow] makeFirstResponder:_searchBar];
    searchTerm = [[searchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.startpage.com/do/search?language=english&cat=web&query=%@", [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [self readFromURL:url ofType:@"public.html" error:nil];
}

- (NSURL *)findApplicationByID:(NSString *)appID
{
    CFURLRef appURL = NULL;
    OSStatus result = LSFindApplicationForInfo (kLSUnknownCreator, (__bridge CFStringRef)(appID), NULL, NULL, &appURL);
    if (result != noErr) return nil;
    if (appURL == nil) return nil;
    
    return CFBridgingRelease(appURL);
}

- (IBAction)showPageSource:(id)sender
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSArray *apps = [NSArray arrayWithObjects:@"Taco HTML Edit.app", @"BBEdit.app", @"TextWrangler.app", @"TextEdit.app", nil];
    NSString *tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", [[NSUUID UUID] UUIDString]]];
    BOOL opened = NO;
    NSUInteger idx = 0;
    
    [[[[_webView mainFrame] dataSource] data] writeToFile:tempFile atomically:NO];
    
    do
    {
        opened = [workspace openFile:tempFile withApplication:[apps objectAtIndex:idx]];
        idx++;
    } while (opened == NO);
    
    [_removeList addObject:tempFile];
}

- (NSURL *)findApplicationByName:(NSString *)appName
{
    CFURLRef appURL = NULL;
    OSStatus result = LSFindApplicationForInfo (kLSUnknownCreator, NULL, (__bridge CFStringRef)(appName), NULL, &appURL);
    if (result != noErr) return nil;
    if (appURL == nil) return nil;
    
    return CFBridgingRelease(appURL);
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    SEL action = [menuItem action];
    BOOL pageValid = [self pageIsUsable:_webView];
    
    if ( (action == @selector(saveDocumentAs:)) || (action == @selector(printDocument:)) || (action == @selector(runPageLayout:)) || (action == @selector(selectAll:))) return pageValid;
    if (action == @selector(showPageSource:) == YES) return pageValid;
    return YES;
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
    NSLog(@"%@", anItem);
    return YES;
}

- (BOOL)pageIsUsable:(WebView *)page
{
    DOMDocument *dom = [[page mainFrame] DOMDocument];
    if (dom == nil) return NO;
    if ([[dom readyState] isEqualToString:@"complete"] == NO) return NO;
    if ([page isLoading] == YES) return NO;
    if ([[page mainFrameTitle] isEqualToString:@""] == YES) return NO;
    if ([[page mainFrame] dataSource] == nil) return NO;
    if ([[[[page mainFrame] dataSource] data] length] == 0) return NO;
    
    return YES;
}

/*- (BOOL)isCopyableText:(WebView *)page
{
    WebFrame *selectedFrame = [page selectedFrame];
    NSResponder *firstResponder = [[self ourWindow] firstResponder];
    DOMRange *selection = [page selectedDOMRange];
    
    if (selectedFrame == nil) return NO;
    if (firstResponder == nil) return NO;
    if (selection == nil) return NO;
    if ([[selection toString] isEqualToString:@""] == YES) return NO;
    
    return YES;
} */

- (void)setUpUI
{
    [_backButton setEnabled:[_webView canGoBack]];
    [_forwardButton setEnabled:[_webView canGoForward]];
    
    if ([_webView isLoading] == YES)
    {
        [_goButton setEnabled:NO];
        [_stopButton setEnabled:YES];
        [_addressBar setEnabled:NO];
        [_searchBar setEnabled:NO];
    }
    else
    {
        [_stopButton setEnabled:NO];
        [_addressBar setEnabled:YES];
        [_refreshButton setEnabled:YES];
        [_searchBar setEnabled:YES];
    }
}

// WebView WebDownloadDelegate methods

- (NSWindow *)downloadWindowForAuthenticationSheet:(WebDownload *)sender
{
    return [self ourWindow];
}

// WebView FrameLoadDelegate methods

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    NSString *add = [[[[[sender mainFrame] provisionalDataSource] request] URL] absoluteString];
    if ([add hasPrefix:@"https://"] == YES)
    {
        [_sslButton setImage:_SSLImage];
    }
    else
    {
        [_sslButton setImage:_noSSLImage];
    }
    [_elementInfo setHidden:YES];
    [_progressBar setHidden:NO];
    [_progressBar setDoubleValue:[_webView estimatedProgress]];
    [self setUpUI];
}

- (void)webView:(WebView *)sender didReceiveServerRedirectForProvisionalLoadForFrame:(WebFrame *)frame
{
    
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    [_progressBar setHidden:YES];
    NSString *message = @"Error Loading Page";
    NSString *info = [error localizedDescription];
    NSInteger errorCode = [error code];
    NSString *errorDomain = [error domain];
    [self setUpUI];
    
    //NSLog(@"Error domain %@, code %ld", errorDomain, (long)errorCode);
    
    if ([errorDomain isEqualToString:@"WebKitErrorDomain"] == YES)
    {
        switch (errorCode)
        {
            case WebKitErrorFrameLoadInterruptedByPolicyChange:
                return;
            default:
                return;
        }
    }
    if ([errorDomain isEqualToString:@"NSURLErrorDomain"] == YES)
    {
        switch (errorCode)
        {
            case NSURLErrorBadURL: // = -1000
                info = @"Invalid address or URL.";
                break;
            case NSURLErrorTimedOut: // = -1001
                info = @"The operation timed out.";
                break;
            case NSURLErrorCannotFindHost:
                [self performSearch:[[[[[_webView mainFrame] provisionalDataSource] request] URL] host]];
                return;
            default:
                return;
        }
    }
    
    NSAlert *alert = [NSAlert alertWithMessageText:message defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", info];
    [alert setInformativeText:info];
    [alert setMessageText:message];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert runModal];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    [_progressBar setHidden:YES];
    NSString *message = @"Error Loading Page";
    NSString *info = [error localizedDescription];
    NSInteger errorCode = [error code];
    NSString *errorDomain = [error domain];
    [self setUpUI];
    
    //NSLog(@"Error domain %@, code %ld", errorDomain, (long)errorCode);
    
    if ([errorDomain isEqualToString:@"WebKitErrorDomain"] == YES)
    {
        switch (errorCode)
        {
            case WebKitErrorFrameLoadInterruptedByPolicyChange:
                return;
            default:
                return;
        }
    }
    if ([errorDomain isEqualToString:@"NSURLErrorDomain"] == YES)
    {
        switch (errorCode)
        {
            case NSURLErrorBadURL: // = -1000
                info = @"Invalid address or URL.";
                break;
            case NSURLErrorTimedOut: // = -1001
                info = @"The operation timed out.";
                break;
            case NSURLErrorCannotFindHost:
                [self performSearch:[[[[[_webView mainFrame] provisionalDataSource] request] URL] host]];
                return;
            default:
                return;
        }
    }
    
    NSAlert *alert = [NSAlert alertWithMessageText:message defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", info];
    [alert setInformativeText:info];
    [alert setMessageText:message];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert runModal];
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame
{
    [_addressBar setStringValue:[[[[[sender mainFrame] dataSource] request] URL] absoluteString]];
    [_elementInfo setHidden:YES];
    [_progressBar setHidden:NO];
    [_progressBar setDoubleValue:[_webView estimatedProgress]];
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if (frame == [_webView mainFrame])
    {
        [self setDisplayName:[_webView mainFrameTitle]];
        [[self ourWindow] setTitle:[_webView mainFrameTitle]];
    }
}

- (void)webView:(WebView *)sender didReceiveIcon:(NSImage *)image forFrame:(WebFrame *)frame
{
    
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    NSString *add = [[[[[sender mainFrame] dataSource] request] URL] absoluteString];
    if ([add hasPrefix:@"https://"] == YES)
    {
        [_sslButton setImage:_SSLImage];
    }
    else
    {
        [_sslButton setImage:_noSSLImage];
    }
    [_addressBar setStringValue:add];
    [_elementInfo setHidden:YES];
    [_progressBar setHidden:NO];
    [_progressBar setDoubleValue:[_webView estimatedProgress]];
    
    if ([sender isLoading] == NO)
    {
        [_refreshButton setEnabled:YES];
        [_progressBar setHidden:YES];
        [[self ourWindow] makeFirstResponder:_webView];
    }
    
    [self setUpUI];
}

- (void)webView:(WebView *)sender didChangeLocationWithinPageForFrame:(WebFrame *)frame
{
    
}

- (void)webView:(WebView *)sender willPerformClientRedirectToURL:(NSURL *)URL delay:(NSTimeInterval)seconds fireDate:(NSDate *)date forFrame:(WebFrame *)frame
{
    
}

- (void)webView:(WebView *)sender didCancelClientRedirectForFrame:(WebFrame *)frame
{
    
}

- (void)webView:(WebView *)sender willCloseFrame:(WebFrame *)frame
{
    
}

- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
    
}

- (void)webView:(WebView *)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame
{
    
}

// WebView WebPolicyDelegate methods

- (void)webView:(WebView *)webView decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    if ([type isEqualToString:@"application/pdf"] == YES)
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"File Download Requested" defaultButton:@"Download" alternateButton:@"Open in Adobe Reader" otherButton:@"Cancel" informativeTextWithFormat:@"What would you like to do with this PDF file?"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        NSModalResponse r = [alert runModal];
        switch (r)
        {
            case NSAlertDefaultReturn:
                break;
            case NSAlertAlternateReturn:
                [[NSWorkspace sharedWorkspace] openURL:[request URL]];
                [listener ignore];
                break;
            default:
                [listener ignore];
                break;
        }
    }
    NSLog(@"MIME type requested %@", type);
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSString *host = [[request URL] host];
    if (host == nil)
    {
        [listener ignore];
        return;
    }
    
    if ([host isEqualToString:@"adimg.uimserv.net"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"tpc.googlesyndication.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"aax-eu.amazon-adsystem.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"cm.g.doubleclick.net"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"googleads.g.doubleclick.net"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"accounts.google.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"sec-s.uicdn.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"smmc.sitescoutadserver.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"platform.twitter.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"s-static.ak.facebook.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"apis.google.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"www.reddit.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"static.ak.facebook.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"disqus.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"ads.pubmatic.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"seg.sharethis.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"engine.4dsply.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"edge.sharethis.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"a.rfihub.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"my.leadpages.net"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"tags.bluekai.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"secure-us.imrworldwide.com"] == YES) { [listener ignore]; return; }
    if ([host isEqualToString:@"s7.addthis.com"] == YES) { [listener ignore]; return; }
    
    [listener use];
    printf("if ([host isEqualToString:@\"%s\"] == YES) { [listener ignore]; return; }\n", [host UTF8String]);
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSError *theError;
    CMDocument *theDocument = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:&theError];
    if (theDocument == nil)
    {
        [NSApp presentError:theError];
        return;
    }
    [theDocument readFromURL:[request URL] ofType:@"public.html" error:NULL];
    
    [listener ignore];
}

- (void)webView:(WebView *)webView unableToImplementPolicyWithError:(NSError *)error frame:(WebFrame *)frame
{
    [NSApp presentError:error modalForWindow:[self ourWindow] delegate:nil didPresentSelector:nil contextInfo:NULL];
}

// WebView WebResourceLoadDelegate methods

- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource
{
    return nil;
}

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    return request;
}

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge fromDataSource:(WebDataSource *)dataSource
{
    
}

- (void)webView:(WebView *)sender resource:(id)identifier didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge fromDataSource:(WebDataSource *)dataSource
{
    
}

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)dataSource
{
    [_elementInfo setHidden:YES];
    [_progressBar setHidden:NO];
    [_progressBar setDoubleValue:[_webView estimatedProgress]];
}

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveContentLength:(NSInteger)length fromDataSource:(WebDataSource *)dataSource
{
    [_elementInfo setHidden:YES];
    [_progressBar setHidden:NO];
    [_progressBar setDoubleValue:[_webView estimatedProgress]];
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    [_elementInfo setHidden:YES];
    [_progressBar setHidden:NO];
    [_progressBar setDoubleValue:[_webView estimatedProgress]];
}

- (void)webView:(WebView *)sender resource:(id)identifier didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource
{
    [self setUpUI];
}

- (void)webView:(WebView *)sender plugInFailedWithError:(NSError *)error dataSource:(WebDataSource *)dataSource
{
    NSInteger errorCode = [error code];
    if (errorCode == 102) return;
    
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert setInformativeText:[alert messageText]];
    [alert setMessageText:@"A Plugin Has Stopped Working"];
    [alert runModal];
}

// WebView UIDelegate

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    NSError *theError;
    CMDocument *theDocument = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:&theError];
    if (theDocument == nil)
    {
        [NSApp presentError:theError];
        return nil;
    }
    if ([theDocument readFromURL:[request URL] ofType:@"public.html" error:NULL] == YES) return [theDocument webView];
    
    return nil;
}


- (void)webViewShow:(WebView *)sender
{
    
}

//- (WebView *)webView:(WebView *)sender createWebViewModalDialogWithRequest:(NSURLRequest *)request
//{
    
//}


- (void)webViewRunModal:(WebView *)sender
{
    
}

- (void)webViewClose:(WebView *)sender
{
    
}

- (void)webViewFocus:(WebView *)sender
{
    
}

- (void)webViewUnfocus:(WebView *)sender
{
    
}

- (NSResponder *)webViewFirstResponder:(WebView *)sender
{
    return [[self ourWindow] firstResponder];
}

- (void)webView:(WebView *)sender makeFirstResponder:(NSResponder *)responder
{
    [[self ourWindow] makeFirstResponder:responder];
}

- (void)webView:(WebView *)sender setStatusText:(NSString *)text
{
    
}

//- (NSString *)webViewStatusText:(WebView *)sender
//{
    
//}

- (BOOL)webViewAreToolbarsVisible:(WebView *)sender
{
    return NO;
}

- (void)webView:(WebView *)sender setToolbarsVisible:(BOOL)visible
{
    
}

- (BOOL)webViewIsStatusBarVisible:(WebView *)sender
{
    return NO;
}

- (void)webView:(WebView *)sender setStatusBarVisible:(BOOL)visible
{
    
}

- (BOOL)webViewIsResizable:(WebView *)sender
{
    return YES;
}

- (void)webView:(WebView *)sender setResizable:(BOOL)resizable
{
    
}

- (void)webView:(WebView *)sender setFrame:(NSRect)frame
{
    
}

//- (NSRect)webViewFrame:(WebView *)sender
//{
    
//}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"A JavaScript Error Occurred" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:[self ourWindow] modalDelegate:nil didEndSelector:nil contextInfo:NULL];
}

/*!
 @method webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:
 @abstract Display a JavaScript confirm panel.
 @param sender The WebView sending the delegate method.
 @param message The message to display.
 @param frame The WebFrame whose JavaScript initiated this call.
 @result YES if the user hit OK, NO if the user chose Cancel.
 @discussion Clients should visually indicate that this panel comes
 from JavaScript initiated by the specified frame. The panel should have
 two buttons, e.g. "OK" and "Cancel".
 */
- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Message From JavaScript" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"%@", message];
    [alert setAlertStyle:NSInformationalAlertStyle];
    NSModalResponse r = [alert runModal];
    if (r == NSAlertDefaultReturn) return YES;
    
    return NO;
}

/*!
 @method webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:
 @abstract Display a JavaScript text input panel.
 @param sender The WebView sending the delegate method.
 @param message The message to display.
 @param defaultText The initial text for the text entry area.
 @param frame The WebFrame whose JavaScript initiated this call.
 @result The typed text if the user hit OK, otherwise nil.
 @discussion Clients should visually indicate that this panel comes
 from JavaScript initiated by the specified frame. The panel should have
 two buttons, e.g. "OK" and "Cancel", and an area to type text.
 */
//- (NSString *)webView:(WebView *)sender runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WebFrame *)frame
//{
    
//}

/*!
 @method webView:runBeforeUnloadConfirmPanelWithMessage:initiatedByFrame:
 @abstract Display a confirm panel by an "before unload" event handler.
 @param sender The WebView sending the delegate method.
 @param message The message to display.
 @param frame The WebFrame whose JavaScript initiated this call.
 @result YES if the user hit OK, NO if the user chose Cancel.
 @discussion Clients should include a message in addition to the one
 supplied by the web page that indicates. The panel should have
 two buttons, e.g. "OK" and "Cancel".
 */
- (BOOL)webView:(WebView *)sender runBeforeUnloadConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Message From JavaScript" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"%@", message];
    [alert setAlertStyle:NSInformationalAlertStyle];
    NSModalResponse r = [alert runModal];
    if (r == NSAlertDefaultReturn) return YES;
    
    return NO;
}

/*!
 @method webView:runOpenPanelForFileButtonWithResultListener:
 @abstract Display a file open panel for a file input control.
 @param sender The WebView sending the delegate method.
 @param resultListener The object to call back with the results.
 @discussion This method is passed a callback object instead of giving a return
 value so that it can be handled with a sheet.
 */
- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id<WebOpenPanelResultListener>)resultListener
{
    
}

/*!
 @method webView:runOpenPanelForFileButtonWithResultListener:allowMultipleFiles
 @abstract Display a file open panel for a file input control that may allow multiple files to be selected.
 @param sender The WebView sending the delegate method.
 @param resultListener The object to call back with the results.
 @param allowMultipleFiles YES if the open panel should allow myltiple files to be selected, NO if not.
 @discussion This method is passed a callback object instead of giving a return
 value so that it can be handled with a sheet.
 */
- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id<WebOpenPanelResultListener>)resultListener allowMultipleFiles:(BOOL)allowMultipleFiles NS_AVAILABLE_MAC(10_6)
{
    
}

/*!
 @method webView:mouseDidMoveOverElement:modifierFlags:
 @abstract Update the window's feedback for mousing over links to reflect a new item the mouse is over
 or new modifier flags.
 @param sender The WebView sending the delegate method.
 @param elementInformation Dictionary that describes the element that the mouse is over, or nil.
 @param modifierFlags The modifier flags as in NSEvent.
 */
- (void)webView:(WebView *)sender mouseDidMoveOverElement:(NSDictionary *)elementInformation modifierFlags:(NSUInteger)modifierFlags
{
    if ([_progressBar isHidden] == NO) return;
    if (elementInformation == nil)
    {
        [_elementInfo setHidden:YES];
        return;
    }
    NSURL *url = (NSURL *)[elementInformation objectForKey:WebElementLinkURLKey];
    if (url == nil)
    {
        [_elementInfo setHidden:YES];
        return;
    }
    NSString *address = [url absoluteString];
    if ((address == nil) || ([address isEqualToString:@""] == true))
    {
        [_elementInfo setHidden:NO];
        return;
    }
    
    [_elementInfo setHidden:NO];
    [_elementInfo setStringValue:address];
}

/*!
 @method webView:contextMenuItemsForElement:defaultMenuItems:
 @abstract Returns the menu items to display in an element's contextual menu.
 @param sender The WebView sending the delegate method.
 @param element A dictionary representation of the clicked element.
 @param defaultMenuItems An array of default NSMenuItems to include in all contextual menus.
 @result An array of NSMenuItems to include in the contextual menu.
 */
- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:defaultMenuItems];
    NSMenuItem *seperator = [NSMenuItem separatorItem];
    
    return items;
}

/*!
 @method webView:validateUserInterfaceItem:defaultValidation:
 @abstract Controls UI validation
 @param webView The WebView sending the delegate method
 @param item The user interface item being validated
 @pararm defaultValidation Whether or not the WebView thinks the item is valid
 @discussion This method allows the UI delegate to control WebView's validation of user interface items.
 See WebView.h to see the methods to that WebView can currently validate. See NSUserInterfaceValidations and
 NSValidatedUserInterfaceItem for information about UI validation.
 */
//- (BOOL)webView:(WebView *)webView validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item defaultValidation:(BOOL)defaultValidation
//{
    
//}

/*!
 @method webView:shouldPerformAction:fromSender:
 @abstract Controls actions
 @param webView The WebView sending the delegate method
 @param action The action being sent
 @param sender The sender of the action
 @discussion This method allows the UI delegate to control WebView's behavior when an action is being sent.
 For example, if the action is copy:, the delegate can return YES to allow WebView to perform its default
 copy behavior or return NO and perform copy: in some other way. See WebView.h to see the actions that
 WebView can perform.
 */
//- (BOOL)webView:(WebView *)webView shouldPerformAction:(SEL)action fromSender:(id)sender
//{
    
//}

/*!
 @method webView:dragDestinationActionMaskForDraggingInfo:
 @abstract Controls behavior when dragging to a WebView
 @param webView The WebView sending the delegate method
 @param draggingInfo The dragging info of the drag
 @discussion This method is called periodically as something is dragged over a WebView. The UI delegate can return a mask
 indicating which drag destination actions can occur, WebDragDestinationActionAny to allow any kind of action or
 WebDragDestinationActionNone to not accept the drag.
 */
- (NSUInteger)webView:(WebView *)webView dragDestinationActionMaskForDraggingInfo:(id <NSDraggingInfo>)draggingInfo
{
    return WebDragDestinationActionAny;
}

/*!
 @method webView:willPerformDragDestinationAction:forDraggingInfo:
 @abstract Informs that WebView will perform a drag destination action
 @param webView The WebView sending the delegate method
 @param action The drag destination action
 @param draggingInfo The dragging info of the drag
 @discussion This method is called after the last call to webView:dragDestinationActionMaskForDraggingInfo: after something is dropped on a WebView.
 This method informs the UI delegate of the drag destination action that WebView will perform.
 */
- (void)webView:(WebView *)webView willPerformDragDestinationAction:(WebDragDestinationAction)action forDraggingInfo:(id <NSDraggingInfo>)draggingInfo
{
    
}

/*!
 @method webView:dragSourceActionMaskForPoint:
 @abstract Controls behavior when dragging from a WebView
 @param webView The WebView sending the delegate method
 @param point The point where the drag started in the coordinates of the WebView
 @discussion This method is called after the user has begun a drag from a WebView. The UI delegate can return a mask indicating
 which drag source actions can occur, WebDragSourceActionAny to allow any kind of action or WebDragSourceActionNone to not begin a drag.
 */
- (NSUInteger)webView:(WebView *)webView dragSourceActionMaskForPoint:(NSPoint)point
{
    return WebDragSourceActionAny;
}

/*!
 @method webView:willPerformDragSourceAction:fromPoint:withPasteboard:
 @abstract Informs that a drag a has begun from a WebView
 @param webView The WebView sending the delegate method
 @param action The drag source action
 @param point The point where the drag started in the coordinates of the WebView
 @param pasteboard The drag pasteboard
 @discussion This method is called after webView:dragSourceActionMaskForPoint: is called after the user has begun a drag from a WebView.
 This method informs the UI delegate of the drag source action that will be performed and gives the delegate an opportunity to modify
 the contents of the dragging pasteboard.
 */
- (void)webView:(WebView *)webView willPerformDragSourceAction:(WebDragSourceAction)action fromPoint:(NSPoint)point withPasteboard:(NSPasteboard *)pasteboard
{
    
}

/*!
 @method webView:printFrameView:
 @abstract Informs that a WebFrameView needs to be printed
 @param webView The WebView sending the delegate method
 @param frameView The WebFrameView needing to be printed
 @discussion This method is called when a script or user requests the page to be printed.
 In this method the delegate can prepare the WebFrameView to be printed. Some content that WebKit
 displays can be printed directly by the WebFrameView, other content will need to be handled by
 the delegate. To determine if the WebFrameView can handle printing the delegate should check
 WebFrameView's documentViewShouldHandlePrint, if YES then the delegate can call printDocumentView
 on the WebFrameView. Otherwise the delegate will need to request a NSPrintOperation from
 the WebFrameView's printOperationWithPrintInfo to handle the printing.
 */
- (void)webView:(WebView *)sender printFrameView:(WebFrameView *)frameView
{
    
}

/*!
 @method webViewHeaderHeight:
 @param webView The WebView sending the delegate method
 @abstract Reserve a height for the printed page header.
 @result The height to reserve for the printed page header, return 0.0 to not reserve any space for a header.
 @discussion The height returned will be used to calculate the rect passed to webView:drawHeaderInRect:.
 */
- (float)webViewHeaderHeight:(WebView *)sender
{
    return 0.0;
}

/*!
 @method webViewFooterHeight:
 @param webView The WebView sending the delegate method
 @abstract Reserve a height for the printed page footer.
 @result The height to reserve for the printed page footer, return 0.0 to not reserve any space for a footer.
 @discussion The height returned will be used to calculate the rect passed to webView:drawFooterInRect:.
 */
- (float)webViewFooterHeight:(WebView *)sender
{
    return 0.0;
}

/*!
 @method webView:drawHeaderInRect:
 @param webView The WebView sending the delegate method
 @param rect The NSRect reserved for the header of the page
 @abstract The delegate should draw a header for the sender in the supplied rect.
 */
- (void)webView:(WebView *)sender drawHeaderInRect:(NSRect)rect
{
    
}

/*!
 @method webView:drawFooterInRect:
 @param webView The WebView sending the delegate method
 @param rect The NSRect reserved for the footer of the page
 @abstract The delegate should draw a footer for the sender in the supplied rect.
 */
- (void)webView:(WebView *)sender drawFooterInRect:(NSRect)rect
{
    
}

- (void)dealloc
{
    for (NSString *f in _removeList)
    {
        [[NSFileManager defaultManager] removeItemAtPath:f error:NULL];
    }
}


@end
