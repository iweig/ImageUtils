//
//  AppDelegate.m
//  ImageUtils
//
//  Created by Lan on 15/12/22.
//  Copyright © 2015年 lan. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

//@property (strong,nonatomic) BaseView       *base;

@property (strong,nonatomic) BaseViewController     *baseViewController;

@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your applicatio
    self.baseViewController = [[BaseViewController alloc]initWithNibName:@"BaseViewController" bundle:nil];
    self.window.contentViewController = self.baseViewController;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
