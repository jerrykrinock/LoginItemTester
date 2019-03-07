#import "Job.h"

@implementation Job

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self) {
		self.answer = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"Job"];
        self.agentVersion = [aDecoder decodeIntegerForKey:@"agentVersion"];
	}
	return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.answer forKey:@"Job"];
    [aCoder encodeInteger:self.agentVersion forKey:@"agentVersion"];
}

@end
