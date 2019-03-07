#import <Cocoa/Cocoa.h>
#import "Worker.h"

@interface GUIAppDel : NSObject <NSApplicationDelegate>

- (IBAction)loginAgentOn:(id)sender;
- (IBAction)loginAgentOff:(id)sender;
- (IBAction) doWork:(id)sender;

@property (assign) IBOutlet NSWindow* window;
@property (weak) IBOutlet NSButton* button;
@property (weak) IBOutlet NSTextField* textInField;
@property (weak) IBOutlet NSTextField* textOutField;
@property (weak) IBOutlet NSTextField* processActivityTextField;
@property (weak) IBOutlet NSLevelIndicator* blinker;
@property (strong) NSXPCConnection* connection;
@property (strong) id <Worker> job;
@property (weak) IBOutlet NSTextField* enDisAbleResult;

@end

