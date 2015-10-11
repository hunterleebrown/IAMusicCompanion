//
//  IAMusicService.h
//  IA Music
//
//  Created by Hunter on 10/10/15.
//  Copyright © 2015 Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArchiveSearchDoc.h"

typedef NS_ENUM(NSUInteger, IADataServiceSortType)
{
    IADataServiceSortTypeDateDescending,
    IADataServiceSortTypeDateAscending,
    IADataServiceSortTypeDownloadDescending,
    IADataServiceSortTypeDownloadAscending,
    IADataServiceSortTypeTitleAscending,
    IADataServiceSortTypeTitleDescending,
    IADataServiceSortTypeNone,
};

typedef NS_ENUM(NSUInteger, SearchFields)
{
    SearchFieldsAll = 0,
    SearchFieldsCreator = 1,
};


typedef void (^IAFetchCompletionHandler)(NSArray<ArchiveSearchDoc *> *docs);

@interface IAMusicService : NSObject

@property (nonatomic, strong) NSString *queryString;
@property (nonatomic) SearchFields searchField;

- (id) initWithQueryString:(NSString *)query;
- (void)fetchIASearcDocsWithCompletionHandler:(IAFetchCompletionHandler)completion;

@end
