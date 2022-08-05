package com.rediska1114.plugins.capacitorappmetrica;

import static android.content.ContentValues.TAG;

import android.app.Activity;
import android.content.Context;
import android.location.Location;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.yandex.metrica.AppMetricaDeviceIDListener;
import com.yandex.metrica.PreloadInfo;
import com.yandex.metrica.YandexMetrica;
import com.yandex.metrica.YandexMetricaConfig;
import com.yandex.metrica.profile.Attribute;
import com.yandex.metrica.profile.BirthDateAttribute;
import com.yandex.metrica.profile.GenderAttribute;
import com.yandex.metrica.profile.UserProfile;
import com.yandex.metrica.profile.UserProfileUpdate;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import org.json.JSONException;

@NativePlugin
public class Appmetrica extends Plugin {

    @PluginMethod
    public void activate(PluginCall call) {
        final Context context = getContext();
        try {
            YandexMetricaConfig config = toYandexMetricaConfig(call);
            YandexMetrica.activate(context, config);
            enableActivityAutoTracking();
            call.success();
        } catch (JSONException e) {
            call.reject(e.getLocalizedMessage(), e);
        }
    }

    @PluginMethod
    public void pauseSession(PluginCall call) {
        YandexMetrica.pauseSession(getActivity());
        call.success();
    }

    @PluginMethod
    public void sendEventsBuffer(PluginCall call) {
        YandexMetrica.sendEventsBuffer();
        call.success();
    }

    @PluginMethod
    public void resumeSession(PluginCall call) {
        YandexMetrica.resumeSession(getActivity());
        call.success();
    }

    @PluginMethod
    public void setLocationTracking(PluginCall call) {
        Boolean enabled = call.getBoolean("enabled");
        YandexMetrica.setLocationTracking(enabled);
        call.success();
    }

    @PluginMethod
    public void setStatisticsSending(PluginCall call) {
        Boolean enabled = call.getBoolean("enabled");
        YandexMetrica.setStatisticsSending(getContext(), enabled);
        call.success();
    }

    @PluginMethod
    public void setLocation(PluginCall call) {
        JSObject location = call.getObject("location");
        try {
            YandexMetrica.setLocation(toLocation(location));
            call.success();
        } catch (JSONException e) {
            call.reject(e.getLocalizedMessage(), e);
        }
    }

    @PluginMethod
    public void reportAppOpen(PluginCall call) {
        String url = call.getString("url");
        YandexMetrica.reportAppOpen(url);
        call.success();
    }

    @PluginMethod
    public void reportError(PluginCall call) {
        String identifier = call.getString("identifier");
        String message = call.getString("message", "");

        Throwable errorThrowable = message.length() > 0 ? new Throwable(message) : null;
        YandexMetrica.reportError(identifier, errorThrowable);

        call.success();
    }

    @PluginMethod
    public void reportEvent(PluginCall call) {
        String name = call.getString("name");
        JSObject parameters = call.getObject("parameters");
        YandexMetrica.reportEvent(name, parameters.toString());
        call.success();
    }

    @PluginMethod
    public void reportReferralUrl(PluginCall call) {
        String referralUrl = call.getString("referralUrl");
        YandexMetrica.reportReferralUrl(referralUrl);
        call.success();
    }

    @PluginMethod
    public void setUserProfileID(PluginCall call) {
        String id = call.getString("id");
        YandexMetrica.setUserProfileID(id);
        call.success();
    }

    @PluginMethod
    public void getDeviceID(PluginCall call) {
        YandexMetrica.requestAppMetricaDeviceID(new CapacitrorAppMetricaDeviceIDListener(call));
    }

    @PluginMethod
    public void reportUserProfile(PluginCall call) {
        JSArray updates = call.getArray("updates");

        try {
            YandexMetrica.reportUserProfile(toProfile(updates));
            call.success();
        } catch (JSONException e) {
            e.printStackTrace();
            call.reject(e.getLocalizedMessage());
        }
    }

    private UserProfile toProfile(JSArray updates) throws JSONException {
        UserProfile.Builder profile = UserProfile.newBuilder();
        for (ProfileUpdate update : updates.<ProfileUpdate>toList()) {
            switch (update.attributeName) {
                case "birthDate":
                    profile.apply(toUserProfileBirthDate(update.methodName, update.values));
                    break;
                case "gender":
                    profile.apply(toUserProfileGender(update.methodName, update.values));
                    break;
                case "name":
                    profile.apply(toUserProfileName(update.methodName, update.values));
                    break;
                case "notificationsEnabled":
                    profile.apply(toUserProfileNotificationsEnabled(update.methodName, update.values));
                    break;
                case "customBoolean":
                    profile.apply(toUserProfileBool(update.methodName, update.key, update.values));
                    break;
                case "customCounter":
                    profile.apply(toUserProfileCounter(update.methodName, update.key, update.values));
                    break;
                case "customNumber":
                    profile.apply(toUserProfileNumber(update.methodName, update.key, update.values));
                    break;
                case "customString":
                    profile.apply(toUserProfileString(update.methodName, update.key, update.values));
                    break;
                default:
                    throw new Error("Unknown attribute " + update.attributeName);
            }
        }

        return profile.build();
    }

    private void enableActivityAutoTracking() {
        AppCompatActivity activity = getActivity();
        if (activity != null) { // TODO: check
            YandexMetrica.enableActivityAutoTracking(activity.getApplication());
        } else {
            Log.w(TAG, "Activity is not attached");
        }
    }

    private UserProfileUpdate toUserProfileBirthDate(String methodName, Object[] values) {
        UserProfileUpdate update;

        switch (methodName) {
            case "withAge":
                update = Attribute.birthDate().withAge((Integer) values[0]);
                break;
            case "withBirthDate":
                if (values.length >= 1) {
                    update = Attribute.birthDate().withBirthDate((Integer) values[0]);
                } else if (values.length >= 2) {
                    update = Attribute.birthDate().withBirthDate((Integer) values[0], (Integer) values[1]);
                } else {
                    update = Attribute.birthDate().withBirthDate((Integer) values[0], (Integer) values[1], (Integer) values[1]);
                }
                break;
            case "withValueReset":
                update = Attribute.birthDate().withValueReset();
                break;
            default:
                throw new Error("Unknown method" + methodName);
        }

        return update;
    }

    private GenderAttribute.Gender toGender(String gender) {
        if (gender == "MALE") {
            return GenderAttribute.Gender.MALE;
        } else if (gender == "FEMALE") {
            return GenderAttribute.Gender.FEMALE;
        } else {
            return GenderAttribute.Gender.OTHER;
        }
    }

    private UserProfileUpdate toUserProfileGender(String methodName, Object[] values) {
        UserProfileUpdate update;
        switch (methodName) {
            case "withValue":
                update = Attribute.gender().withValue(toGender((String) values[0]));
                break;
            case "withValueReset":
                update = Attribute.gender().withValueReset();
                break;
            default:
                throw new Error("Unknown method" + methodName);
        }
        return update;
    }

    private UserProfileUpdate toUserProfileName(String methodName, Object[] values) {
        UserProfileUpdate update;
        switch (methodName) {
            case "withValue":
                update = Attribute.name().withValue((String) values[0]);
                break;
            case "withValueReset":
                update = Attribute.name().withValueReset();
                break;
            default:
                throw new Error("Unknown method" + methodName);
        }
        return update;
    }

    private UserProfileUpdate toUserProfileNotificationsEnabled(String methodName, Object[] values) {
        UserProfileUpdate update;
        switch (methodName) {
            case "withValue":
                update = Attribute.notificationsEnabled().withValue((Boolean) values[0]);
                break;
            case "withValueReset":
                update = Attribute.notificationsEnabled().withValueReset();
                break;
            default:
                throw new Error("Unknown method" + methodName);
        }
        return update;
    }

    private UserProfileUpdate toUserProfileBool(String methodName, String key, Object[] values) {
        UserProfileUpdate update;
        switch (methodName) {
            case "withValue":
                update = Attribute.customBoolean(key).withValue((Boolean) values[0]);
                break;
            case "withValueIfUndefined":
                update = Attribute.customBoolean(key).withValueIfUndefined((Boolean) values[0]);
                break;
            case "withValueReset":
                update = Attribute.customBoolean(key).withValueReset();
                break;
            default:
                throw new Error("Unknown method" + methodName);
        }
        return update;
    }

    private UserProfileUpdate toUserProfileCounter(String methodName, String key, Object[] values) {
        UserProfileUpdate update;
        switch (methodName) {
            case "withDelta":
                update = Attribute.customCounter(key).withDelta((Double) values[0]);
                break;
            default:
                throw new Error("Unknown method" + methodName);
        }
        return update;
    }

    private UserProfileUpdate toUserProfileNumber(String methodName, String key, Object[] values) {
        UserProfileUpdate update;
        switch (methodName) {
            case "withValue":
                update = Attribute.customNumber(key).withValue((Double) values[0]);
                break;
            case "withValueIfUndefined":
                update = Attribute.customNumber(key).withValueIfUndefined((Double) values[0]);
                break;
            case "withValueReset":
                update = Attribute.customNumber(key).withValueReset();
                break;
            default:
                throw new Error("Unknown method" + methodName);
        }
        return update;
    }

    private UserProfileUpdate toUserProfileString(String methodName, String key, Object[] values) {
        UserProfileUpdate update;
        switch (methodName) {
            case "withValue":
                update = Attribute.customString(key).withValue((String) values[0]);
                break;
            case "withValueIfUndefined":
                update = Attribute.customString(key).withValueIfUndefined((String) values[0]);
                break;
            case "withValueReset":
                update = Attribute.customString(key).withValueReset();
                break;
            default:
                throw new Error("Unknown method" + methodName);
        }
        return update;
    }

    private YandexMetricaConfig toYandexMetricaConfig(PluginCall configMap) throws JSONException {
        YandexMetricaConfig.Builder builder = YandexMetricaConfig.newConfigBuilder(configMap.getString("apiKey"));

        if (configMap.hasOption("appVersion")) {
            builder.withAppVersion(configMap.getString("appVersion"));
        }
        if (configMap.hasOption("crashReporting")) {
            builder.withCrashReporting(configMap.getBoolean("crashReporting"));
        }
        // activationAsSessionStart ??
        if (configMap.hasOption("firstActivationAsUpdate")) {
            builder.handleFirstActivationAsUpdate(configMap.getBoolean("firstActivationAsUpdate"));
        }
        if (configMap.hasOption("location")) {
            builder.withLocation(toLocation(configMap.getObject("location")));
        }
        if (configMap.hasOption("locationTracking")) {
            builder.withLocationTracking(configMap.getBoolean("locationTracking"));
        }
        if (configMap.hasOption("userProfileID")) {
            builder.withUserProfileID(configMap.getString("userProfileID"));
        }
        if (configMap.hasOption("appOpenTrackingEnabled")) {
            builder.withAppOpenTrackingEnabled(configMap.getBoolean("appOpenTrackingEnabled"));
        }
        if (configMap.hasOption("revenueAutoTrackingEnabled")) {
            builder.withRevenueAutoTrackingEnabled(configMap.getBoolean("revenueAutoTrackingEnabled"));
        }
        if (configMap.hasOption("logs") && configMap.getBoolean("logs")) {
            builder.withLogs();
        }
        if (configMap.hasOption("preloadInfo")) {
            builder.withPreloadInfo(toPreloadInfo(configMap.getObject("preloadInfo")));
        }
        if (configMap.hasOption("sessionsAutoTracking")) {
            builder.withSessionsAutoTrackingEnabled(configMap.getBoolean("sessionsAutoTracking"));
        }
        if (configMap.hasOption("sessionTimeout")) {
            builder.withSessionTimeout(configMap.getInt("sessionTimeout"));
        }
        if (configMap.hasOption("statisticsSending")) {
            builder.withStatisticsSending(configMap.getBoolean("statisticsSending"));
        }

        if (configMap.hasOption("maxReportsInDatabaseCount")) {
            builder.withMaxReportsInDatabaseCount(configMap.getInt("maxReportsInDatabaseCount"));
        }
        if (configMap.hasOption("nativeCrashReporting")) {
            builder.withNativeCrashReporting(configMap.getBoolean("nativeCrashReporting"));
        }

        return builder.build();
    }

    private Location toLocation(JSObject locationMap) throws JSONException {
        if (locationMap == null) {
            return null;
        }

        Location location = new Location("Custom");

        if (locationMap.has("latitude")) {
            location.setLatitude(locationMap.getDouble("latitude"));
        }
        if (locationMap.has("longitude")) {
            location.setLongitude(locationMap.getDouble("longitude"));
        }
        if (locationMap.has("altitude")) {
            location.setAltitude(locationMap.getDouble("altitude"));
        }
        if (locationMap.has("accuracy")) {
            location.setAccuracy((float) locationMap.getDouble("accuracy"));
        }
        if (locationMap.has("course")) {
            location.setBearing((float) locationMap.getDouble("course"));
        }
        if (locationMap.has("speed")) {
            location.setSpeed((float) locationMap.getDouble("speed"));
        }
        if (locationMap.has("timestamp")) {
            location.setTime((long) locationMap.getDouble("timestamp"));
        }

        return location;
    }

    private PreloadInfo toPreloadInfo(JSObject preloadInfoMap) {
        if (preloadInfoMap == null) {
            return null;
        }

        PreloadInfo.Builder builder = PreloadInfo.newBuilder(preloadInfoMap.getString("trackingId"));
        if (preloadInfoMap.has("additionalInfo")) {
            JSObject additionalInfo = preloadInfoMap.getJSObject("additionalInfo");
            if (additionalInfo != null) {
                for (Iterator<String> keyIterator = additionalInfo.keys(); keyIterator.hasNext();) {
                    final String key = keyIterator.next();
                    final String value = additionalInfo.getString(key);
                    builder.setAdditionalParams(key, value);
                }
            }
        }

        return builder.build();
    }
}
