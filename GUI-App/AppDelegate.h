#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (IBAction)loginAgentOn:(id)sender;
- (IBAction)loginAgentOff:(id)sender;

@property (weak) IBOutlet NSTextField* enDisAbleResult;

@end

