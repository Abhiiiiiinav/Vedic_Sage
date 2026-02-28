package com.astrolearn.astro_learn

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

class TaskWidgetProvider : AppWidgetProvider() {

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

            val completed = prefs.getInt("tasks_completed", 0)
            val total = prefs.getInt("tasks_total", 0)
            val task1 = prefs.getString("task_1", "—") ?: "—"
            val task2 = prefs.getString("task_2", "") ?: ""

            val progressPercent = if (total > 0) (completed * 100) / total else 0

            val views = RemoteViews(context.packageName, R.layout.task_widget)
            views.setTextViewText(R.id.task_progress, "$completed/$total")
            views.setProgressBar(R.id.task_progress_bar, 100, progressPercent, false)
            views.setTextViewText(R.id.task_1, "○  $task1")
            views.setTextViewText(R.id.task_2, if (task2.isNotEmpty()) "○  $task2" else "")

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
