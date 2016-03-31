//
//  DragDropView.m
//  ImageUtils
//
//  Created by Lan on 15/12/24.
//  Copyright © 2015年 lan. All rights reserved.
//

#import "DragDropView.h"

@implementation DragDropView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self =  [super initWithFrame:frameRect];
    if (self) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }
    return  self;
}

/**
 *  @author 蓝佑华, 15-12-24 16:12:46
 *
 *  TODO: 进入会触发这个函数
 *
 *  @param sender 托动信息
 *
 *  @return 拖动操作
 *
 *  @since 1.0
 */
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

/**
 *  @author 蓝佑华, 15-12-24 16:12:29
 *
 *  TODO: 挡在View中松开时调用
 *
 *  @param sender 拖拽信息
 *
 *  @return YES
 *
 *  @since 1.0
 */
-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    // 1）、获取拖动数据中的粘贴板
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    // 2）、从粘贴板中提取我们想要的NSFilenamesPboardType数据，这里获取到的是一个文件链接的数组，里面保存的是所有拖动进来的文件地址，如果你只想处理一个文件，那么只需要从数组中提取一个路径就可以了。
    NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
    // 3）、将接受到的文件链接数组通过代理传送
    if(self.delegate && [self.delegate respondsToSelector:@selector(dragDropView:FileUrl:)])
        [self.delegate dragDropView:self FileUrl:list.firstObject];
    return YES;
}

@end
