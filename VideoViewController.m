//
//  ViewController.m
//  VideoCover


#import "VideoViewController.h"
#import "AppViewController.h"
#import "NavigationView.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <POP/POP.h>
#import "Parse.h"
#import "Alert.h"
#import <Contacts/Contacts.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface VideoViewController ()

@property (nonatomic, strong) AVPlayer *avplayer;
@property (strong, nonatomic) IBOutlet UIView *movieView;
@property (strong, nonatomic) IBOutlet UIView *gradientView;
@property (strong, nonatomic) IBOutlet UIView *contentView;


@end

@implementation VideoViewController
{
    AppViewController *appview;
    UIPageControl *pageControl;
    UILabel *label;
    UIButton *button1;
    UIButton *button2;
    UIButton *camera;
    UIButton *contacts;
    UIButton *notifications;
    
    NSInteger buttonIndicate;
    POPSpringAnimation *spring;
    POPBasicAnimation *disappear;
    }
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    buttonIndicate = 0;
    /*-----------------------------------------------------------------------------------------*/
    spring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    spring.toValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
    spring.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    spring.springBounciness = 20.f;

    /*----------------------------------------------------------------------------------------*/
    disappear = [POPBasicAnimation animation];
    disappear.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    disappear.toValue = @(0);
    /*-----------------------------------------------------------------------------------------*/
    pageControl = [[UIPageControl alloc] init];
    pageControl.frame = self.view.frame;
    pageControl.numberOfPages = 10;
    pageControl.currentPage = 0;
    pageControl.userInteractionEnabled = NO;
    /*-----------------------------------------------------------------------------------------*/
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(70,350,200,20)];
    label.text = @"0";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    /*-----------------------------------------------------------------------------------------*/
    button1 =[[UIButton alloc]initWithFrame:CGRectMake(80,210,160,40)];
    button1.backgroundColor = [UIColor purpleColor];
    button1.layer.cornerRadius = 10;
    button1.clipsToBounds = YES;
    [button1 addTarget:self
               action:@selector(button1Pressed:)
     forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"Continue  ➣" forState:UIControlStateNormal];
    button1.frame = CGRectMake(100, 450, 160.0, 40.0);
    [self.view addSubview:button1];
    /*-----------------------------------------------------------------------------------------*/
    button2 =[[UIButton alloc]initWithFrame:CGRectMake(80,210,160,40)];
    button2.backgroundColor = [UIColor purpleColor];
    
    button2.layer.cornerRadius = 10;
    button2.clipsToBounds = YES;
    [button2 addTarget:self
                action:@selector(button2Pressed:)
      forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"I already Know" forState:UIControlStateNormal];
    button2.frame = CGRectMake(90, 500, 200, 40.0);
    [self.view addSubview:button2];
    /*-----------------------------------------------------------------------------------------*/
    camera =[[UIButton alloc]initWithFrame:CGRectMake(80,210,160,40)];
    camera.backgroundColor = [UIColor purpleColor];
    camera.layer.cornerRadius = 10;
    camera.clipsToBounds = YES;
    [camera addTarget:self
                action:@selector(cameraPermission:)
      forControlEvents:UIControlEventTouchUpInside];
    [camera setTitle:@"Allow Camera" forState:UIControlStateNormal];
    camera.frame = CGRectMake(90, 300, 200, 40.0);
    [self.view addSubview:camera
     ];
    camera.hidden = YES;
    /*-----------------------------------------------------------------------------------------*/
    contacts =[[UIButton alloc]initWithFrame:CGRectMake(80,210,160,40)];
    contacts.backgroundColor = [UIColor purpleColor];
    contacts.layer.cornerRadius = 10;
    contacts.clipsToBounds = YES;
    [contacts addTarget:self
                action:@selector(contactPermission:)
      forControlEvents:UIControlEventTouchUpInside];
    [contacts setTitle:@"Allow Contacts" forState:UIControlStateNormal];
    contacts.frame = CGRectMake(90, 350, 200, 40.0);
    [self.view addSubview:contacts];
    contacts.hidden = YES;
     /*-----------------------------------------------------------------------------------------*/
    notifications =[[UIButton alloc]initWithFrame:CGRectMake(80,210,160,40)];
    notifications.backgroundColor = [UIColor purpleColor];
    notifications.layer.cornerRadius = 10;
    notifications.clipsToBounds = YES;
    [notifications addTarget:self
                action:@selector(notificationPermission:)
      forControlEvents:UIControlEventTouchUpInside];
    [notifications setTitle:@"Allow Notifications" forState:UIControlStateNormal];
    notifications.frame = CGRectMake(90, 400, 200, 40.0);
    notifications.hidden = YES;
    [self.view addSubview:notifications];
    /*-----------------------------------------------------------------------------------------*/

    NSError *sessionError = nil;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    //Set up player
    [self setUpVideo:@"xx" :@"mp4"];

    
    //Config player
    [self.avplayer seekToTime:kCMTimeZero];
    [self.avplayer setVolume:0.0f];
    [self.avplayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avplayer currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerStartPlaying)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
 /*
    //Config dark gradient view
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [[UIScreen mainScreen] bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0x030303) CGColor], (id)[[UIColor clearColor] CGColor], (id)[UIColorFromRGB(0x030303) CGColor],nil];
    [self.gradientView.layer insertSublayer:gradient atIndex:0];*/
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.avplayer play];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)playerStartPlaying
{
    [self.avplayer play];
}


- (IBAction)button1Pressed:(id)sender {

    [button1 pop_addAnimation:spring forKey:@"springAnimation"];
    [self.movieView pop_addAnimation:disappear forKey:@"kPOPViewAlpha"];
    ++pageControl.currentPage;
    switch (pageControl.currentPage) {
        case 0:
            label.text = @"0";
            break;
        case 1:
            label.text = @"1";
            break;
        case 2:
            label.text = @"2";
            break;
        case 3:
            label.text = @"3";
            break;
        case 4:
            label.text = @"4";
            break;
        case 5:
            label.text = @"5";
            break;
        case 6:
            label.text = @"6";
            break;
        case 7:
            label.text = @"7";
            break;
        case 8:
            label.text = @"8";
            [self.movieView removeFromSuperview];
            [self.gradientView removeFromSuperview];
            button2.hidden = YES;
            camera.hidden = NO;
            contacts.hidden = NO;
            notifications.hidden = NO;
            button1.userInteractionEnabled = NO;
            button1.backgroundColor = [UIColor grayColor];
            break;
        case 9:
            label.text = @"9";
            
            
            [self dismissViewControllerAnimated:YES completion:nil];
            break;

            
        default:
            break;
            
    }
    
    

 
   }
- (IBAction)button2Pressed:(id)sender {

    [button2 pop_addAnimation:spring forKey:@"springAnimation"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        pageControl.currentPage = 9;
    });
    [self.movieView removeFromSuperview];
    [self.gradientView removeFromSuperview];
    button2.hidden = YES;
    camera.hidden = NO;
    contacts.hidden = NO;
    notifications.hidden = NO;
    button1.userInteractionEnabled = NO;
    button1.backgroundColor = [UIColor grayColor];
    label.text = @"9";
    
}
-(IBAction)cameraPermission:(id)sender{

    [camera pop_addAnimation:spring forKey:@"springAnimation"];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        // Will get here on both iOS 7 & 8 even though camera permissions weren't required
        // until iOS 8. So for iOS 7 permission will always be granted.
        if (granted) {
            // Permission has been granted. Use dispatch_async for any UI updating
            // code because this block may be executed in a thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                camera.backgroundColor = [UIColor greenColor];
                buttonIndicate++;
                if (buttonIndicate == 3)
                {
                    button1.userInteractionEnabled = YES;
                    button1.backgroundColor = [UIColor purpleColor];
                }
               
            });
        } else {
            // Permission has been denied.
        }
    }];
    
}

-(IBAction)contactPermission:(id)sender
{

    [contacts pop_addAnimation:spring forKey:@"springAnimation"];
    
    CNContactStore* addressBook = [[CNContactStore alloc]init];
    CNAuthorizationStatus permissions = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if(permissions == CNAuthorizationStatusNotDetermined) {
        
        [addressBook requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable contactError) {
            
            if (granted)
            {
                contacts.backgroundColor = [UIColor greenColor];
                buttonIndicate++;
                if (buttonIndicate == 3)
                {
                    button1.userInteractionEnabled = YES;
                    button1.backgroundColor = [UIColor purpleColor];
                }
            }
            else
            {}
        }];
    }

    
}

-(IBAction)notificationPermission:(id)sender
{
 
    [notifications pop_addAnimation:spring forKey:@"springAnimation"];
    if (!ParseCheckPermissionForRemoteNotifications())
    {

                  ParseRegisterForRemoteNotifications(^(BOOL notificationsAreEnabled)
                                                      {
                                                          notifications.backgroundColor = [UIColor greenColor];
                                                          buttonIndicate++;
                                                          if (buttonIndicate == 3)
                                                          {
                                                              button1.userInteractionEnabled = YES;
                                                              button1.backgroundColor = [UIColor purpleColor];
                                                          }
                                                      });
            
    }

}

-(void)setUpVideo:(NSString*)fileName :(NSString*)extension
{
    if (self.movieView.window != nil)
    {
        [self.movieView.window removeFromSuperview];
    }
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:extension]];
    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    self.avplayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [avPlayerLayer setFrame:[[UIScreen mainScreen] bounds]];

    [self.movieView.layer addSublayer:avPlayerLayer];
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
