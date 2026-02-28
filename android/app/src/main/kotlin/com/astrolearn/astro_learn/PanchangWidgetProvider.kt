package com.astrolearn.astro_learn

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

class PanchangWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs: SharedPreferences =
                context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val tithi = prefs.getString("tithi", "—") ?: "—"
            val nakshatra = prefs.getString("nakshatra", "—") ?: "—"
            val yoga = prefs.getString("yoga", "—") ?: "—"
            val vara = prefs.getString("vara", "—") ?: "—"
            val varaLord = prefs.getString("vara_lord", "") ?: ""
            val date = prefs.getString("date", "—") ?: "—"

            val views = RemoteViews(context.packageName, R.layout.panchang_widget)
            views.setTextViewText(R.id.panchang_date, date)
            views.setTextViewText(R.id.panchang_tithi, tithi)
            views.setTextViewText(R.id.panchang_nakshatra, nakshatra)
            views.setTextViewText(R.id.panchang_yoga, yoga)
            views.setTextViewText(
                R.id.panchang_vara,
                if (varaLord.isNotEmpty()) "$vara ($varaLord)" else vara
            )

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
