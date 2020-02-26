//
//  IMPModelMetadata.h
//  ImproveUnitTests
//
//  Created by Vladimir on 2/24/20.
//  Copyright © 2020 Mind Blown Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMPModelMetadata : NSObject

@property (assign, nonatomic) NSUInteger numberOfFeatures;

@property (copy, nonatomic) NSString *hashPrefix;

@property (copy, nonatomic) NSString *modelId;

/**
 If YES, the timestamp must be automatically included to the context of `choose` and `rank`.
 Default is NO.
 */
@property (assign, nonatomic) BOOL shouldAutomaticallyAddTimestamp;

// coming later: hashing tables

+ (nullable instancetype)metadataWithURL:(NSURL *)url;

- (nullable instancetype)initWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
