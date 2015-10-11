//
//  ArchiveSearchItem.h
//  The Internet Archive Companion
//
//  Created by Hunter on 1/27/13.
//  Copyright (c) 2013 Hunter Lee Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ArchiveImage.h"

typedef NS_ENUM(NSUInteger, MediaType) {
    MediaTypeNone,
    MediaTypeAudio,
    MediaTypeVideo,
    MediaTypeTexts,
    MediaTypeImage,
    MediaTypeCollection,
    MediaTypeAny,
    MediaTypeSoftware,
    MediaTypeEtree,
    
};

@interface ArchiveSearchDoc : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *itemImageUrl;
@property (strong, nonatomic) NSString *details;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *publicDate;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *creator;

@property (strong, nonatomic) NSDictionary *rawDoc;
@property (nonatomic) MediaType type;


@end



@interface ArchiveDetailDoc : ArchiveSearchDoc

@property (strong, nonatomic) NSString *uploader;
@property (strong, nonatomic) NSArray *files;

@end