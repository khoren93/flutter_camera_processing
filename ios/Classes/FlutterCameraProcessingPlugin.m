#import "FlutterCameraProcessingPlugin.h"
#if __has_include(<flutter_camera_processing/flutter_camera_processing-Swift.h>)
#import <flutter_camera_processing/flutter_camera_processing-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_camera_processing-Swift.h"
#endif

@implementation FlutterCameraProcessingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterCameraProcessingPlugin registerWithRegistrar:registrar];
}
@end
