# Installation instructions

Android installation instructions.

*Use the links below to jump to your platform.*

- [Android](#android)
	- [Play Store](#play-store)
	- [Manual installation](#manual)

## Android

> [!IMPORTANT]
> Android support added in v0.8.0.

### Play Store

This is the recommended way to install Fladder on Android.

<a href='https://play.google.com/store/apps/details?id=nl.jknaapen.fladder&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' width=250/></a>

### Manual

If your device can't access the Play Store, you can install Fladder manually.

1. Download the latest `.apk` file from the [Releases](https://github.com/DonutWare/Fladder/releases) page and save it to your device.

2. Open it to start the installation. You may need to allow unknown apps to be installed on your device, as this will be disallowed by default.

## Server Configuration Options

Fladder can be preconfigured by placing a config file in `config/config.json`:

```json
{
	"baseUrl": "https://jellyfin.example.com",
	"seerrBaseUrl": "https://seerr.example.com"
}
```

- `baseUrl`: String. Presets Jellyfin URL on login.
- `seerrBaseUrl`: String. Presets Seerr URL in personal settings.
