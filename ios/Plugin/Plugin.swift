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
        YMMYandexMetrica.requestAppMetricaDeviceID(withCompletionQueue: nil) { deviceId, error in
            if let error = error {
                return call.reject(error.localizedDescription)
            }

            return call.resolve([
                "deviceId": deviceId!
            ])
        }
    }
}
