//
//  MainWindowController.h
//  pkgutilApp
//
//  Created by Kohei on 2014/06/26.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController <NSBrowserDelegate>
{
    IBOutlet NSBrowser *myBrowser;
    IBOutlet NSProgressIndicator *myIndicator;
    
    NSArray *pkgsArray;
    NSArray *filesArray;
}

@end
