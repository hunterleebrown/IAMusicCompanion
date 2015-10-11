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

@interface IAItemViewController ()

@property (nonatomic, strong) IAMusicService *service;
@property (nonatomic, strong) ArchiveDetailDoc *doc;


@property (nonatomic, weak) IBOutlet UIImageView *itemImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation IAItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    _titleLabel.text = self.searchDoc.title;
    [_itemImageView setImageWithURL:[NSURL URLWithString:self.searchDoc.itemImageUrl]];
    
    _service = [IAMusicService new];
    _service.identifier = _searchDoc.identifier;
    
    IAItemViewController __weak *weakSelf = self;
    [_service fetchIASearcDocsWithCompletionHandler:^(NSArray<ArchiveSearchDoc *> *docs) {
        
        if(docs.count > 0)
        {
            weakSelf.doc = (ArchiveDetailDoc *)docs[0];
        }
        
    }];
    
    UIFontDescriptor *userFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
    float userFontSize = [userFont pointSize];
    UIFont *font = [UIFont fontWithName:@"ArialHebrew-Bold" size:userFontSize];
    
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
