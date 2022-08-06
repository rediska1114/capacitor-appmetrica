import Capacitor
import CoreLocation
import Foundation
import YandexMobileMetrica


/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(AppmetricaPlugin)
public class AppmetricaPlugin: CAPPlugin {
    @objc func activate(_ call: CAPPluginCall) {
        guard let apiKey = call.getString("apiKey") else {
            return call.reject("Missing apiKey argument")
        }

        // Initializing the AppMetrica SDK.

        let configuration = YMMYandexMetricaConfiguration(apiKey: apiKey)

        if let appVersion = call.getString("appVersion") {
            configuration?.appVersion = appVersion
        }
        if let crashReporting = call.getBool("crashReporting") {
            configuration?.crashReporting = crashReporting
        }
        if let activationAsSessionStart = call.getBool("activationAsSessionStart") {
            configuration?.handleActivationAsSessionStart = activationAsSessionStart
        }
        if let firstActivationAsUpdate = call.getBool("firstActivationAsUpdate") {
            configuration?.handleFirstActivationAsUpdate = firstActivationAsUpdate
        }
        if let location = call.getObject("location") {
            configuration?.location = locationForDictionary(location as! [String: Double]?)
        }
        if let locationTracking = call.getBool("locationTracking") {
            configuration?.locationTracking = locationTracking
        }
        if let userProfileID = call.getString("userProfileID") {
            configuration?.userProfileID = userProfileID
        }
        if let appOpenTrackingEnabled = call.getBool("appOpenTrackingEnabled") {
            configuration?.appOpenTrackingEnabled = appOpenTrackingEnabled
        }
        if let revenueAutoTrackingEnabled = call.getBool("revenueAutoTrackingEnabled") {
            configuration?.revenueAutoTrackingEnabled = revenueAutoTrackingEnabled
        }
        if let logs = call.getBool("logs") {
            configuration?.logs = logs
        }
        if let preloadInfo = call.getObject("preloadInfo") {
            configuration?.preloadInfo = preloadInfoForDictionary(preloadInfo)
        }
        if let sessionsAutoTracking = call.getBool("sessionsAutoTracking") {
            configuration?.sessionsAutoTracking = sessionsAutoTracking
        }
        if let sessionTimeout = call.getInt("sessionTimeout") {
            configuration?.sessionTimeout = UInt(sessionTimeout)
        }
        if let statisticsSending = call.getBool("statisticsSending") {
            configuration?.statisticsSending = statisticsSending
        }

        YMMYandexMetrica.activate(with: configuration!)

        call.resolve()
    }

    @objc func pauseSession(_ call: CAPPluginCall) {
        YMMYandexMetrica.pauseSession()
        call.resolve()
    }

    @objc func sendEventsBuffer(_ call: CAPPluginCall) {
        YMMYandexMetrica.sendEventsBuffer()
        call.resolve()
    }

    @objc func resumeSession(_ call: CAPPluginCall) {
        YMMYandexMetrica.resumeSession()
        call.resolve()
    }

    @objc func setLocationTracking(_ call: CAPPluginCall) {
        guard let enabled = call.getBool("enabled") else {
            return call.reject("Missing enabled argument")
        }
        YMMYandexMetrica.setLocationTracking(enabled)
        call.resolve()
    }

    @objc func setStatisticsSending(_ call: CAPPluginCall) {
        guard let enabled = call.getBool("enabled") else {
            return call.reject("Missing enabled argument")
        }
        YMMYandexMetrica.setStatisticsSending(enabled)
        call.resolve()
    }

    @objc func setLocation(_ call: CAPPluginCall) {
        guard let location = call.getObject("location") else {
            return call.reject("Missing location argument")
        }
        YMMYandexMetrica.setLocation(locationForDictionary(location as! [String: Double]?))
        call.resolve()
    }

    @objc func reportAppOpen(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url") else {
            return call.reject("Missing url argument")
        }
        guard let url = URL(string: urlString) else {
            return call.reject("Bad url argument")
        }
        YMMYandexMetrica.handleOpen(url)
        call.resolve()
    }

    @objc func reportError(_ call: CAPPluginCall) {
        guard let identifier = call.getString("identifier") else {
            return call.reject("Missing identifier argument")
        }
        let parameters = call.getObject("parameters")
        let message = call.getString("message")

        let error = YMMError(
            identifier: identifier,
            message: message,
            parameters: parameters
        )

        YMMYandexMetrica.report(error: error, onFailure: { err in
            call.reject(err.localizedDescription)
        })
        call.resolve()
    }

    @objc func reportEvent(_ call: CAPPluginCall) {
        guard let name = call.getString("name") else {
            return call.reject("Missing name argument")
        }
        let parameters = call.getObject("parameters") ?? nil

        YMMYandexMetrica.reportEvent(name, parameters: parameters, onFailure: { error in
            call.reject(error.localizedDescription)
        })

        call.success()
    }

    @objc func reportReferralUrl(_ call: CAPPluginCall) {
        guard let referralUrl = call.getString("referralUrl") else {
            return call.reject("Missing referralUrl argument")
        }

        guard let url = URL(string: referralUrl) else {
            return call.reject("Bad referralUrl argument")
        }

        YMMYandexMetrica.reportReferralUrl(url)
        call.success()
    }

    @objc
    func setUserProfileID(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            return call.reject("Missing id argument")
        }

        YMMYandexMetrica.setUserProfileID(id)

        call.success()
    }

    @objc
    func getDeviceID(_ call: CAPPluginCall) {
        YMMYandexMetrica.requestAppMetricaDeviceID(withCompletionQueue: nil) { deviceID, error in
            if let error = error {
                return call.reject(error.localizedDescription)
            }

            return call.resolve([
                "deviceID": deviceID!,
            ])
        }
    }

    @objc
    func reportUserProfile(_ call: CAPPluginCall) {
        guard let updates = call.getArray("updates", [String: Any].self) else {
            return call.reject("Missing updates argument")
        }

        let profile = YMMMutableUserProfile()

        for update in updates {
            let attributeName = update["attributeName"] as! String
            let methodName = update["methodName"] as! String
            let key = update["key"] as? String
            let values = update["values"] as? [Any] ?? []
            if attributeName == "birthDate" {
                profile.apply(userProfileBirthDateFromDictionary(methodName, values))
            } else if attributeName == "gender" {
                profile.apply(userProfileGenderFromDictionary(methodName, values))
            } else if attributeName == "name" {
                profile.apply(userProfileNameFromDictionary(methodName, values))
            } else if attributeName == "notificationsEnabled" {
                profile.apply(userProfileNotificationsEnabledFromDictionary(methodName, values))
            } else if attributeName == "customBoolean" {
                profile.apply(userProfileBoolDictionary(methodName, key!, values))
            } else if attributeName == "customCounter" {
                profile.apply(userProfileCounterFromDictionary(methodName, key!, values))
            } else if attributeName == "customNumber" {
                profile.apply(userProfileNumberFromDictionary(methodName, key!, values))
            } else if attributeName == "customString" {
                profile.apply(userProfileStringFromDictionary(methodName, key!, values))
            } else {
                call.reject("Unknown attribute " + attributeName)
            }
        }

        YMMYandexMetrica.report(profile, onFailure: { error in
            call.reject(error.localizedDescription)
        })

        return call.resolve()
    }

    @objc
    private func userProfileBirthDateFromDictionary(_ methodName: String, _ values: [Any]) -> YMMUserProfileUpdate {
        var userProfileUpdate: YMMUserProfileUpdate?
        if methodName == "withAge" {
            userProfileUpdate = YMMProfileAttribute.birthDate().withAge(values[0] as! UInt)
        } else if methodName == "withBirthDate" {
            var date = DateComponents()
            if values.count >= 1 {
                date.year = values[0] as? Int
            }
            if values.count >= 2 {
                date.month = values[1] as? Int
            }
            if values.count >= 3 {
                date.day = values[2] as? Int
            }
            userProfileUpdate = YMMProfileAttribute.birthDate().withDate(dateComponents: date)
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.birthDate().withValueReset()
        } else {
            print("Unknown method" + methodName)
        }
        return userProfileUpdate!
    }

    @objc private func userProfileGenderTypeFromString(_ genderType: String) -> YMMGenderType {
        if genderType == "MALE" {
            return YMMGenderType.male
        } else if genderType == "FEMALE" {
            return YMMGenderType.female
        }
        return YMMGenderType.other
    }

    @objc private func userProfileGenderFromDictionary(_ methodName: String, _ values: [Any]) -> YMMUserProfileUpdate
    {
        var userProfileUpdate: YMMUserProfileUpdate?
        if methodName == "withValue" {
            let genderType: YMMGenderType = userProfileGenderTypeFromString(values[0] as! String)
            userProfileUpdate = YMMProfileAttribute.gender().withValue(genderType)
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.gender().withValueReset()
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate!
    }

    @objc private func userProfileNameFromDictionary(_ methodName: String, _ values: [Any]) -> YMMUserProfileUpdate {
        var userProfileUpdate: YMMUserProfileUpdate?
        if methodName == "withValue" {
            userProfileUpdate = YMMProfileAttribute.name().withValue(values[0] as? String)
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.name().withValueReset()
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate!
    }

    @objc private func userProfileNotificationsEnabledFromDictionary(_ methodName: String, _ values: [Any]) -> YMMUserProfileUpdate {
        var userProfileUpdate: YMMUserProfileUpdate?
        if methodName == "withValue" {
            userProfileUpdate = YMMProfileAttribute.notificationsEnabled().withValue(values[0] as! Bool)
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.notificationsEnabled().withValueReset()
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate!
    }

    @objc private func userProfileBoolDictionary(_ methodName: String, _ key: String, _ values: [Any]) -> YMMUserProfileUpdate
    {
        var userProfileUpdate: YMMUserProfileUpdate?
        if methodName == "withValue" {
            userProfileUpdate = YMMProfileAttribute.customBool(key).withValue(values[0] as! Bool)
        } else if methodName == "withValueIfUndefined" {
            userProfileUpdate = YMMProfileAttribute.customBool(key).withValueIfUndefined(values[0] as! Bool)
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.customBool(key).withValueReset()
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate!
    }

    @objc private func userProfileCounterFromDictionary(_ methodName: String, _ key: String, _ values: [Any]) -> YMMUserProfileUpdate
    {
        var userProfileUpdate: YMMUserProfileUpdate?
        if methodName == "withDelta" {
            userProfileUpdate = YMMProfileAttribute.customCounter(key).withDelta(values[0] as! Double)
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate!
    }

    @objc private func userProfileNumberFromDictionary(_ methodName: String, _ key: String, _ values: [Any]) -> YMMUserProfileUpdate
    {
        var userProfileUpdate: YMMUserProfileUpdate?
        if methodName == "withValue" {
            userProfileUpdate = YMMProfileAttribute.customNumber(key).withValue(values[0] as! Double)
        } else if methodName == "withValueIfUndefined" {
            userProfileUpdate = YMMProfileAttribute.customNumber(key).withValueIfUndefined(values[0] as! Double)
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.customNumber(key).withValueReset()
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate!
    }

    @objc private func userProfileStringFromDictionary(_ methodName: String, _ key: String, _ values: [Any]) -> YMMUserProfileUpdate
    {
        var userProfileUpdate: YMMUserProfileUpdate?
        if methodName == "withValue" {
            userProfileUpdate = YMMProfileAttribute.customString(key).withValue(values[0] as? String)
        } else if methodName == "withValueIfUndefined" {
            userProfileUpdate = YMMProfileAttribute.customString(key).withValueIfUndefined(values[0] as? String)
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.customString(key).withValueReset()
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate!
    }

    @objc private func locationForDictionary(_ locationDict: [String: Double]?) -> CLLocation? {
        if locationDict == nil {
            return nil
        }

        let latitude = Double(locationDict!["latitude"]!)
        let longitude = Double(locationDict!["longitude"]!)
        let altitude = Double(locationDict!["altitude"]!)
        let horizontalAccuracy = Double(locationDict!["accuracy"]!)
        let verticalAccuracy = Double(locationDict!["verticalAccuracy"]!)
        let course = Double(locationDict!["course"]!)
        let speed = Double(locationDict!["speed"]!)
        let timestamp = locationDict!["timestamp"]

        let locationDate = timestamp != nil ? Date(timeIntervalSince1970: Double(timestamp!)) : Date()
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: locationDate)

        return location
    }

    @objc private func preloadInfoForDictionary(_ preloadInfoDict: [String: Any]?) -> YMMYandexMetricaPreloadInfo?
    {
        if preloadInfoDict == nil {
            return nil
        }

        let trackingId = preloadInfoDict!["trackingId"]
        let preloadInfo = YMMYandexMetricaPreloadInfo(trackingIdentifier: trackingId as! String)

        let additionalInfo = preloadInfoDict!["additionalInfo"] as? [String: Any]
        if additionalInfo != nil {
            for (key, value) in additionalInfo! {
                preloadInfo?.setAdditional(value as! String, forKey: key)
            }
        }

        return preloadInfo
    }
}
