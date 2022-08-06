import { UserProfile } from './profile';
import { registerPlugin } from '@capacitor/core';

import type {
  AppmetricaActivateOptions,
  AppmetricaLocation,
  AppmetricaPlugin,
} from './definitions';

const CapacitorAppmetrica = registerPlugin<AppmetricaPlugin>('Appmetrica', {
  // web: () => import('./web').then(m => new m.AppmetricaWeb()),
});

export * from './definitions';
export * from './profile'

export class Appmetrica {
  private appmetrica = CapacitorAppmetrica;

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
