package com.astrolearn.astro_learn

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

class PlanetOfDayWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val prefs: SharedPreferences =
                context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val planet = prefs.getString("pod_planet", "—") ?: "—"
            val theme = prefs.getString("pod_theme", "Cosmic Energy") ?: "Cosmic Energy"
            val emoji = prefs.getString("pod_emoji", "🪐") ?: "🪐"

            val views = RemoteViews(context.packageName, R.layout.planet_day_widget)
            views.setTextViewText(R.id.pod_emoji, emoji)
            views.setTextViewText(R.id.pod_planet, planet)
            views.setTextViewText(R.id.pod_theme, theme)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
