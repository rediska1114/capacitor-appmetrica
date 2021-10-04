import Capacitor
import Foundation
import YandexMobileMetrica

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(Appmetrica)
public class Appmetrica: CAPPlugin {
    override public func load() {
        // Initializing the AppMetrica SDK.
        let apiKey = getConfigValue("apiKey") as! String
        let logs = getConfigValue("logs") as? Bool
        let configuration = YMMYandexMetricaConfiguration(apiKey: apiKey)
        if let logs = logs {
            configuration?.logs = logs
        }

        YMMYandexMetrica.activate(with: configuration!)

        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenUrl(_:)), name: Notification.Name(CAPNotifications.URLOpen.name()), object: nil)
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

    @objc
    func setUserProfileID(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            return call.reject("Missing id argument")
        }

        YMMYandexMetrica.setUserProfileID(id)

        call.success()
    }

    @objc
    func handleOpenUrl(_ notification: Notification) {
        guard let object = notification.object as? [String: Any] else {
            print("There is no object on handleOpenUrl")
            return
        }
        guard let url = object["url"] as? URL else {
            print("There is no url on handleOpenUrl")
            return
        }
        YMMYandexMetrica.handleOpen(url)
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
                profile.apply(userProfileBoolDictionary(methodName, key, values))
            } else if attributeName == "customCounter" {
                profile.apply(userProfileCounterFromDictionary(methodName, key, values))
            } else if attributeName == "customNumber" {
                profile.apply(userProfileNumberFromDictionary(methodName, key, values))
            } else if attributeName == "customString" {
                profile.apply(userProfileStringFromDictionary(methodName, key, values))
            } else {
                call.reject("Unknown attribute " + attributeName)
            }
        }

        YMMYandexMetrica.reportUserProfile(profile, onFailure: { error in
            call.reject(error.localizedDescription)
        })

        return call.resolve()
    }

    func userProfileBirthDateFromDictionary(_ methodName: String, _ values: [Any]) -> YMMUserProfileUpdate {
        let userProfileUpdate: YMMUserProfileUpdate = nil
        if methodName == "withAge" {
            userProfileUpdate = YMMProfileAttribute.birthDate().withBirthDate(values[0] as! Int)
        } else if methodName == "withBirthDate" {
            let date: DateComponents
            if values.count >= 1 {
                date.year = values[0] as! Int
            }
            if values.count >= 2 {
                date.month = values[1] as! Int
            }
            if values.count >= 3 {
                date.day = values[2] as! Int
            }
            userProfileUpdate = YMMProfileAttribute.birthDate().withDateComponents(values[0] as! Int)
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.birthDate().withValueReset()
        } else {
            print("Unknown method" + methodName)
        }
        return userProfileUpdate
    }

    func userProfileGenderTypeFromString(_ genderType: String) -> YMMGenderType {
        if genderType == "MALE" {
            return YMMGenderTypeMale
        } else if genderType == "FEMALE" {
            return YMMGenderTypeFemale
        }
        return YMMGenderTypeOther
    }

    func serProfileGenderFromDictionary(_ methodName: String, _ values: [Any]) -> YMMUserProfileUpdate
    {
        let userProfileUpdate: YMMUserProfileUpdate = nil
        if methodName == "withValue" {
            let genderType: YMMGenderType = userProfileGenderTypeFromString(values[0])
            userProfileUpdate = YMMProfileAttribute.gender().withValue(genderType)
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.gender().withValueReset
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate
    }

    func userProfileNameFromDictionary(_ methodName: String, _ values: [Any]) -> YMMUserProfileUpdate {
        let userProfileUpdate: YMMUserProfileUpdate = nil
        if methodName == "withValue" {
            userProfileUpdate = YMMProfileAttribute.name().withValue(values[0])
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.name().withValueReset()
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate
    }

    func userProfileNotificationsEnabledFromDictionary(_ methodName: String, _ values: [Any]) -> YMMUserProfileUpdate {
        let userProfileUpdate: YMMUserProfileUpdate = nil
        if methodName == "withValue" {
            userProfileUpdate = YMMProfileAttribute.notificationsEnabled().withValue(values[0] as! Bool)
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.notificationsEnabled().withValueReset()
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate
    }

    func userProfileBoolDictionary(_ methodName: String, _ key: String, _ values: [Any]) -> YMMUserProfileUpdate
    {
        let userProfileUpdate: YMMUserProfileUpdate = nil
        if methodName == "withValue" {
            userProfileUpdate = YMMProfileAttribute.customBool(key).withValue(values[0] as! Bool)
        } else if methodName == "withValueIfUndefined" {
            userProfileUpdate = YMMProfileAttribute.customBool(key).withValueIfUndefined(values[0] as! Bool)
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.customBool(key).withValueReset()
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate
    }

    func userProfileCounterFromDictionary(_ methodName: String, _ key: String, _ values: [Any]) -> YMMUserProfileUpdate
    {
        let userProfileUpdate: YMMUserProfileUpdate = nil
        if methodName == "withDelta" {
            userProfileUpdate = YMMProfileAttribute.customCounter(key).withDelta(values[0] as! Double)
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate
    }

    func userProfileNumberFromDictionary(_ methodName: String, _ key: String, _ values: [Any]) -> YMMUserProfileUpdate
    {
        let userProfileUpdate: YMMUserProfileUpdate = nil
        if methodName == "withValue" {
            userProfileUpdate = YMMProfileAttribute.customNumber(key).withValue(values[0] as! Double)
        } else if methodName == "withValueIfUndefined" {
            userProfileUpdate = YMMProfileAttribute.customNumber(key).withValueIfUndefined(values[0] as! Double)
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.customNumber(key).withValueReset()
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate
    }

    func userProfileStringFromDictionary(_ methodName: String, _ key: String, _ values: [Any]) -> YMMUserProfileUpdate
    {
        let userProfileUpdate: YMMUserProfileUpdate = nil
        if methodName == "withValue" {
            userProfileUpdate = YMMProfileAttribute.customString(key).withValue(values[0])
        } else if methodName == "withValueIfUndefined" {
            userProfileUpdate = YMMProfileAttribute.customString(key).withValueIfUndefined(values[0])
        } else if methodName == "withValueReset" {
            userProfileUpdate = YMMProfileAttribute.customString(key).withValueReset()
        } else {
            print("Unknown method " + methodName)
        }
        return userProfileUpdate
    }
}
