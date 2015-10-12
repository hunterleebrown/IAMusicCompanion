//
//  SearchTableViewCell.h
//  IA Music
//
//  Created by Hunter on 10/10/15.
//  Copyright © 2015 Hunter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArchiveSearchDoc.h"

@interface SearchTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *searchTitle;
@property (nonatomic, weak) IBOutlet UIImageView *searchImageView;
@property (nonatomic, weak) IBOutlet UILabel *creator;
@property (nonatomic, weak) IBOutlet UILabel *typeLabel;
@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;


@property (nonatomic, strong) ArchiveSearchDoc *archiveSearchDoc;

@end
