//
//  IAMCSearchViewController.m
//  IA Music
//
//  Created by Hunter on 10/10/15.
//  Copyright © 2015 Hunter. All rights reserved.
//

#import "IAMCSearchViewController.h"
#import "IAMusicService.h"
#import "SearchTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "IAItemViewController.h"


@interface IAMCSearchViewController ()<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *searchTableView;

@property (nonatomic, strong) IAMusicService *service;

@property (nonatomic, strong) NSMutableArray *documents;

@property (nonatomic, strong) ArchiveSearchDoc *selectedDoc;

@end

@implementation IAMCSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.service = [IAMusicService new];
    self.documents = [NSMutableArray new];
    
    self.searchTableView.estimatedRowHeight = 44.0;
    self.searchTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];


    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self doSearch:searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self doSearch:searchBar];
}

- (void)doSearch:(UISearchBar *)searchBar
{
    if([searchBar.text isEqualToString:@""] || searchBar.text.length == 0)
    {
        [self.documents removeAllObjects];
        [self.searchTableView reloadData];
        return;
    }
    
    self.service.queryString = searchBar.text;
    [self.service fetchIASearcDocsWithCompletionHandler:^(NSArray<ArchiveSearchDoc *> *docs) {
        [self.documents removeAllObjects];
        [self.documents addObjectsFromArray:docs];
        [self.searchTableView reloadData];
        
    }];

}


- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    switch (selectedScope) {
        case SearchFieldsCreator:
            self.service.searchField = SearchFieldsCreator;
            break;
            
        case SearchFieldsAll:
            self.service.searchField = SearchFieldsAll;
            break;
    }
    
    [self doSearch:searchBar];

}


#pragma mark - table delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.documents.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArchiveSearchDoc *doc = [self.documents objectAtIndex:indexPath.row];
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
    cell.searchTitle.text = doc.title;
    [cell.searchImageView setImageWithURL:[NSURL URLWithString:doc.itemImageUrl] placeholderImage:nil];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    _selectedDoc = [self.documents objectAtIndex:indexPath.row];
//
//}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"cellPush"])
    {
        IAItemViewController *itemVC = [segue destinationViewController];
        ArchiveSearchDoc *doc = [self.documents objectAtIndex:[self.searchTableView indexPathForSelectedRow].row];
        [itemVC setSearchDoc:doc];
    }
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
