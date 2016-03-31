//
//  NSImage+imegeAdditions.m
//  ImageUtils
//
//  Created by Lan on 15/12/22.
//  Copyright © 2015年 lan. All rights reserved.
//

#import "NSImage+imegeAdditions.h"

@implementation NSImage (imegeAdditions)


/**
 *  @author 蓝佑华, 15-12-22 17:12:55
 *
 *  TODO: 按照像素的大小直接写入到文件中
 *
 *  @param URL          路径
 *  @param outputSizePx 输出像素大小
 *  @param error        错误
 *
 *  @return 是否正确
 *
 *  @since 1.0
 */
- (BOOL)writePNGToURL:(NSURL*)URL outputSizeInPixels:(NSSize)outputSizePx error:(NSError*__autoreleasing*)error
{
    BOOL result = YES;
    NSImage* scalingImage = [NSImage imageWithSize:[self size] flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
        [self drawAtPoint:NSMakePoint(0.0, 0.0) fromRect:dstRect operation:NSCompositeSourceOver fraction:1.0];
        return YES;
    }];
    NSRect proposedRect = NSMakeRect(0.0, 0.0, outputSizePx.width, outputSizePx.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    CGContextRef cgContext = CGBitmapContextCreate(NULL, proposedRect.size.width, proposedRect.size.height, 8, 4*proposedRect.size.width, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    NSGraphicsContext* context = [NSGraphicsContext graphicsContextWithGraphicsPort:cgContext flipped:NO];
    CGContextRelease(cgContext);
    CGImageRef cgImage = [scalingImage CGImageForProposedRect:&proposedRect context:context hints:nil];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)(URL), kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, cgImage, nil);
    if(!CGImageDestinationFinalize(destination))
    {
        NSDictionary* details = @{NSLocalizedDescriptionKey:@"Error writing PNG image"};
        [details setValue:@"ran out of money" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"SSWPNGAdditionsErrorDomain" code:10 userInfo:details];
        result = NO;
    }
    CFRelease(destination);
    return result;
}

/**
 *  @author 蓝佑华, 15-12-22 16:12:41
 *
 *  TODO: 返回图像的pixels像素
 *
 *  @return pixels大小
 *
 *  @since 1.0
 */
- (CGSize)imagePixelsSize
{
    NSImageRep *rep = [[self representations] objectAtIndex:0];
    NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
    return imageSize;
}


@end
