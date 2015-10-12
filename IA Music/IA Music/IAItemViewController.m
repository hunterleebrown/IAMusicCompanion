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
#import "MediaFileCell.h"
#import "MediaFileHeaderCell.h"
#import "MediaUtils.h"

@interface IAItemViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IAMusicService *service;
@property (nonatomic, strong) ArchiveDetailDoc *doc;

@property (nonatomic, weak) IBOutlet UIImageView *itemImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITableView *mediaTable;


@property (nonatomic, strong) NSMutableDictionary *organizedMediaFiles;

@end

@implementation IAItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    _organizedMediaFiles = [NSMutableDictionary new];

    _mediaTable.rowHeight = UITableViewAutomaticDimension;
    _mediaTable.estimatedRowHeight = 44;
    _mediaTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];


    
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
            [_mediaTable reloadData];
        }
        
        
    }];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self makeTranslToolbar:self.navigationController.navigationBar];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _titleLabel.preferredMaxLayoutWidth = _titleLabel.frame.size.width;
    [_titleLabel sizeToFit];
    [self.view layoutIfNeeded];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self setNeedsStatusBarAppearanceUpdate];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.itemImageView setImage:nil];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)makeTranslToolbar:(UINavigationBar *)toolbar
{
    [toolbar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    toolbar.backgroundColor = [UIColor clearColor];
    [toolbar setTintColor:[UIColor lightGrayColor]];
    
    toolbar.shadowImage = [UIImage new];
    toolbar.translucent = YES;
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
    
    // Removing Images
    for(NSNumber *num in @[[NSNumber numberWithInt:FileFormatH264],
                           [NSNumber numberWithInt:FileFormatH264HD],
                           [NSNumber numberWithInt:FileFormatMPEG4],
                           [NSNumber numberWithInt:FileFormatPNG],
                           [NSNumber numberWithInt:FileFormatJPEG],
                           [NSNumber numberWithInt:FileFormatPNG15],
                           [NSNumber numberWithInt:FileFormatGIF],
                           [NSNumber numberWithInt:FileFormatImage]])
    {
        if([_organizedMediaFiles objectForKey:num] != nil){
            [_organizedMediaFiles removeObjectForKey:num];
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

#pragma mark - Table Stuff
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(_organizedMediaFiles.count == 0){
        return @"";
    }
    
    ArchiveFile *firstFile;
    firstFile = [[_organizedMediaFiles objectForKey:[[_organizedMediaFiles allKeys]  objectAtIndex:section]] objectAtIndex:0];
    return [firstFile.file objectForKey:@"format"];
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MediaFileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell"];
    
    if(_organizedMediaFiles.count > 0){
        ArchiveFile *aFile = [[_organizedMediaFiles objectForKey:[[_organizedMediaFiles allKeys]  objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        //        cell.fileTitle.text = aFile.title;
        cell.fileTitle.text = [NSString stringWithFormat:@"%@%@",aFile.track ? [NSString stringWithFormat:@"%ld ",(long)aFile.track] : @"",aFile.title];
        cell.fileFormat.text = [aFile.file objectForKey:@"format"];
        cell.durationLabel.text = [aFile.file objectForKey:@"duration"];
        cell.fileName.text = aFile.name;
        
    }
    
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_organizedMediaFiles.count > 0){
        ArchiveFile *aFile = [[_organizedMediaFiles objectForKey:[[_organizedMediaFiles allKeys]  objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        if(aFile.format == FileFormatJPEG || aFile.format == FileFormatGIF || aFile.format == FileFormatPNG || aFile.format == FileFormatImage) {
//            MediaImageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mediaImageViewController"];
//            [vc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
//            ArchiveImage *image = [[ArchiveImage alloc] initWithUrlPath:aFile.url];
//            [vc setImage:image];
//            [self presentViewController:vc animated:YES completion:nil];
        } else if (aFile.format == FileFormatDjVuTXT || aFile.format == FileFormatProcessedJP2ZIP || aFile.format == FileFormatTxt) {
//            ArchivePageViewController *pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"archivePageViewController"];
//            [pageViewController setIdentifier:self.searchDoc.identifier];
//            [pageViewController setBookFile:aFile];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenBookViewer" object:pageViewController];
        } else if (aFile.format == FileFormatEPUB) {
//            self.externalUrl = [NSURL URLWithString:aFile.url];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Open Web Page To Save EPUB Book" message:@"Do you want to open Safari?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
//            [alert show];
            
        } else {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddToPlayerListFileAndPlayNotification" object:aFile];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenMediaPlayer" object:nil];
            
            
        }
    }
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    MediaFileHeaderCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"mediaHeaderCell"];
    
    if(_organizedMediaFiles.count > 0){
        ArchiveFile *firstFile;
        firstFile = [[_organizedMediaFiles objectForKey:[[_organizedMediaFiles allKeys]  objectAtIndex:section]] objectAtIndex:0];
        NSString *format = [firstFile.file objectForKey:@"format"];
        
        headerCell.sectionHeaderLabel.text = format;
        [headerCell setTypeLabelIconFromFileTypeString:format];
        
        MediaType type = [MediaUtils mediaTypeFromFileFormat:[MediaUtils formatFromString:format]];
        headerCell.sectionPlayAllButton.hidden = type == MediaTypeNone || type == MediaTypeTexts;
        [headerCell.sectionPlayAllButton setTag:section];
        
//        [headerCell.sectionPlayAllButton addTarget:self action:@selector(playAll:) forControlEvents:UIControlEventTouchUpInside];
    }
    return headerCell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return _organizedMediaFiles.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_organizedMediaFiles.count == 0){
        return 0;
    }
    
    return [[_organizedMediaFiles objectForKey:[[_organizedMediaFiles allKeys]  objectAtIndex:section]] count];
}





@end
