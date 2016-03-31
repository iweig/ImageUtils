//
//  DragDropView.h
//  ImageUtils
//
//  Created by Lan on 15/12/24.
//  Copyright © 2015年 lan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DragDropView;
@protocol DragDropViewDelegate <NSObject>

/**
 *  @author 蓝佑华, 15-12-24 16:12:14
 *
 *  TODO: 拖动事件回调
 *
 *  @param dragDropView 拖动View
 *  @param fileUrl      文件URL
 *
 *  @since 1.0
 */
- (void)dragDropView:(DragDropView *)dragDropView  FileUrl:(NSString *)fileUrl;

@end

@interface DragDropView : NSView

@property (nonatomic, assign) id<DragDropViewDelegate> delegate;

@end
