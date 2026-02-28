package com.astrolearn.astro_learn

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

class LevelProgressWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val prefs: SharedPreferences =
                context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val level = prefs.getInt("lp_level", 1)
            val xpCurrent = prefs.getInt("lp_xp_current", 0)
            val xpNeeded = prefs.getInt("lp_xp_needed", 200)
            val progress = prefs.getInt("lp_progress", 0)
            val chapters = prefs.getInt("lp_chapters", 0)

            val views = RemoteViews(context.packageName, R.layout.level_progress_widget)
            views.setTextViewText(R.id.lp_level_badge, "Lv. $level")
            views.setProgressBar(R.id.lp_progress_bar, 100, progress, false)
            views.setTextViewText(R.id.lp_xp_text, "$xpCurrent / $xpNeeded XP")
            views.setTextViewText(R.id.lp_chapters, "$chapters chapters completed")

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
