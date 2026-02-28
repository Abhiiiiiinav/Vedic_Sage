package com.astrolearn.astro_learn

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

class StreakWidgetProvider : AppWidgetProvider() {

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

            val streak = prefs.getInt("streak", 0)
            val totalXP = prefs.getInt("total_xp", 0)
            val level = prefs.getInt("level", 1)

            val views = RemoteViews(context.packageName, R.layout.streak_widget)
            views.setTextViewText(R.id.streak_count, streak.toString())
            views.setTextViewText(R.id.streak_xp, "$totalXP XP")
            views.setTextViewText(R.id.streak_level, "Lv. $level")

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
