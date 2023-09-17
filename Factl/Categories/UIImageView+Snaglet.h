//
//  UIImageView+Snaglet.h
//  Snaglet
//
//  Created by anshaggarwal on 5/4/18.
//  Copyright (c) 2018 Snaglet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Snaglet)

-(void)snaglet_setImageWithURL:(NSURL *)url imageSent:(BOOL)imageSent placeholderImage:(UIImage *)placeholder;

@end
