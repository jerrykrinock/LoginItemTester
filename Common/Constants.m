#import "Constants.h"

NSString* constAgentID = @"com.sheepsystems.Login1";

/* We hard code the agentVersion here.  Change it to verify that the
 newest version of the agent is being launched by macOS.  Note that
 this code (JobListener) is only built into the Agent-App, not the
 GUI-App.  */
NSInteger const constAgentVersion = 102;
