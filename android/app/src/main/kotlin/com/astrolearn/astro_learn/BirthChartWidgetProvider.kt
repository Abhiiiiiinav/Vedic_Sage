package com.astrolearn.astro_learn

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

class BirthChartWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val prefs: SharedPreferences =
                context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val name = prefs.getString("bc_name", "No chart loaded") ?: "No chart loaded"
            val lagna = prefs.getString("bc_lagna", "—") ?: "—"
            val charts = prefs.getString("bc_charts", "") ?: ""

            val views = RemoteViews(context.packageName, R.layout.birth_chart_widget)
            views.setTextViewText(R.id.bc_name, name)
            views.setTextViewText(R.id.bc_lagna, lagna)
            views.setTextViewText(R.id.bc_charts, charts)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
