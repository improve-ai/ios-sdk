//
//  IMPConfiguration.m
//  ImproveUnitTests
//
//  Created by Vladimir on 2/23/20.
//  Copyright © 2020 Mind Blown Apps, LLC. All rights reserved.
//

#import "IMPConfiguration.h"

@implementation IMPConfiguration

+ (instancetype)configurationWithAPIKey:(NSString *)apiKey
                                 userId:(nullable NSString *)userId
                             modelNames:(NSArray<NSString*> *)modelNames
{
    id configuration = [[self alloc] initWithAPIKey:apiKey
                                             userId:userId
                                         modelNames:modelNames];
    return configuration;
}

+ (instancetype)configurationWithAPIKey:(NSString *)apiKey
                             modelNames:(NSArray<NSString*> *)modelNames
{
    return [self configurationWithAPIKey:apiKey modelNames:modelNames];
}

- (instancetype)initWithAPIKey:(NSString *)apiKey
                        userId:(nullable NSString *)userId
                    modelNames:(NSArray<NSString*> *)modelNames
{
    self = [super init];
    if (!self) return nil;

    _apiKey = [apiKey copy];
    _userId = [userId copy];
    _modelNames = [modelNames copy];

    return self;
}

- (instancetype)initWithAPIKey:(NSString *)apiKey
                    modelNames:(NSArray<NSString*> *)modelNames
{
    return [self initWithAPIKey:apiKey userId:nil modelNames:modelNames];
}

- (NSURL *)modelURLForName:(NSString *)modelName {
    // TODO: It's just a stab, actual implementation pending.
    NSString *endpoint = @"https://api.improve.ai/v3/models";
    NSString *path = [NSString stringWithFormat:@"%@/%@.tar.gz", endpoint, modelName];
    NSURL *url = [NSURL URLWithString:path];
    return url;
}

@end
