//
//  DALImageCache.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-27.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DALImageCache : NSCache
/**
 @return The shared instance of SMKArtworkCache
 */
+ (instancetype)sharedCache;

/**
 Compression quality of the image, 1.0 being best quality and 0.0 being lowest.
 Default value is 1.0.
 */
@property (nonatomic, assign) CGFloat JPEGCompressionQuality;

/**
 Maximum size of the on disk cache, in MB
 Default maximum size is 200MB.
 */
@property (nonatomic, assign) NSUInteger maximumDiskCacheSize;
/**
 Asynchronously fetches a cached image and calls the completion handler
 @param key The cached image key
 @param handler Hander block called with the fetched image
 */
- (void)fetchImageForKey:(NSString *)key completionHandler:(void (^)(UIImage *image))handler;

/**
 Saves an image in the cache with the specified key
 @param key The key to save the cached image under
 @param image The image to save
 */
- (void)setCachedImage:(UIImage *)image
                forKey:(NSString *)key;

/**
 Removes the image with the specified key from the cache
 @param key The key of the image to remove from the cache
 */
- (void)removeCachedImageForKey:(NSString *)key;

/**
 Removes every image in the cache (including on disk)
 */
- (void)removeAllCachedImages;
@end
