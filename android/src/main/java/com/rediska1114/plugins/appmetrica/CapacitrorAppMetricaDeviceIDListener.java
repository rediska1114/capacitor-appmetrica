package com.rediska1114.plugins.appmetrica;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.getcapacitor.PluginCall;
import com.yandex.metrica.AppMetricaDeviceIDListener;
import com.getcapacitor.JSObject;

public class CapacitrorAppMetricaDeviceIDListener  implements AppMetricaDeviceIDListener {
    private final PluginCall call;

   CapacitrorAppMetricaDeviceIDListener(PluginCall call) {
       this.call = call;
   }
    @Override
    public void onLoaded(@Nullable String s) {
        JSObject res = new JSObject();
        res.put("deviceID", s);
        call.success(res);
    }

    @Override
    public void onError(@NonNull com.yandex.metrica.AppMetricaDeviceIDListener.Reason reason) {
        call.reject(reason.toString());
    }
}
