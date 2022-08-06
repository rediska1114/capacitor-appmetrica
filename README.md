# Capacitor Appmetrica plugin [![npm version](https://badge.fury.io/js/capacitor-appmetrica.svg)](https://badge.fury.io/js/capacitor-appmetrica)

# Available methods:

- activate()
- pauseSession()
- sendEventsBuffer()
- resumeSession()
- setLocationTracking()
- setStatisticsSending()
- setLocation()
- reportAppOpen()
- reportError()
- reportEvent()
- reportReferralUrl()
- setUserProfileID()
- getDeviceID()
- reportUserProfile()

# Angular usage example:

1. In your module (e.g. `app.module.ts`)

```ts
...
import { Appmetrica } from 'capacitor-appmetrica'

@NgModule({
	...
	providers: [
		...
		Appmetrica,
	],
})
export class AppModule {}

```

2. In your component or service (e.g. `analytics.service.ts`)

```ts
...
import { Appmetrica, UserProfile, ProfileAttribute } from 'capacitor-appmetrica'

@Injectable()
export class AnalyticsService {
	constructor(private appmetrica: Appmetrica) {}

	async initialization() {
		await this.appmetrica.activate("<SDK_API_KEY>", { logs: true })
	}

	async logEvent(name: string, params?: Object) {
		await this.appmetrica.logEvent(name, params)
	}

	async setUserProfileID(id: string) {
		return this.appmetrica.setUserProfileID(id)
	}

	async reportUserProfile() {
		const userProfile = new UserProfile()
		userProfile.applyFromArray([
			ProfileAttribute.Name().withValue('Ivan'),
			ProfileAttribute.BirthDate().withBirthDate(new Date()),
			ProfileAttribute.CustomString('born_in').withValueIfUndefined('Moscow'),
		])

		await this.appmetrica.reportUserProfile(userProfile)
	}

	async getDeviceID(): string {
		return this.appmetrica.getDeviceID()
	}
}

```

# React usage example:

```tsx
import { Appmetrica } from 'capacitor-appmetrica';

export function useAppmetrica() {
  return useRef(new Appmetrica());
}
```

```tsx
import {
  Appmetrica,
  UserProfile,
  ProfileAttribute,
} from 'capacitor-appmetrica';

export default function App() {
  const appmetrica = useAppmetrica();

  const [deviceId, setDeviceId] = useState(null);

  useEffect(() => {
    appmetrica.activate('<SDK_API_KEY>', { logs: true });

    appmetrica.getDeviceID().then(deviceId => {
      setDeviceId(deviceId);
    });
  }, []);

  const onButtonClick = () => {
    appmetrica.logEvent('clickButton', { param: 10 });
  };

  const onProfileClick = async () => {
    await appmetrica.setUserProfileID('123');

    const userProfile = new UserProfile();
    userProfile.applyFromArray([
      ProfileAttribute.Name().withValue('Ivan'),
      ProfileAttribute.BirthDate().withBirthDate(new Date()),
      ProfileAttribute.CustomString('born_in').withValueIfUndefined('Moscow'),
    ]);

    await appmetrica.reportUserProfile(userProfile);
  };

  return (
    <div>
      deviceId: {deviceId}
      <button onClick={onButtonClick}>log event</button>
      <button onClick={onProfileClick()}>set profile</button>
    </div>
  );
}
```

## BREAKING CHANGES in 1.x.x

1. Removed automatic initialization of Appmetrica, now you need to initialize it manually using the `activate` method

To migrate, remove the `Appmetrica` settings from the `capacitor.config.json`

```diff
{
	"plugins": {
		...
-		"Appmetrica": {
-			"apiKey": "Your API key"
-			...
-		},
		...
	}
```

and run the `activate` method when the application starts. For example:

```typescript
ngOnInit() {
	this.appmetrica.activate("<API_KEY>", options)
}
```

2. Added Android support

3. Removed support for appmetrica push notifications

4. Added full support for Capacitor 3 and removed compatibility with Capacitor 2
