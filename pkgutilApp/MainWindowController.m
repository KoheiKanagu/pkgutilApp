//
//  MainWindowController.m
//  pkgutilApp
//
//  Created by Kohei on 2014/06/26.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

#import "MainWindowController.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        pkgsArray = [self pkgutil:@[@"-c",
                                    @"pkgutil --pkgs"]];
    }
    return self;
}

-(NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column
{
    switch (column) {
        case 0:
            return pkgsArray.count;
            break;
            
        case 1:
            return filesArray.count;
            break;
            
        default:
            break;
    }
    return 0;
}


-(IBAction)forgetButton:(id)sender
{
    NSInteger selectedNo = [myBrowser selectedRowInColumn:0];
    if(selectedNo < 0){
        return;
    }
    NSString *pkgName = pkgsArray[selectedNo];
    NSString *source = [NSString stringWithFormat:@"do shell script \"sudo pkgutil --forget %@\" with administrator privileges", pkgName];
    NSAppleScript *script = [[NSAppleScript alloc]initWithSource:source];
    
    NSDictionary *errors = [NSDictionary dictionary];
    [script executeAndReturnError:&errors];
    
    if(![errors objectForKey:NSAppleScriptErrorNumber]){
        pkgsArray = [self pkgutil:@[@"-c",
                                    @"pkgutil --pkgs"]];
        [myBrowser reloadColumn:0];
        NSLog(@"done");
    }
}


-(CGFloat)browser:(NSBrowser *)browser shouldSizeColumn:(NSInteger)columnIndex forUserResize:(BOOL)forUserResize toWidth:(CGFloat)suggestedWidth
{
    switch (columnIndex) {
        case 0:
            return 400;
            break;
            
        case 1:
            return 800;
            break;
            
        default:
            break;
    }
    return 0;
}


-(void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
    switch (column) {
        case 0:
            [cell setTitle:pkgsArray[row]];
            [cell setLeaf:NO];
            break;
            
        case 1:
            [cell setTitle:filesArray[row]];
            [cell setLeaf:YES];
            break;
            
        default:
            break;
    }
}


-(void)browser:(NSBrowser *)browser didChangeLastColumn:(NSInteger)oldLastColumn toColumn:(NSInteger)column
{
    if(column == 0 || browser.selectedColumn == 0){
        NSInteger index = [browser selectedRowInColumn:oldLastColumn];
        if(index >= 0){
            NSString *pkgName = pkgsArray[index];
            NSString *arg = [NSString stringWithFormat:@"pkgutil --files %@", pkgName];
            
            [myIndicator startAnimation:nil];
            [browser setEnabled:NO];
            
            filesArray = [self pkgutil:@[@"-c",
                                         arg]];

            [browser setEnabled:YES];
            [myIndicator stopAnimation:nil];

            [browser reloadColumn:1];
        }
    }
}


-(NSArray *)pkgutil:(NSArray *)arg
{
    NSTask *task = [[NSTask alloc]init];
    NSPipe *pipe = [[NSPipe alloc]init];
    
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:arg];
    [task setStandardOutput:pipe];
    [task launch];
    
    NSFileHandle *handle = [pipe fileHandleForReading];
    NSData *data = [handle readDataToEndOfFile];
    
    NSString *string = [[NSString alloc]initWithData:data
                                            encoding:NSUTF8StringEncoding];
    
    return [string componentsSeparatedByString:@"\n"];
}

@end
