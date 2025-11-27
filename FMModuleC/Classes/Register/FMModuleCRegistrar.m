//
//  FMModuleCRegistrar.m
//  FMModuleC
//
//  Created by FumingLeo on 2025/11/21.
//

#import "FMModuleCRegistrar.h"
#import "FMModuleC/FMModuleC-Swift.h"

@implementation FMModuleCRegistrar

+ (void)load {
    [FMModuleC registerService];
}

@end
