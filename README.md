# Capacitor Appmetrica plugin

Currently only works on ios, but android support will be coming soon

# Available methods:

- logEvent
- setUserProfileID
- reportUserProfile
- getDeviceID

# Usage example:

0. Add in `capacitor.config.json`

```json
{
	"plugins": {
		"Appmetrica": {
			"apiKey": "Your API key"
		}
	}
```

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
