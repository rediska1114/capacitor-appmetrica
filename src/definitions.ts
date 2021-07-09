declare module '@capacitor/core' {
  interface PluginRegistry {
    Appmetrica: AppmetricaPlugin;
  }
}

export interface AppmetricaPlugin {
  logEvent(options: { name: string; parameters?: Object }): Promise<void>;
  setUserProfileID(options: { id: string }): Promise<void>;
}
