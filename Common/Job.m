#import "Job.h"

@implementation Job

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.answer forKey:@"answer"];
    [coder encodeInteger:self.agentVersion forKey:@"agentVersion"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self) {
		_answer = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"answer"];
        _agentVersion = [aDecoder decodeIntegerForKey:@"agentVersion"];
	}
	return self;
}

@end
