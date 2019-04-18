#import <Cocoa/Cocoa.h>
#import "Worker.h"

@interface GUIAppDel : NSObject <NSApplicationDelegate>

- (IBAction)loginAgentOn:(id)sender;
- (IBAction)loginAgentOff:(id)sender;
- (IBAction)startConnection:(id)sender;
- (IBAction)endConnection:(id)sender;
- (IBAction)doWork:(id)sender;

@property (assign) IBOutlet NSWindow* window;
@property (weak) IBOutlet NSTextField* textInField;
@property (weak) IBOutlet NSTextField* textOutField;
@property (weak) IBOutlet NSTextField* processActivityTextField;
@property (weak) IBOutlet NSView* blinker;
@property (strong) NSXPCConnection* connection;
@property (strong) id <Worker> agentProxy;
@property (weak) IBOutlet NSTextField* enDisAbleResult;
@property (weak) IBOutlet NSTextField* connectionResult;

@end

