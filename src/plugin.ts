import { AppmetricaPlugin as IAppmetricaPlugin } from './definitions';
import { Plugins } from '@capacitor/core';

const AppmetricaPlugin = Plugins.Appmetrica as IAppmetricaPlugin;

export class Appmetrica {
  private appmetrica = AppmetricaPlugin;

  reportEvent(name: string, parameters?: Object) {
    return this.appmetrica.reportEvent({ name, parameters });
  }

  setUserProfileID(id: string) {
    return this.appmetrica.setUserProfileID({ id });
  }

  getDeviceID() {
    return this.appmetrica.getDeviceID().then(({ deviceID }) => deviceID);
  }
}
