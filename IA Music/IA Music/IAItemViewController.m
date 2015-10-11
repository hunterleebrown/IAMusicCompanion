//
//  IAItemViewController.m
//  IA Music
//
//  Created by Hunter on 10/10/15.
//  Copyright © 2015 Hunter. All rights reserved.
//

#import "IAItemViewController.h"
#import "IAMusicService.h"
#import "UIImageView+AFNetworking.h"
#import "ArchiveFile.h"

@interface IAItemViewController ()

@property (nonatomic, strong) IAMusicService *service;
@property (nonatomic, strong) ArchiveDetailDoc *doc;

@property (nonatomic, weak) IBOutlet UIImageView *itemImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) NSMutableDictionary *organizedMediaFiles;

@end

@implementation IAItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    _organizedMediaFiles = [NSMutableDictionary new];

    
    _titleLabel.text = self.searchDoc.title;
    [_itemImageView setImageWithURL:[NSURL URLWithString:self.searchDoc.itemImageUrl]];
    
    _service = [IAMusicService new];
    _service.identifier = _searchDoc.identifier;
    
    IAItemViewController __weak *weakSelf = self;
    [_service fetchIASearcDocsWithCompletionHandler:^(NSMutableDictionary *response) {
        
        if(((NSMutableArray *)response[@"documents"]).count > 0)
        {
            weakSelf.doc = (ArchiveDetailDoc *)((NSMutableArray *)response[@"documents"])[0];
            [weakSelf orgainizeMediaFiles];
            
        }
        
        
    }];
    
    
}


- (void)setSearchDoc:(ArchiveSearchDoc *)searchDoc
{
    _searchDoc = searchDoc;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadDoc
{
    _titleLabel.text = _doc.title;
    [_itemImageView setImageWithURL:[NSURL URLWithString:_doc.itemImageUrl]];

}


- (void) orgainizeMediaFiles{

    NSMutableArray *files = [NSMutableArray new];
    NSMutableArray *filteredOutOthers = [NSMutableArray new];
    for(ArchiveFile *f in _doc.files)
    {
        if(f.format != FileFormatOther)
        {
            [filteredOutOthers addObject:f];
        }
    }
    
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"track" ascending:YES];
    [files addObjectsFromArray:[filteredOutOthers sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]]];
    
    
    for(ArchiveFile *f in files){
        if([_organizedMediaFiles objectForKey:[NSNumber numberWithInt:f.format]] != nil){
            
            if(f.format == FileFormatPNG && [[f.file objectForKey:@"source"] isEqualToString: @"derivative"] )
            { } else {
                [[_organizedMediaFiles objectForKey:[NSNumber numberWithInt:f.format]] addObject:f];
            }
            
        } else {
            
            if(f.format == FileFormatPNG && [[f.file objectForKey:@"source"] isEqualToString: @"derivative"] )
            { } else {
                NSMutableArray *filesForFormat = [NSMutableArray new];
                [filesForFormat addObject:f];
                [_organizedMediaFiles setObject:filesForFormat forKey:[NSNumber numberWithInt:f.format]];            }
        }
    }
    
    //    FileFormat64KbpsMP3 = 8,
    //    FileFormat128KbpsMP3 = 12,
    //    FileFormatMP3 = 13,
    //    FileFormat96KbpsMP3 = 14,
    //
    // REMOVING ALL AUDIO BESIDES VBR MP3
    if([_organizedMediaFiles objectForKey:[NSNumber numberWithInt:FileFormat128KbpsMP3]] != nil){
        [_organizedMediaFiles removeObjectForKey:[NSNumber numberWithInt:FileFormat128KbpsMP3]];
    }
    if([_organizedMediaFiles objectForKey:[NSNumber numberWithInt:FileFormatMP3]] != nil){
        [_organizedMediaFiles removeObjectForKey:[NSNumber numberWithInt:FileFormatMP3]];
    }
    if([_organizedMediaFiles objectForKey:[NSNumber numberWithInt:FileFormat96KbpsMP3]] != nil){
        [_organizedMediaFiles removeObjectForKey:[NSNumber numberWithInt:FileFormat96KbpsMP3]];
    }
    if([_organizedMediaFiles objectForKey:[NSNumber numberWithInt:FileFormat64KbpsMP3]] != nil){
        [_organizedMediaFiles removeObjectForKey:[NSNumber numberWithInt:FileFormat64KbpsMP3]];
    }
    
    if(_doc.type != MediaTypeTexts)
    {
        if([_organizedMediaFiles objectForKey:[NSNumber numberWithInt:FileFormatDjVuTXT]] != nil){
            [_organizedMediaFiles removeObjectForKey:[NSNumber numberWithInt:FileFormatDjVuTXT]];
        }
        if([_organizedMediaFiles objectForKey:[NSNumber numberWithInt:FileFormatTxt]] != nil){
            [_organizedMediaFiles removeObjectForKey:[NSNumber numberWithInt:FileFormatTxt]];
        }
    }
    
    
    if([_organizedMediaFiles objectForKey:[NSNumber numberWithInt:FileFormatVBRMP3]] != nil)
    {
        // Filtering out repeated titles in VBR List
        NSArray *vbrs = [_organizedMediaFiles objectForKey:[NSNumber numberWithInt:FileFormatVBRMP3]];
        NSMutableSet* existingNames = [NSMutableSet set];
        NSMutableArray* filteredArray = [NSMutableArray array];
        for (ArchiveFile *file in vbrs) {
            if (![existingNames containsObject:file.title]) {
                [existingNames addObject:file.title];
                [filteredArray addObject:file];
            }
        }
        [_organizedMediaFiles setObject:filteredArray forKey:[NSNumber numberWithInt:FileFormatVBRMP3]];
    }
    
//    [mediaTable reloadData];
    
}


@end
