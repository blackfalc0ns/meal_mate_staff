//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<driver_voice_engine/DriverVoiceEnginePlugin.h>)
#import <driver_voice_engine/DriverVoiceEnginePlugin.h>
#else
@import driver_voice_engine;
#endif

#if __has_include(<integration_test/IntegrationTestPlugin.h>)
#import <integration_test/IntegrationTestPlugin.h>
#else
@import integration_test;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [DriverVoiceEnginePlugin registerWithRegistrar:[registry registrarForPlugin:@"DriverVoiceEnginePlugin"]];
  [IntegrationTestPlugin registerWithRegistrar:[registry registrarForPlugin:@"IntegrationTestPlugin"]];
}

@end
