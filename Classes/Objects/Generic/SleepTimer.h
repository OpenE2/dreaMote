//
//  SleepTimer.h
//  dreaMote
//
//  Created by Moritz Venn on 02.06.11.
//  Copyright 2011 Moritz Venn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	sleeptimerStandby,
	sleeptimerShutdown,
} sleeptimerActions;

@interface SleepTimer : NSObject
{
@private
	sleeptimerActions action;
	BOOL enabled;
	NSString *text;
	NSUInteger time;
	BOOL valid;
}

@property (nonatomic, assign) sleeptimerActions action;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) NSUInteger time;
@property (nonatomic, assign) BOOL valid;

@end