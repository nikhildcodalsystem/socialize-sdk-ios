//
//  SocializeCommentsTableViewController.m
//  appbuildr
//
//  Created by Fawad Haider on 12/2/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "SocializeCommentsTableViewController.h"
#import "CommentsTableViewCell.h"
#import "NSDateAdditions.h"
#import "CommentDetailsViewController.h"
#import "PostCommentViewController.h"
#import "UILabel-Additions.h"
#import "UIButton+Socialize.h"
#import <QuartzCore/CALayer.h>
#import "SocializeComment.h"
#import "UINavigationBarBackground.h"

#define UIColorFromRGB(rgbValue) [UIColor \
	colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
		green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
			blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SocializeCommentsTableViewController()
-(NSString*)getDateString:(NSDate*)date;
-(void)setupNavBar;
-(UIView*)prepareCommentsNavBarsLeftView;
-(UIBarButtonItem*)createLeftNavigationButtonWithCaption:(NSString*)caption;

@end

@implementation SocializeCommentsTableViewController

@synthesize _tableView;
@synthesize brushedMetalBackground;
@synthesize backgroundView;
@synthesize roundedContainerView;
@synthesize noCommentsIconView;
@synthesize topToolBar;
@synthesize commentsCell;
@synthesize footerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil entryUrlString:(NSString*) entryUrlString {
    
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

		_errorLoading = NO;
		_isLoading = YES;
		self.view.clipsToBounds = YES;

		_commentDateFormatter = [[NSDateFormatter alloc] init];
		[_commentDateFormatter setDateFormat:@"hh:mm:ss zzz"];
        
		/*container frame inits*/
		CGRect containerFrame = CGRectMake(0, 0, 140, 140);
		TableBGInfoView * containerView = [[[TableBGInfoView alloc] initWithFrame:containerFrame bgImageName:@"socialize-nocomments-icon.png"] autorelease];
		containerView.hidden = YES;
		containerView.center = _tableView.center;
		[_tableView addSubview:containerView];

		informationView = containerView;
		informationView.errorLabel.text = @"No comments to show.";
        
        _entity = [[SocializeEntity alloc] init];
        _entity.key = entryUrlString;
        _socialize = [[Socialize alloc] initWithDelegate:self]; 
        
        _cache = [[ImagesCache alloc] initWithCompleteBlock:nil];
        
	}
    return self;
}

- (UIView*)prepareCommentsNavBarsLeftView {
    
	NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"commentsNavBarLeftItemView" owner:self options:nil];
	UIView* myview = [nibViews objectAtIndex: 0];
	return myview;

}

-(void)setupNavBar{

    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Comments" style: UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    
    UIButton * cancelButton = [UIButton redSocializeNavBarButtonWithTitle:@"Close"];
	NSMutableArray* navButtonItems = [NSMutableArray arrayWithCapacity:3];

 	UIBarButtonItem* leftItem = [[UIBarButtonItem alloc] initWithCustomView:[self prepareCommentsNavBarsLeftView]];
	UIBarButtonItem* rightCancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
	UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	fixedSpace.width = 130;

	[navButtonItems addObject:leftItem];
	[navButtonItems addObject:fixedSpace];
	[navButtonItems addObject:rightCancelItem];
    self.topToolBar.tintColor = [UIColor blackColor];
	
	[self.topToolBar setItems:navButtonItems];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_socialize getCommentList:_entity.key first:nil last:nil]; 
    _loadingView = [LoadingView loadingViewInView:self.view];
    
    CompleteBlock completeAction = [[^(ImagesCache* cache)
                                     {
                                         if (!_arrayOfComments)
                                             return;
                                         
                                         [_tableView reloadData];
                                     } copy]autorelease];
    _cache.completeAction = completeAction;
}

#pragma mark SocializeService Delegate

-(void)service:(SocializeService *)service didFail:(NSError *)error{

    _isLoading = NO;
    [self._tableView reloadData];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Failed!", @"") 
                                                    message: [error localizedDescription]
                                                   delegate: nil 
                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                          otherButtonTitles: nil];
    [alert show];	
    [alert release];
    [_loadingView removeView];
}

-(void)service:(SocializeService *)service didFetchElements:(NSArray *)dataArray{
 
    _isLoading = NO;
    _arrayOfComments = [dataArray retain];
    [_loadingView removeView];
    [self._tableView reloadData];
    
}
#pragma mark -

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
    
    _tableView.scrollsToTop = YES;
    _tableView.autoresizesSubviews = YES;

	UIImage * backgroundImage = [UIImage imageNamed:@"socialize-activity-bg.png"];
	UIImageView * imageBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
	_tableView.backgroundView = imageBackgroundView; 
	[imageBackgroundView release];

}

#pragma mark tableFooterViewDelegate

-(IBAction)addCommentButtonPressed:(id)sender {

    PostCommentViewController * pcViewController = [[PostCommentViewController alloc] initWithNibName:@"PostCommentViewController" bundle:nil entityUrlString:_entity.key];
    
    UIImage * socializeNavBarBackground = [UIImage imageNamed:@"socialize-navbar-bg.png"];
    UINavigationController * pcNavController = [[UINavigationController alloc] initWithRootViewController:pcViewController];
    [pcNavController.navigationBar setBackgroundImage:socializeNavBarBackground];
    [pcViewController release];

    [self presentModalViewController:pcNavController animated:YES];
}

#pragma mark -

#pragma mark CommentViewController delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

	if (anim == [self.view.layer animationForKey:@"transform.scaleOut"]){
		[self.view.layer removeAnimationForKey:@"transform.scaleOut"];
		[self autorelease];
	}
	
	[self.view.layer removeAnimationForKey:@"transform.scaleOut"];
	[self.view removeFromSuperview];
	[self autorelease];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	if ([_arrayOfComments count] <= 0 && !_isLoading) 
		[self addNoCommentsBackground];
	else 
		[self removeNoCommentsBackground];
	
	if (_arrayOfComments)
		return [_arrayOfComments count];
	else
		return 0;
}

-(NSString*)getDateString:(NSDate*)startdate {
	return [NSDate getTimeElapsedString:startdate]; 
}

-(UIBarButtonItem*) createLeftNavigationButtonWithCaption: (NSString*) caption {

    UIButton *backButton = [UIButton blackSocializeNavBarBackButtonWithTitle:caption]; 
    [backButton addTarget:self action:@selector(backToCommentsList:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backLeftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return backLeftItem;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_arrayOfComments count]){

       [tableView deselectRowAtIndexPath:indexPath animated:YES];
        SocializeComment* entryComment = ((SocializeComment*)[_arrayOfComments objectAtIndex:indexPath.row]);
        
        CommentDetailsViewController* details = [[CommentDetailsViewController alloc] init];
        details.title = [NSString stringWithFormat: @"%d of %d", indexPath.row + 1, [_arrayOfComments count]];
        details.comment = entryComment;

        [_cache stopOperations];
        details.cache = _cache;
           
        [self.navigationController pushViewController:details animated:YES];
        [details release];
    }
}

-(IBAction)viewProfileButtonTouched:(id)sender {
    // TODO :  lets view the profile    
}

-(void)backToCommentsList:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)newTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"socializecommentcell";
	CommentsTableViewCell *cell = (CommentsTableViewCell*)[newTableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
    if (cell == nil) {
        
        // Create a temporary UIViewController to instantiate the custom cell.
        [[NSBundle mainBundle] loadNibNamed:@"CommentsTableViewCell" owner:self options:nil];
        // Grab a pointer to the custom cell.
        cell = commentsCell;
        self.commentsCell = nil;

    }
	
	if ([_arrayOfComments count]) {
		
		SocializeComment* entryComment = ((SocializeComment*)[_arrayOfComments objectAtIndex:indexPath.row]);

		NSString *commentText = ((SocializeComment*)[_arrayOfComments objectAtIndex:indexPath.row]).text;
		NSString *commentHeadline = ((SocializeComment*)[_arrayOfComments objectAtIndex:indexPath.row]).user.userName;
        
        cell.locationPin.hidden = (entryComment.lat == nil);
        cell.btnViewProfile.tag = indexPath.row;
		cell.headlineLabel.text = commentHeadline;
		[cell setComment:commentText];
        
		cell.dateLabel.text = [self getDateString:((SocializeComment*)[_arrayOfComments objectAtIndex:indexPath.row]).date];
        
        CGRect cellRect = cell.bounds;
        CGRect datelabelRect = cell.dateLabel.frame;
        
        CGSize textSize = CGSizeMake(cellRect.size.width, datelabelRect.size.height);
        textSize = [cell.dateLabel.text sizeWithFont:cell.dateLabel.font constrainedToSize:textSize];
                    
        CGFloat xLabelCoordinate = cellRect.size.width - textSize.width - 7;
        datelabelRect = CGRectMake(xLabelCoordinate, datelabelRect.origin.y, textSize.width, datelabelRect.size.height);
        cell.dateLabel.frame = datelabelRect;
         
        CGRect locationPinFrame = cell.locationPin.frame;
        CGFloat xPinCoordinate = xLabelCoordinate - locationPinFrame.size.width - 7;
        locationPinFrame = CGRectMake(xPinCoordinate, locationPinFrame.origin.y, locationPinFrame.size.width, locationPinFrame.size.height);
        
        cell.locationPin.frame = locationPinFrame;
        
        UIImage * profileImage =(UIImage *)[_cache imageFromCache:entryComment.user.smallImageUrl];
		
		if (profileImage) 
		{
			cell.userProfileImage.image = profileImage;
		}
		else
		{
            cell.userProfileImage.image = [UIImage imageNamed:@"socialize-cell-image-default.png"];
			if (([entryComment.user.smallImageUrl length] > 0))
			{ 
                [_cache loadImageFromUrl: entryComment.user.smallImageUrl];
			}
		}
	}
	else {
		if (_isLoading){
			UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RegularCell"] autorelease];
			cell.textLabel.text = @"Comments loading...";
			return cell;
		}
		else if (_errorLoading){

			UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RegularCell"] autorelease];
			cell.textLabel.text = @"Error retrieving comments";
			return cell;

		}
		else {
			UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RegularCell"] autorelease];
			cell.textLabel.text = @"Be the first commentator";
			return cell;
		}
	}
	return cell;
}

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

#pragma -

#pragma mark UITableViewDelegate
// Display customization
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

// Variable height support
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [CommentsTableViewCell getCellHeightForString:((SocializeComment*)[_arrayOfComments objectAtIndex:indexPath.row]).text] + 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	return 80;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}
#pragma mark -


 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)addNoCommentsBackground{
	informationView.errorLabel.hidden = NO;
	informationView.noActivityImageView.hidden = NO;
	informationView.hidden = NO;
}

- (void)removeNoCommentsBackground{
	informationView.errorLabel.hidden = YES;
	informationView.noActivityImageView.hidden = YES;
	informationView.hidden = YES;
}
#pragma mark TextView Delegate 

- (void)textViewDidChange:(UITextView *)textView {
	
}

#pragma mark PostCommentViewController Delegate



#pragma mark FooterAnimateDelegate


#pragma mark -
- (void)dealloc {
    [_cache release];
    [_socialize release];
	[informationView release];
	[_entity release];
	[_arrayOfComments release];
	[_commentDateFormatter release];
    [footerView release];
    [super dealloc];
}

@end
