//
//  OtherSplitViewController.h
//  dreaMote
//
//  Created by Moritz Venn on 06.11.11.
//  Copyright (c) 2011 Moritz Venn. All rights reserved.
//

#import "AdSupportedSplitViewController.h"

#import <OtherViewProtocol.h>
#import <ViewController/AboutDreamoteViewController.h>

@interface OtherSplitViewController : AdSupportedSplitViewController<AboutDreamoteDelegate, OtherViewProtocol>
{
@private
	BOOL isInit;
}

@end
