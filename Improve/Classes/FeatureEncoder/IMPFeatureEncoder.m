//
//  FeatureEncoder.m
//  PyF
//
//  Created by PanHongxi on 3/10/21.
//

#import <Foundation/Foundation.h>

#import "IMPFeatureEncoder.h"
#import "xxhash.h"

#define sprinkle(x, small_noise) ((x + small_noise) * (1 + small_noise))

#define shrink(noise) (noise * pow(2, -17))

#define xxhash3(data, len, seed) XXH3_64bits_withSeed(data, len, seed)

@interface IMPFeatureEncoder()

@property (nonatomic) double modelSeed;

@end

@implementation IMPFeatureEncoder{
    uint64_t _variantSeed;
    uint64_t _valueSeed;
    uint64_t _contextSeed;
}

- (id)initWithModelSeed:(uint64_t)modelSeed{
    if(self = [super init]){
        self.modelSeed = modelSeed;
        _variantSeed = xxhash3("variant", strlen("variant"), self.modelSeed);
        _valueSeed = xxhash3("$value", strlen("$value"), _variantSeed);
        _contextSeed = xxhash3("context", strlen("context"), self.modelSeed);
    }
    return self;
}

- (NSArray<NSDictionary *> *)encodeVariants:(NSArray<NSDictionary*> *)variants
                                      given:(nullable NSDictionary *)context
{
    [NSException raise:@"TODO filter valid feature names from model" format:@"TODO"];
    
    double noise = ((double)arc4random() / UINT32_MAX); // between 0.0 and 1.0

    // if context, encode contextFeatures
    NSDictionary *contextFeatures = context ? [self encodeContext:context withNoise:noise] : nil;
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:variants.count];
    for (NSDictionary *variant in variants) {
        NSMutableDictionary *variantFeatures = contextFeatures ? [contextFeatures mutableCopy] : [[NSMutableDictionary alloc] init];
        
        [result addObject:[self encodeVariant:variant withNoise:noise forFeatures:variantFeatures]];
    }
    return result;
}

- (NSDictionary *)encodeContext:(id)context withNoise:(double)noise{
    NSMutableDictionary<NSString*, NSNumber*> *features = [[NSMutableDictionary alloc] init];
    double shrinkedNoise = shrink(noise);
    return [self encodeInternal:context withSeed:_contextSeed andNoise:shrinkedNoise forFeatures:features];
}

- (NSDictionary *)encodeVariant:(id)variant withNoise:(double)noise forFeatures:(nonnull NSMutableDictionary *)features{
    double small_noise = shrink(noise);
    
    if([variant isKindOfClass:[NSDictionary class]]){
        return [self encodeInternal:variant withSeed:_variantSeed andNoise:small_noise forFeatures:features];
    } else {
        return [self encodeInternal:variant withSeed:_valueSeed andNoise:small_noise forFeatures:features];
    }
}

- (NSDictionary *)encodeInternal:(id)context withSeed:(uint64_t)seed andNoise:(double)noise forFeatures:(NSMutableDictionary *)features{
    if([context isKindOfClass:[NSNumber class]]){
        NSString *feature_name = [self hash_to_feature_name:seed];
        NSNumber *curValue = [features objectForKey:feature_name];
        NSNumber *newValue = [NSNumber numberWithDouble:([curValue doubleValue] + sprinkle([context doubleValue], noise))];
        [features setObject:newValue forKey:feature_name];
    } else if([context isKindOfClass:[NSString class]]){
        const char *value = [context UTF8String];
        uint64_t hashed = xxhash3(value, strlen(value), seed);
        
        NSString *feature_name = [self hash_to_feature_name:seed];
        NSNumber *curValue = [features objectForKey:feature_name];
        NSNumber *newValue = [NSNumber numberWithDouble:([curValue doubleValue] + sprinkle((double)((hashed & 0xffff0000) >> 16) - 0x8000, noise))];
        [features setObject:newValue forKey:feature_name];
        NSString *hashed_feature_name = [self hash_to_feature_name:hashed];
        NSNumber *curHashedValue = [features objectForKey:hashed_feature_name];
        NSNumber *newHashedValue = [NSNumber numberWithDouble:([curHashedValue doubleValue] + sprinkle((double)(hashed & 0xffff) - 0x8000, noise))]; // the double type cast here cannot be omitted. Guess why?
        [features setObject:newHashedValue forKey:hashed_feature_name];
    } else if([context isKindOfClass:[NSDictionary class]]){
        [context enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            const char* ckey = [key UTF8String];
            uint64_t newSeed = xxhash3(ckey, strlen(ckey), seed);
            [self encodeInternal:obj withSeed:newSeed andNoise:noise forFeatures:features];
        }];
    } else if([context isKindOfClass:[NSArray class]]){
        [context enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            unsigned char bytes[8];
            [self to_bytes:idx withBuffer:bytes];
            uint64_t newSeed = xxhash3(bytes, 8, seed);
            [self encodeInternal:obj withSeed:newSeed andNoise:noise forFeatures:features];
        }];
    }
    return features;
}

- (NSString *)hash_to_feature_name:(uint64_t)hash{
    char buffer[12];
    sprintf(buffer, "%x", (uint32_t)(hash>>32));
    return @(buffer);
}

// convert uint64_t to 8 bytes
- (void)to_bytes:(uint64_t)n withBuffer:(unsigned char*)buf{
    for(int i = 0; i < 8; ++i){
        buf[i] = (n >> (7-i)*8) & 0xff;
    }
}



@end
