import {
  AppmetricaActivateOptions,
  AppmetricaLocation,
  AppmetricaPlugin as IAppmetricaPlugin,
} from './definitions';
import { Plugins } from '@capacitor/core';
import { UserProfile } from './profile';

const AppmetricaPlugin = Plugins.Appmetrica as IAppmetricaPlugin;

export class Appmetrica {
  private appmetrica = AppmetricaPlugin;

  activate(apiKey: string, options: AppmetricaActivateOptions = {}) {
    return this.appmetrica.activate({ apiKey, ...options });
  }
  pauseSession() {
    return this.appmetrica.pauseSession();
  }
  sendEventsBuffer() {
    return this.appmetrica.sendEventsBuffer();
  }
  resumeSession() {
    return this.appmetrica.resumeSession();
  }
  setLocationTracking(enabled: boolean) {
    return this.appmetrica.setLocationTracking({ enabled });
  }
  setStatisticsSending(enabled: boolean) {
    return this.appmetrica.setStatisticsSending({ enabled });
  }
  setLocation(location: AppmetricaLocation) {
    return this.appmetrica.setLocation({ location });
  }
  reportAppOpen(url: string) {
    return this.appmetrica.reportAppOpen({ url });
  }
  reportError(identifier: string, message?: string, parameters?: Object) {
    return this.appmetrica.reportError({ identifier, message, parameters });
  }
  reportEvent(name: string, parameters?: Object) {
    return this.appmetrica.reportEvent({ name, parameters });
  }
  reportReferralUrl(referralUrl: string) {
    return this.appmetrica.reportReferralUrl({ referralUrl });
  }
  setUserProfileID(id: string) {
    return this.appmetrica.setUserProfileID({ id });
  }
  getDeviceID() {
    return this.appmetrica.getDeviceID().then(({ deviceID }) => deviceID);
  }
  reportUserProfile(profile: UserProfile) {
    const updates = profile.updates.map(m => ({
      attributeName: m.attributeName,
      methodName: m.methodName,
      key: m.key,
      values: m.values,
    }));

    return this.appmetrica.reportUserProfile({ updates });
  }
}
