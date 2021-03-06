//
//  MovieTableViewCell.h
//  dreaMote
//
//  Created by Moritz Venn on 09.03.08.
//  Copyright 2008-2012 Moritz Venn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TableViewCell/MultiSelectionTableViewCell.h>

#import <Objects/MovieProtocol.h>


/*!
 @brief Cell identifier for this cell.
 */
extern NSString *kMovieCell_ID;

/*!
 @brief UITableViewCell optimized to display Movies.
 */
@interface MovieTableViewCell : MultiSelectionTableViewCell

/*!
 @brief Movie.
 */
@property (nonatomic, strong) NSObject<MovieProtocol> *movie;

/*!
 @brief Date Formatter instance.
 */
@property (nonatomic, strong) NSDateFormatter *formatter;

@end


