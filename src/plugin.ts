import { AppmetricaPlugin as IAppmetricaPlugin } from './definitions';
import { Plugins } from '@capacitor/core';

const AppmetricaPlugin = Plugins.Appmetrica as IAppmetricaPlugin;

export class Appmetrica {
  private appmetrica = AppmetricaPlugin;

  logEvent(name: string, parameters?: Object) {
    return this.appmetrica.logEvent({ name, parameters });
  }
}
