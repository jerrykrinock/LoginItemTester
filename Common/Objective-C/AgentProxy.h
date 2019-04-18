#import <Foundation/Foundation.h>

@interface AgentProxy : NSObject <NSSecureCoding> {
}

@property (copy) NSString* text;
@property (assign) NSInteger characterCount;
@property (copy) NSDate* timestamp;

@end
