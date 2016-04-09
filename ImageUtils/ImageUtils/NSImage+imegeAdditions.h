//
//  NSImage+imegeAdditions.h
//  ImageUtils
//
//  Created by Lan on 15/12/22.
//  Copyright © 2015年 lan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (imegeAdditions)

/**
 *  @author 蓝佑华, 15-12-22 18:12:04
 *
 *  TODO: 将图片用固定的像素写入到文件中
 *
 *  @param URL          路径
 *  @param outputSizePx 像素
 *  @param error        错误
 *
 *  @return 是否成功
 *
 *  @since 1.0
 */
- (BOOL)writePNGToURL:(NSURL*)URL outputSizeInPixels:(NSSize)outputSizePx error:(NSError*__autoreleasing*)error;

/**
 *  @author 蓝佑华, 15-12-22 16:12:41
 *
 *  TODO: 返回图像的pixels像素
 *
 *  @return pixels大小
 *
 *  @since 1.0
 */
- (CGSize)imagePixelsSize;

@end
