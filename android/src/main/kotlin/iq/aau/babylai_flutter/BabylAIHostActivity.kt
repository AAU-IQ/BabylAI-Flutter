package iq.aau.babylai_flutter

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import iq.aau.babylai.android.babylaisdk.BabylAI
import iq.aau.babylai.android.babylaisdk.BabylAITheme

class BabylAIHostActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val screenId = intent.getStringExtra(EXTRA_SCREEN_ID) ?: ""
        val isDirect = intent.getBooleanExtra(EXTRA_IS_DIRECT, false)
        val theme = if (intent.getStringExtra(EXTRA_THEME) == "dark") BabylAITheme.DARK else BabylAITheme.LIGHT

        setContent {
            if (isDirect) {
                BabylAI.shared.presentActiveChat(
                    theme = theme,
                    screenId = screenId,
                    onDismiss = { finish() }
                )
            } else {
                BabylAI.shared.viewer(
                    theme = theme,
                    isDirect = false,
                    screenId = screenId,
                    onDismiss = { finish() }
                )
            }
        }
    }

    companion object {
        const val EXTRA_SCREEN_ID = "screen_id"
        const val EXTRA_IS_DIRECT = "is_direct"
        const val EXTRA_THEME = "theme"
    }
}


