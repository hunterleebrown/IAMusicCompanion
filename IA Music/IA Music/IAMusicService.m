//
//  IAMusicService.m
//  IA Music
//
//  Created by Hunter on 10/10/15.
//  Copyright © 2015 Hunter. All rights reserved.
//

#import "IAMusicService.h"
#import "MediaUtils.h"
#import "AFNetworking.h"

@interface IAMusicService ()

@property (nonatomic, strong) NSString *testUrl;
@property (nonatomic, strong) NSString *loadMoreStart;
@property (nonatomic, strong) NSString *fileNameIn;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *urlStr;

@property (nonatomic, strong) NSDictionary *parameters;


@end

@implementation IAMusicService

- (id) initWithQueryString:(NSString *)query {
    self = [super init];
    if(self){
        [self setQueryString:query];
        _searchField = SearchFieldsAll;
    }
    
    return self;
}

- (void)setQueryString:(NSString *)queryString
{
    _queryString = queryString;
    _urlStr = @"https://archive.org/advancedsearch.php";
     

    NSString *searchFieldString;
    switch (self.searchField) {
        case SearchFieldsAll:
            queryString = queryString;
            break;
            
        case SearchFieldsCreator:
            queryString = [NSString stringWithFormat:@"creator:%@", queryString];
            break;
    }
    
    _parameters = @{ @"q" : [NSString stringWithFormat:@"%@ AND NOT collection:web AND NOT collection:webwidecrawl AND mediatype:audio", queryString],
                     @"output" : @"json",
                     @"rows" : @"50"
                     };

}


- (void)setSearchField:(SearchFields)searchField
{
    _searchField = searchField;
}


#pragma mark - AFNetwork fetch

- (void)fetchIASearcDocsWithCompletionHandler:(IAFetchCompletionHandler)completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:_urlStr parameters:_parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        NSLog(@"%@ %@", _urlStr, _parameters);
        completion([self packageJsonResponeDictionary:responseObject]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];

}



- (NSMutableArray *) packageJsonResponeDictionary:(NSDictionary *)jsonResponse{
    
    
//    rawResults = [NSMutableDictionary new];
//    [rawResults setObject:jsonResponse forKey:@"original"];
    NSMutableArray *responseDocs = [NSMutableArray new];
    
    NSDictionary *response = [jsonResponse objectForKey:@"response"];
    NSDictionary *metadata = [jsonResponse objectForKey:@"metadata"];
    
    
    if(response){
        NSArray *docs = [response objectForKey:@"docs"];
        if(docs){
            for(NSDictionary *doc in docs){
                if([doc objectForKey:@"description"] && [doc objectForKey:@"title"]){
                    ArchiveSearchDoc *aDoc = [ArchiveSearchDoc new];
                    [aDoc setRawDoc:doc];
                    [aDoc setIdentifier:[doc objectForKey:@"identifier"]];
                    [aDoc setTitle:[doc objectForKey:@"title"]];
                    
                    if(![doc objectForKey:@"headerImage"]){
                        [aDoc setHeaderImageUrl:[NSString stringWithFormat:@"http://archive.org/services/img/%@", aDoc.identifier]];
//                        ArchiveImage *anImage = [[ArchiveImage alloc] initWithUrlPath:aDoc.headerImageUrl];
//                        [aDoc setArchiveImage:anImage];
                        
                    } else {
                        [aDoc setHeaderImageUrl:[doc objectForKey:@"headerImage"]];
//                        ArchiveImage *anImage = [[ArchiveImage alloc] initWithUrlPath:aDoc.headerImageUrl];
//                        [aDoc setArchiveImage:anImage];
                    }
                    [aDoc setDetails:[doc objectForKey:@"description"]];
                    [aDoc setPublicDate:[doc objectForKey:@"publicdate"]];
                    [aDoc setDate:[doc objectForKey:@"date"]];
                    
                    [aDoc setType:[MediaUtils mediaTypeFromString:[doc objectForKey:@"mediatype"]]];
                    
                    [responseDocs addObject:aDoc];
                }
                
            }
//            [rawResults setObject:responseDocs forKey:@"documents"];
//            [rawResults setObject:[response objectForKey:@"numFound"] forKey:@"numFound"];
        }
    }
    
    if(metadata){
        ArchiveDetailDoc *dDoc = [ArchiveDetailDoc new];
        [dDoc setRawDoc:jsonResponse];
        NSDictionary *metadata = [jsonResponse objectForKey:@"metadata"];
        [dDoc setIdentifier:[metadata objectForKey:@"identifier"]];
        
        if([[metadata objectForKey:@"title"] isKindOfClass:[NSArray class]])
        {
            [dDoc setTitle:[metadata objectForKey:@"title"][0]];
        }
        else
        {
            [dDoc setTitle:[metadata objectForKey:@"title"]];
        }
        
        if(![metadata objectForKey:@"headerImage"]){
            [dDoc setHeaderImageUrl:[NSString stringWithFormat:@"http://archive.org/services/img/%@", dDoc.identifier]];
//            ArchiveImage *anImage = [[ArchiveImage alloc] initWithUrlPath:dDoc.headerImageUrl];
//            [dDoc setArchiveImage:anImage];
        } else {
            [dDoc setHeaderImageUrl:[metadata objectForKey:@"headerImage"]];
//            ArchiveImage *anImage = [[ArchiveImage alloc] initWithUrlPath:dDoc.headerImageUrl];
//            [dDoc setArchiveImage:anImage];
        }
        
        // Descriptions can now be arrays... yay
        if([[metadata objectForKey:@"description"] isKindOfClass:[NSArray class]])
        {
            NSArray *desc = [metadata objectForKey:@"description"];
            NSMutableString *descText = [NSMutableString new];
            
            for(NSObject *obj in desc)
            {
                if([obj isKindOfClass:[NSString class]])
                {
                    [descText appendString:[NSString stringWithFormat:@"%@\n", obj]];
                }
            }
            [dDoc setDetails:descText];
            
        } else
        {
            [dDoc setDetails:[metadata objectForKey:@"description"]];
        }
        
        
        [dDoc setPublicDate:[metadata objectForKey:@"publicdate"]];
        if([metadata objectForKey:@"date"] != nil)
        {
            [dDoc setDate:[metadata objectForKey:@"date"]];
        }
        
        NSMutableArray *files = [NSMutableArray new];
        if([jsonResponse objectForKey:@"files"]){
            for (NSDictionary *file in [jsonResponse objectForKey:@"files"]) {
                ArchiveFile *aFile = [[ArchiveFile alloc]initWithIdentifier:dDoc.identifier withIdentifierTitle:dDoc.title withServer:[jsonResponse objectForKey:@"server"] withDirectory:[jsonResponse objectForKey:@"dir"] withFile:file];
                [files addObject:aFile];
            }
        }
        [dDoc setFiles:files];
        
        [dDoc setType:[MediaUtils mediaTypeFromString:[metadata objectForKey:@"mediatype"]]];
        
        [responseDocs addObject:dDoc];
//        [rawResults setObject:responseDocs forKey:@"documents"];
        
    }
    
//    if(identifier){
//        [rawResults setObject:identifier forKey:@"identifier"];
//    }
    
    
//    if(fileNameIn) {
//        ArchiveFile *aFile;
//        ArchiveDetailDoc *aDoc = [responseDocs objectAtIndex:0];
//        for(ArchiveFile *af in aDoc.files){
//            if([af.name isEqualToString:fileNameIn]){
//                aFile = af;
//            }
//        }
//        if(aFile){
//            
//            
//            if(self.delegate && [self.delegate respondsToSelector:@selector(dataDidFinishLoadingWithArchiveFile:)]){
//                [self.delegate dataDidFinishLoadingWithArchiveFile:aFile];
//            }
//        }
//        
//        
//        
//    } else {
    
//        if(self.delegate && [self.delegate respondsToSelector:@selector(dataDidBecomeAvailableForService:)]){
//            [self.delegate dataDidBecomeAvailableForService:self];
//        }
//    }
    
    return responseDocs;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
    
}


#pragma mark -


- (NSString *)sortStringFromType:(IADataServiceSortType)type{
    
    switch (type) {
        case IADataServiceSortTypeDateDescending:
            return  @"publicdate+desc";
            break;
        case IADataServiceSortTypeDateAscending:
            return @"publicdate+asc";
            break;
            
        case IADataServiceSortTypeDownloadDescending:
            return @"downloads+desc";
            break;
        case IADataServiceSortTypeDownloadAscending:
            return  @"downloads+asc";
            break;
            
        case IADataServiceSortTypeTitleDescending:
            return @"titleSorter+desc";
            break;
            
        case IADataServiceSortTypeTitleAscending:
            return @"titleSorter+asc";
            break;
            
        case IADataServiceSortTypeNone:
            return @"";
            break;
    }
    
}

- (void) searchChangeSortType:(IADataServiceSortType)type
{
    
    if(_identifier){
        _testUrl = [NSString stringWithFormat:_testUrl, _identifier];
    }
    
    NSString *sort = @"";
    if(![[self sortStringFromType:type] isEqualToString:@""])
    {
        sort = [NSString stringWithFormat:@"&sort[]=%@", [self sortStringFromType:type]];
    }
    
    _urlStr = [NSString stringWithFormat:@"%@%@", _testUrl, sort];
    
}

- (void) changeSortType:(IADataServiceSortType)type {
    _loadMoreStart = @"0";
    self.urlStr = [self docsUrlStringsWithType:MediaTypeCollection withIdentifier:_identifier withSort:[self sortStringFromType:type]];
    
}

- (void) setLoadMoreStart:(NSString *)lMS{
    _loadMoreStart = lMS;
    NSString *pre =[NSString stringWithFormat:_testUrl, _identifier];
    self.urlStr = [self docsUrlStringWithTest:pre withStart:_loadMoreStart];
    
}


- (NSString *) docsUrlStringsWithType:(MediaType)type withIdentifier:(NSString *)idString withSort:(NSString *)sort{
    
    _identifier = idString;
    
    if(![sort isEqualToString:@""]){
        sort = [NSString stringWithFormat:@"&sort[]=%@", sort];
    }
    
    if(type != MediaTypeNone ){
        NSString *t = @"";
        if(type == MediaTypeAudio){
            t = @"audio";
        } else if(type == MediaTypeVideo){
            t = @"movies";
        } else if(type == MediaTypeTexts){
            t = @"texts";
        } else if(type == MediaTypeCollection){
            t = @"collection";
        } else if(type == MediaTypeImage){
            t = @"image";
        } else if(type == MediaTypeSoftware){
            t = @"software";
        } else if(type == MediaTypeEtree){
            t = @"etree";
        }
        
        
        _testUrl = @"http://archive.org/advancedsearch.php?q=mediatype:%@+AND+NOT+hidden:true+AND+collection:%@%@&rows=50&output=json";
        
        
        NSString *searchUrl = [NSString stringWithFormat:_testUrl, t, _identifier, sort];
        return [self docsUrlStringWithTest:searchUrl withStart:_loadMoreStart];
        
    } else {
        _testUrl = @"http://archive.org/advancedsearch.php?q=collection:%@%@&rows=50&output=json";
        NSString *searchUrl = [NSString stringWithFormat:_testUrl, _identifier, sort];
        return [self docsUrlStringWithTest:searchUrl withStart:_loadMoreStart];
    }
    
    
    
}


- (NSString *) docsUrlStringWithTest:(NSString *)test withStart:(NSString *)start{
    _testUrl = test;
    return [NSString stringWithFormat:@"%@&start=%@", _testUrl, start];
}

@end
