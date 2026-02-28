package com.astrolearn.astro_learn

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

class AuspiciousTimeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val prefs: SharedPreferences =
                context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val time = prefs.getString("ausp_time", "—") ?: "—"
            val yoga = prefs.getString("ausp_yoga", "—") ?: "—"
            val karana = prefs.getString("ausp_karana", "—") ?: "—"

            val views = RemoteViews(context.packageName, R.layout.auspicious_time_widget)
            views.setTextViewText(R.id.ausp_time, time)
            views.setTextViewText(R.id.ausp_yoga, yoga)
            views.setTextViewText(R.id.ausp_karana, karana)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
