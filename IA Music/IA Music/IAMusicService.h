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


typedef void (^IAFetchCompletionHandler)(NSMutableDictionary *response);

@interface IAMusicService : NSObject

@property (nonatomic, strong) NSString *queryString;
@property (nonatomic) SearchFields searchField;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic) int start;



//- (id) initWithQueryString:(NSString *)query;
//- (id) initWithIAIdentifier:(NSString *)identifier;

- (void)fetchIASearcDocsWithCompletionHandler:(IAFetchCompletionHandler)completion;

@end
