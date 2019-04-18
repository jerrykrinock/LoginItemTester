#import "AgentProxy.h"

@implementation AgentProxy

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.text forKey:@"answer"];
    [coder encodeInteger:self.characterCount forKey:@"characterCount"];
    [coder encodeObject:self.timestamp forKey:@"timestamp"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self) {
        _text = [aDecoder decodeObjectOfClass:[NSString class]
                                         forKey:@"answer"];
        _characterCount = [aDecoder decodeIntegerForKey:@"characterCount"];
        _timestamp = [aDecoder decodeObjectOfClass:[NSDate class]
                                            forKey:@"timestamp"];
	}
	return self;
}

@end
