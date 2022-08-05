# Capacitor Appmetrica plugin

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

# Usage example:

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
