//
//  SearchTableViewCell.m
//  IA Music
//
//  Created by Hunter on 10/10/15.
//  Copyright © 2015 Hunter. All rights reserved.
//

#import "SearchTableViewCell.h"
#import "FontMapping.h"
#import "MediaUtils.h"
#import "StringUtils.h"
#import "UIImageView+AFNetworking.h"


@implementation SearchTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setArchiveSearchDoc:(ArchiveSearchDoc *)archiveSearchDoc
{
    _archiveSearchDoc = archiveSearchDoc;
    [_searchImageView setImageWithURL:[NSURL URLWithString:_archiveSearchDoc.itemImageUrl]];
    
    [_searchTitle setText:_archiveSearchDoc.title];
    
    [_creator setText:[self.class creatorText:archiveSearchDoc]];
    [_creator setFont:[UIFont systemFontOfSize:12]];
    
    self.typeLabel.text = [MediaUtils iconStringFromMediaType:archiveSearchDoc.type];
    [self.typeLabel setTextColor:[MediaUtils colorFromMediaType:archiveSearchDoc.type]];
    

    //    [self.detailsLabel setText:[StringUtils stringByStrippingHTML:self.archiveSearchDoc.details]];
    //    [self.detailsLabel setAttributedText:[self.class detailsAttributedString:[StringUtils stringByStrippingHTML:self.archiveSearchDoc.details]]];
    //    [self.detailsLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    
    NSString *countString = [StringUtils decimalFormatNumberFromInteger:[[archiveSearchDoc.rawDoc objectForKey:@"downloads"] integerValue]];
    NSMutableAttributedString *countAtt = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", VIEWS, countString]];
    [countAtt addAttribute:NSFontAttributeName value:[UIFont fontWithName:ICONOCHIVE size:12] range:NSMakeRange(0, VIEWS.length)];
    [countAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(VIEWS.length+1, countString.length)];
    
    self.countLabel.attributedText = countAtt;
    
    if([archiveSearchDoc.rawDoc objectForKey:@"publicdate"] == nil){
        [_dateLabel setHidden:YES];
    } else {
        NSString *date = [StringUtils displayShortDateFromArchiveDateString:[archiveSearchDoc.rawDoc objectForKey:@"publicdate"]];
        [_dateLabel setText:[NSString stringWithFormat:@"Archived\n%@", date]];
        [_dateLabel setFont:[UIFont systemFontOfSize:10]];
        [_dateLabel setHidden:NO];
    }
    
    [self layoutSubviews];

}

+ (NSString *)creatorText:(ArchiveSearchDoc *)doc{
    if(doc.creator){
        return [NSString stringWithFormat:@"by %@", doc.creator];
    } else
    {
        return @"";
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _searchTitle.preferredMaxLayoutWidth = _searchTitle.frame.size.width;
    [_searchTitle sizeToFit];
    [_searchTitle layoutIfNeeded];

//    [self layoutIfNeeded];
    
}


@end
