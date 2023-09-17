//
//  NSString+Utilities.m
//  Factl
//
//  Created by anshaggarwal on 5/4/18.
//  Copyright (c) 2018 Factl. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

+ (BOOL)isNilOrEmpty:(NSString *)string
{
    if ((NSNull *) string == [NSNull null])
    {
        return YES;
    }
    
    if (!string || string.length <= 0)
    {
        return YES;
    }

    if([string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <= 0)
    {
        return YES;
    }
    return NO;
}

@end

