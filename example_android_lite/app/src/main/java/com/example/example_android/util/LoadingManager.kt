import androidx.fragment.app.FragmentActivity

class LoadingManager(private val activity: FragmentActivity) {

    private var loadingDialog: LoadingDialogFragment? = null

    fun show() {
        if (loadingDialog == null) {
            loadingDialog = LoadingDialogFragment.newInstance()
        }
        loadingDialog?.let {
            if (!it.isAdded) {
                it.show(activity.supportFragmentManager, LoadingDialogFragment.TAG)
            }
        }
    }

    fun dismiss() {
        loadingDialog?.dismissAllowingStateLoss()
        loadingDialog = null
    }

    fun simulateLoading(onComplete: () -> Unit) {
        show()
        android.os.Handler().postDelayed({
            dismiss()
            onComplete()
        }, 3000) // 3秒后关闭
    }
}