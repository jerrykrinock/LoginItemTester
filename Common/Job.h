#import <Foundation/Foundation.h>

@interface Job : NSObject <NSSecureCoding> {
}

@property (copy) NSString* answer;
@property (assign) NSInteger characterCount;
@property (copy) NSDate* timestamp;

@end
