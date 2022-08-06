#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(AppmetricaPlugin, "Appmetrica",
          CAP_PLUGIN_METHOD(activate, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(pauseSession, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(sendEventsBuffer, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(resumeSession, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setLocationTracking, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setStatisticsSending, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setLocation, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(reportAppOpen, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(reportError, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(reportEvent, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(reportReferralUrl, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setUserProfileID, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getDeviceID, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(reportUserProfile, CAPPluginReturnPromise);           
)
