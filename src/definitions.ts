import type { UserProfileUpdate } from './profile';

export interface AppmetricaPlugin {
  activate(
    options: AppmetricaActivateOptions & { apiKey: string },
  ): Promise<void>;
  pauseSession(): Promise<void>;
  sendEventsBuffer(): Promise<void>;
  resumeSession(): Promise<void>;
  setLocationTracking(options: { enabled: boolean }): Promise<void>;
  setStatisticsSending(options: { enabled: boolean }): Promise<void>;
  setLocation(options: { location: AppmetricaLocation }): Promise<void>;
  reportAppOpen(options: { url: string }): Promise<void>;
  reportError(options: AppmetricaReportErrorOptions): Promise<void>;
  reportEvent(options: { name: string; parameters?: Object }): Promise<void>;
  reportReferralUrl(options: { referralUrl: string }): Promise<void>;
  setUserProfileID(options: { id: string }): Promise<void>;
  getDeviceID(): Promise<{ deviceID: string }>;
  reportUserProfile(options: { updates: UserProfileUpdate[] }): Promise<void>;
}

export interface AppmetricaActivateOptions {
  appVersion?: string;
  crashReporting?: boolean;
  activationAsSessionStart?: boolean;
  firstActivationAsUpdate?: boolean;
  location?: AppmetricaLocation;
  locationTracking?: boolean;
  userProfileID?: string;
  appOpenTrackingEnabled?: boolean;
  revenueAutoTrackingEnabled?: boolean;
  logs?: boolean;
  preloadInfo?: AppmetricaPreloadInfo;
  sessionsAutoTracking?: boolean;
  sessionTimeout?: number;
  statisticsSending?: boolean;
}

export interface AppmetricaReportErrorOptions {
  identifier: string;
  parameters?: object;
  message?: string;
}

export interface AppmetricaLocation {
  latitude: number;
  longitude: number;
  altitude: number;
  accuracy: number;
  verticalAccuracy: number;
  course: number;
  speed: number;
  timestamp?: number;
}

export type AppmetricaPreloadInfo = {
  trackingId: string;
  additionalInfo?: Record<string, string>;
};
