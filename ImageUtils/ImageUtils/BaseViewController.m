//
//  BaseViewController.m
//  ImageUtils
//
//  Created by Lan on 15/12/22.
//  Copyright © 2015年 lan. All rights reserved.
//

#import "BaseViewController.h"
#import "NSImage+imegeAdditions.h"
#import "DragDropView.h"

#define fileNameDic        @"fileName"
#define fileDirectoryDic   @"fileDirectory"
#define fileTotalPathDic   @"fileTotalPath"

typedef void(^ProgressBlock) (CGFloat progress);
typedef void(^CommonBlock) (id arg);

@interface BaseViewController ()<NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, DragDropViewDelegate>

//=========== 图片生成器 ==============
//打开文件
@property (strong) IBOutlet NSButton            *selectFileBtn;
//2倍图标签
@property (strong) IBOutlet NSButton            *doubleImageCheck;
//1倍图标签
@property (strong) IBOutlet NSButton            *oneImageCheck;
//多倍图处理进度
@property (strong) IBOutlet NSProgressIndicator *createMutipleImageProgress;
//打开的文件列表
@property (strong) IBOutlet NSTableView         *fileListTableView;
//百分比标签
@property (strong) IBOutlet NSTextField         *percentLabel;
//生成倍图按钮
@property (strong) IBOutlet NSButton            *createImageBtn;
//拖拽文件生成内容
@property (strong) IBOutlet DragDropView        *dragDropView;


//========= 色值转化工具 ===============
//16进制输入框
@property (strong) IBOutlet NSTextField         *OxInputFeild;
//RGB输入框
@property (strong) IBOutlet NSTextField         *RGBInputField;
//色值转化
@property (strong) IBOutlet NSButton            *colorConvertbtn;

//文件夹下面各个@3x的文件路径
@property (nonatomic, strong) NSMutableArray    *filePathArray;

//打开的文件目录的路径
@property (nonatomic, strong) NSString          *openDirectory;

//多倍图数组
@property (nonatomic, strong) NSMutableArray    *mutipleImageArray;



@end

@implementation BaseViewController

#pragma mark -------------life cycle---------------
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self initView];
    [self initData];
}

/**
 *  @author 蓝佑华, 15-12-23 09:12:15
 *
 *  TODO: 初始化界面
 *
 *  @since 1.0
 */
- (void)initView
{
    [self.oneImageCheck setState:0];
    [self.doubleImageCheck setState:1];
    self.createMutipleImageProgress.minValue = 0.0f;
    self.createMutipleImageProgress.maxValue = 1.0f;
    [self initTableView];
}

/**
 *  @author 蓝佑华, 15-12-23 12:12:00
 *
 *  TODO: 初始化TableView
 *
 *  @since 1.0
 */
- (void)initTableView
{
    self.fileListTableView.dataSource = self;
    self.fileListTableView.delegate = self;
    self.dragDropView.delegate = self;
    [self.fileListTableView setAllowsColumnResizing:YES];
}

/**
 *  @author 蓝佑华, 15-12-23 10:12:13
 *
 *  TODO: 初始化数据
 *
 *  @since 1.0
 */
- (void)initData
{
    self.mutipleImageArray = [NSMutableArray array];
    [self.mutipleImageArray addObject:@(2)];
}

#pragma mark ---------   IBAction ------------

/**
 *  @author 蓝佑华, 15-12-22 17:12:49
 *
 *  TODO: 打开文件
 *
 *  @param sender 按钮
 *
 *  @since 1.0
 */
- (IBAction)selectFileBtn_ClickEvent:(id)sender {
    __block NSOpenPanel *panel = [NSOpenPanel openPanel];
    __weak BaseViewController *weakSelf = self;
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel beginSheetModalForWindow:[self.view window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSLog(@"%@",[panel URL]);
            weakSelf.openDirectory = [panel URL].path;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[panel URL].path error:nil];
            [weakSelf filterFileTypeWithOpenDirectory:[panel URL].path withFileArray:array];
        }
        panel=nil;
    }];
}

/**
 *  @author 蓝佑华, 15-12-22 14:12:16
 *
 *  TODO: 生成倍图
 *
 *  @param sender 内容
 *
 *  @since 1.0
 */
- (IBAction)createImageBtn_ClickEvent:(id)sender {
    
    __weak BaseViewController *weakSelf = self;
    [self batchCreateMutipleImagesWithfilePaths:self.filePathArray progress:^(CGFloat progress) {
        weakSelf.createMutipleImageProgress.doubleValue = progress;
        weakSelf.percentLabel.stringValue = [NSString stringWithFormat:@"%2.0f%%",progress*100];
    } completion:^(id arg) {
         weakSelf.percentLabel.stringValue = @"完成";
    }];
}

/**
 *  @author 蓝佑华, 15-12-23 09:12:11
 *
 *  TODO: 是否生成1倍图，默认生成
 *
 *  @param sender 事件
 *
 *  @since 1.0
 */
- (IBAction)oneCheckbtn_ClickEvent:(id)sender {
    
    BOOL isExist = NO;
    for (int i = 0 ; i<self.mutipleImageArray.count; i++) {
        NSInteger mutiple = [self.mutipleImageArray[i] integerValue];
        if (mutiple == 1) {
            isExist = YES;
            [self.mutipleImageArray removeObject:self.mutipleImageArray[i]];
            return;
        }
    }
    if (!isExist){
        [self.mutipleImageArray addObject:@(1)];
    }
}

/**
 *  @author 蓝佑华, 15-12-23 10:12:16
 *
 *  TODO: 是否生成2倍图
 *
 *  @param sender check
 *
 *  @since 1.0
 */
- (IBAction)doubleCheckbtn_ClickEvent:(id)sender {
    
    BOOL isExist = NO;
    for (int i = 0 ; i<self.mutipleImageArray.count; i++) {
        NSInteger mutiple = [self.mutipleImageArray[i] integerValue];
        if (mutiple == 2) {
            isExist = YES;
            [self.mutipleImageArray removeObject:self.mutipleImageArray[i]];
            return;
        }
    }
    if (!isExist){
        [self.mutipleImageArray addObject:@(2)];
    }
}

/**
 *  @author 蓝佑华, 15-12-23 15:12:10
 *
 *  TODO: 色值转换按钮
 *
 *  @param sender 按钮
 *
 *  @since 1.0
 */
- (IBAction)colorConvertBtn_ClickEvent:(id)sender {
    
    NSString *OxString = self.OxInputFeild.stringValue;
//    NSString *rgbString = self.RGBInputField.stringValue;
    
    if (![OxString hasPrefix:@"#"] || OxString.length != 7) {
        NSLog(@"16进制格式不正确");
        self.RGBInputField.stringValue = @"";
    }else{
        NSString *tmpString = [OxString substringFromIndex:1];
        unsigned long  red = strtoul([[tmpString substringWithRange:NSMakeRange(0, 2)] UTF8String],0,16);
        unsigned long  green = strtoul([[tmpString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16);
        unsigned long  blue = strtoul([[tmpString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16);
        self.RGBInputField.stringValue = [NSString stringWithFormat:@"%2lu,%2lu,%2lu",red,green,blue];
        return;
    }
//    if ([rgbString componentsSeparatedByString:@","].count != 3) {
//        NSLog(@"rgb格式不正确");
//        self.OxInputFeild.stringValue = @"";
//    }else{
//        NSArray *array = [rgbString componentsSeparatedByString:@","];
//        NSString *redString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[array[0] intValue]]];
//        NSString *greenString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[array[1] intValue]]];
//        NSString *blueString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[array[2] intValue]]];
//        self.OxInputFeild.stringValue = [NSString stringWithFormat:@"#%@%@%@",redString,greenString,blueString];
//        return;
//    }
    
}

#pragma mark ---------  Notification --------------

/**
 *  @author 蓝佑华, 15-12-23 16:12:35
 *
 *  TODO: 文本变化回调
 *
 *  @param notification 通知
 *
 *  @since 1.0
 */
- (void)textDidChange:(NSNotification *)notification
{
    NSLog(@"%@", notification.object);
    NSLog(@"%@", notification.userInfo);
    
}

#pragma mark ---------  private Method ------------

/**
 *  @author 蓝佑华, 15-12-22 17:12:59
 *
 *  TODO: 批量生成多倍图
 *
 *  @param filePaths  文件路径 字典数组，字典键值位于该文件最上方
 *  @param progress   进度
 *  @param completion 完成
 *
 *  @since 1.0
 */
- (void)batchCreateMutipleImagesWithfilePaths:(NSArray *)filePaths progress:(ProgressBlock)progress completion:(CommonBlock)completion
{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         for (NSInteger i = 0; i<filePaths.count; i++) {
             NSDictionary *fileDic = filePaths[i];
             [self createMutipleImageWith:[fileDic objectForKey:fileTotalPathDic] MutipleArray:self.mutipleImageArray targetDirectory:self.openDirectory];
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (progress) progress( (CGFloat)i /(CGFloat)filePaths.count);
             });
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             if (progress) progress(1);
             if (completion) completion(self.openDirectory);
         });
     });
}


/**
 *  @author 蓝佑华, 15-12-22 14:12:56
 *
 *  TODO: 过滤文件类型
 *
 *  @param urls 文件地址
 *  @param type 类型
 *
 *  @return 返回过滤后的文件地址
 *
 *  @since 1.0
 */
- (void)filterFileTypeWithOpenDirectory:(NSString *)directorypath withFileArray:(NSArray *)fileArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *fileName in fileArray) {
            if ([[fileName lowercaseString] hasSuffix:@"@3x.png"] ) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@",directorypath,fileName];
                NSDictionary *fileDic = @{fileNameDic:fileName,fileDirectoryDic:directorypath,fileTotalPathDic:filePath};
                [array addObject:fileDic];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.createMutipleImageProgress.doubleValue = 0;
            self.percentLabel.stringValue = @"0%";
            if (array.count == 0) {
                self.createImageBtn.enabled = NO;
            }else{
                self.createImageBtn.enabled = YES;
            }
            self.filePathArray = array;
            [self.fileListTableView reloadData];
        });
    });
}

/**
 *  @author 蓝佑华, 15-12-22 14:12:40
 *
 *  TODO: 生成多倍图
 *
 *  @param filePath     文件路径
 *  @param mutipleArray 倍图传入NSNumber;
 *
 *  @since 1.0
 */
- (void)createMutipleImageWith:(NSString *)filePath MutipleArray:(NSArray *)mutipleArray targetDirectory:(NSString *)directory;
{
//    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"文件不存在");
        return;
    }
    BOOL isDirectory = NO;
    if (!([[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDirectory] &&isDirectory)) {
        NSLog(@"目标文件不存在");
        return;
    }
    if (self.mutipleImageArray.count == 0) {
        NSLog(@"没有可生成的倍率");
        return;
    }
    
    NSImage *image = [[NSImage alloc]initWithContentsOfFile:filePath];
    
    NSMutableString *tmpFileName = [[NSMutableString alloc] initWithString:[[[filePath stringByDeletingPathExtension] lastPathComponent] lowercaseString]];
    [tmpFileName replaceOccurrencesOfString:@"@3x" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, tmpFileName.length)];
    for (NSNumber *number in mutipleArray) {
        
        NSInteger scaleHeight = [image imagePixelsSize].height * [number integerValue] / 3;
        NSInteger scaleWidth = [image imagePixelsSize].width * [number integerValue]  / 3;
        
        NSString *newFileName = [NSString stringWithFormat:@"/%@@%@x.png",tmpFileName,number];
        
        if ([number integerValue] == 1) {
            newFileName = [NSString stringWithFormat:@"/%@.png",tmpFileName];
        }
        
        NSString *targetFilePath = [directory stringByAppendingString:newFileName];
        [image writePNGToURL:[NSURL fileURLWithPath:targetFilePath] outputSizeInPixels:CGSizeMake(scaleWidth, scaleHeight) error:nil];
    }
}

#pragma mark --------------- NSTableViewDataSource -------------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.filePathArray.count;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary *fileDic = self.filePathArray[row];
    if ([tableColumn.identifier isEqualToString:@"fileName"]) {
        return [fileDic objectForKey:fileNameDic];
    }else if([tableColumn.identifier isEqualToString:@"fileDirectory"]){
        return [fileDic objectForKey:fileDirectoryDic];
    }else{
        return nil;
    }
}

#pragma mark -------------- DragDropViewDelegate ---------------------

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
- (void)dragDropView:(DragDropView *)dragDropView FileUrl:(NSString *)fileUrl
{
    self.openDirectory = fileUrl;
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fileUrl error:nil];
    [self filterFileTypeWithOpenDirectory:fileUrl withFileArray:array];

}

@end
