//
//  ArchiveFile.h
//  The Internet Archive Companion
//
//  Created by Hunter on 2/6/13.
//  Copyright (c) 2013 Hunter Lee Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FileFormat) {
    FileFormatOther,
    FileFormatJPEG,
    FileFormatGIF,
    FileFormatH264,
    FileFormatMPEG4,
    FileFormat512kbMPEG4,
    FileFormatH264HD,
    FileFormatDjVuTXT,
    FileFormatTxt,
    FileFormatProcessedJP2ZIP,
    FileFormatVBRMP3,
    FileFormat64KbpsMP3,
    FileFormat128KbpsMP3,
    FileFormatMP3,
    FileFormat96KbpsMP3,
    FileFormatPNG15,
    FileFormatEPUB,
    FileFormatImage,
    FileFormatPNG,
};



@interface ArchiveFile : NSObject

@property (nonatomic, strong) NSDictionary *file;
@property (nonatomic)         FileFormat   format;
@property (nonatomic, strong) NSString     *name;
@property (nonatomic, strong) NSString     *title;
@property (nonatomic)         NSInteger    track;
@property (nonatomic, strong) NSString     *url;
@property (nonatomic, strong) NSString     *identifier;
@property (nonatomic, strong) NSString     *server;
@property (nonatomic, strong) NSString     *directory;
@property (nonatomic, strong) NSString     *height;
@property (nonatomic, strong) NSString     *width;
@property (nonatomic, strong) NSString     *identifierTitle;
@property (nonatomic)         NSInteger    size;



- (id) initWithIdentifier:(NSString *)identifier withIdentifierTitle:(NSString *)identifierTitle withServer:(NSString *)server withDirectory:(NSString *)dir withFile:(NSDictionary *)file;


@end


