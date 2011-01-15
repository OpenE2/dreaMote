//
//  MediaPlayerDetailsController.m
//  dreaMote
//
//  Created by Moritz Venn on 10.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaPlayerDetailsController.h"

#import "Constants.h"
#import "DisplayCell.h"
#import "MediaPlayerMetadataCell.h"
#import "RemoteConnectorObject.h"

@interface MediaPlayerDetailsController()
- (void)emptyData;
- (void)fetchCoverart;
- (void)fetchData;
@end

@implementation MediaPlayerDetailsController

/* dealloc */
- (void)dealloc
{
	[_currentTrack release];
	[_currentCover release];
	[_metadataXMLDoc release];
	[_tableView release];

	[super dealloc];
}

/* getter of playlist */
- (FileListView *)playlist
{
	return _playlist;
}

/* setter of playlist */
- (void)setPlaylist:(FileListView *)new
{
	if([new isEqual: _playlist]) return;

	[_playlist release];
	_playlist = [new retain];
	_playlist.fileDelegate = self;
}

- (void)loadView
{
	// setup our parent content view and embed it to your view controller
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	if(IS_IPAD())
	{
		contentView.backgroundColor = [UIColor colorWithRed:0.821f green:0.834f blue:0.860f alpha:1];
	}
	else
	{
		contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];	// use the table view background color
	}

	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

	self.view = contentView;
	[contentView release];

	// setup our table view
	// FIXME: wtf?!
	CGRect frame = self.view.frame;
	frame.origin.x = 0;
	frame.origin.y = 0;
	_tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_tableView.autoresizesSubviews = YES;
	_tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

	[self.view addSubview: _tableView];

	// file list
	_fileList = [[FileListView alloc] initWithFrame: self.view.frame];
	_fileList.path = @"/";
	_fileList.fileDelegate = self;
}

/* new track started playing */
- (void)newTrackPlaying
{
	[self emptyData];

	// playing track changed, update local metadata
	[NSThread detachNewThreadSelector:@selector(fetchData) toTarget:self withObject:nil];
}

/*!
 @brief Hide toolbar.
 */
- (void)hideToolbar
{
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
}

/*!
 @brief Show toolbar.
 */
- (void)showToolbar
{
	[self.navigationItem setLeftBarButtonItem:_addFolderItem animated:YES];
	[self.navigationItem setRightBarButtonItem:_addPlayToggle animated:YES];
}

/* fetch contents */
- (void)fetchData
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[_metadataXMLDoc release];
	_metadataXMLDoc = [[[RemoteConnectorObject sharedRemoteConnector] getMetadata:self] retain];
	[pool release];
}

/* remove content data */
- (void)emptyData
{
	[_currentTrack release];
	_currentTrack = nil;
	[_currentCover release];
	_currentCover = nil;
	NSIndexSet *idxSet = [NSIndexSet indexSetWithIndex:0];
	[_tableView reloadSections:idxSet withRowAnimation:UITableViewRowAnimationRight];
	[_metadataXMLDoc release];
	_metadataXMLDoc = nil;
}

/* fetch coverart */
- (void)fetchCoverart
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSData *imageData = [[RemoteConnectorObject sharedRemoteConnector] getFile:_currentTrack.coverpath];
	[_currentCover release];
	_currentCover = [[UIImage alloc] initWithData:imageData];
	NSIndexSet *idxSet = [NSIndexSet indexSetWithIndex:0];
	[_tableView reloadSections:idxSet withRowAnimation:UITableViewRowAnimationRight];
	[pool release];
}

- (void)placeControls:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	// parent class would screw up the fileList frame otherwise
}

- (IBAction)flipView:(id)sender
{
	// fix up frame
	_fileList.frame = self.view.frame;

	[super flipView:nil];
}

#pragma mark - UITableView delegates

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section != 2) return nil;

	const UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
	if([cell respondsToSelector: @selector(view)]
	   && [((DisplayCell *)cell).view respondsToSelector:@selector(sendActionsForControlEvents:)])
	{
		[(UIButton *)((DisplayCell *)cell).view sendActionsForControlEvents: UIControlEventTouchUpInside];
	}
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch(section)
	{
		case 0:
			if([[RemoteConnectorObject sharedRemoteConnector] hasFeature:kFeaturesMediaPlayerMetadata]
				&& _currentTrack != nil)
				return NSLocalizedString(@"Now Playing", @"");
			return nil;
		case 1:
			return NSLocalizedString(@"Controls", @"");
		default:
			return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch(section)
	{
		case 0:
			if([[RemoteConnectorObject sharedRemoteConnector] hasFeature:kFeaturesMediaPlayerMetadata]
				&& _currentTrack != nil)
				return 1;
			return 0;
		case 1:
			return 4;
		default:
			return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 0)
		return kMetadataCellHeight;
	return kUIRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *sourceCell = nil;

	switch(indexPath.section)
	{
		case 0:
		{
			UIImageView *imageView = nil;
			sourceCell = [tableView dequeueReusableCellWithIdentifier:kMetadataCell_ID];
			if(sourceCell == nil)
				sourceCell = [[[MediaPlayerMetadataCell alloc] initWithFrame:CGRectZero reuseIdentifier:kMetadataCell_ID] autorelease];

			((MediaPlayerMetadataCell *)sourceCell).metadata = _currentTrack;
			if(_currentCover)
				imageView = [[UIImageView alloc] initWithImage:_currentCover];
			((MediaPlayerMetadataCell *)sourceCell).coverart = imageView;
			[imageView release];
			break;
		}
		case 1:
		{
			sourceCell = [tableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
			if(sourceCell == nil)
				sourceCell = [[[DisplayCell alloc] initWithFrame:CGRectZero reuseIdentifier:kDisplayCell_ID] autorelease];

			switch(indexPath.row)
			{
				case 0:
					((DisplayCell *)sourceCell).nameLabel.text = NSLocalizedString(@"Previous", @"");
					((DisplayCell *)sourceCell).view = [[self newButton:CGRectMake(0, 0, kUIRowHeight-2, kUIRowHeight-2) withImage:@"key_fr.png" andKeyCode: kButtonCodeFRwd] autorelease];
					break;
				case 1:
					((DisplayCell *)sourceCell).nameLabel.text = NSLocalizedString(@"Stop", @"");
					((DisplayCell *)sourceCell).view = [[self newButton:CGRectMake(0, 0, kUIRowHeight-2, kUIRowHeight-2) withImage:@"key_stop.png" andKeyCode: kButtonCodeStop] autorelease];
					break;
				case 2:
					((DisplayCell *)sourceCell).nameLabel.text = NSLocalizedString(@"Play/Pause", @"");
					((DisplayCell *)sourceCell).view = [[self newButton:CGRectMake(0, 0, kUIRowHeight-2, kUIRowHeight-2) withImage:@"key_pp.png" andKeyCode: kButtonCodePlayPause] autorelease];
					break;
				case 3:
					((DisplayCell *)sourceCell).nameLabel.text = NSLocalizedString(@"Next", @"");
					((DisplayCell *)sourceCell).view = [[self newButton:CGRectMake(0, 0, kUIRowHeight-2, kUIRowHeight-2) withImage:@"key_ff.png" andKeyCode: kButtonCodeFFwd] autorelease];
					break;
				default: break;
			}
		}
		default: break;
	}

	return sourceCell;
}

#pragma mark -
#pragma mark MetadataSourceDelegate
#pragma mark -

- (void)addMetadata:(NSObject <MetadataProtocol>*)anItem
{
	if(anItem == nil) return;
	[_currentTrack release];
	_currentTrack = [anItem retain];
	NSIndexSet *idxSet = [NSIndexSet indexSetWithIndex:0];

	if(!(_currentTrack.coverpath == nil || [_currentTrack.coverpath isEqualToString: @""])
	   && [[RemoteConnectorObject sharedRemoteConnector] hasFeature:kFeaturesFileDownload])
		[NSThread detachNewThreadSelector:@selector(fetchCoverart) toTarget:self withObject:nil];
	else
	{
		[_currentCover release];
		_currentCover = nil;
	}
	[_tableView reloadSections:idxSet withRowAnimation:UITableViewRowAnimationRight];
}

@end
