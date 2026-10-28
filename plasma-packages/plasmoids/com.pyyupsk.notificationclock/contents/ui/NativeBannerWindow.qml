import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "../code/Style.js" as Style

// A banner window with Plasma's notification role, so KWin stacks it like
// KDE's own popups and never gives it focus. The glass is the Plasma theme's
// dialog frame (Orla theme: blurred, rounded).
PlasmaCore.Dialog {
    id: window
    property var notification: null
    // QImage from the notification, or an icon name; Kirigami draws either.
    property var bannerImage: null
    property var bannerIcon: ""
    property var scheme: Style.scheme("dark")
    property int bannerTimeout: 0
    property double nowMs: Date.now()
    readonly property alias engaged: banner.engaged
    signal activated()
    signal closeRequested()
    signal actionRequested(string name)
    signal jobControlRequested(string control)
    signal replyRequested(string text)
    signal expired()

    type: notification && notification.critical ? PlasmaCore.Dialog.CriticalNotification : PlasmaCore.Dialog.Notification
    // Only a reply in progress takes the keyboard; Dialog re-applies focus on a flags change.
    flags: banner.replying ? 0 : Qt.WindowDoesNotAcceptFocus
    location: PlasmaCore.Types.Floating
    backgroundHints: PlasmaCore.Dialog.StandardBackground
    hideOnWindowDeactivate: false
    visible: false

    mainItem: NotificationBanner {
        id: banner
        width: implicitWidth
        notification: window.notification
        scheme: window.scheme
        nowMs: window.nowMs
        timeout: window.bannerTimeout
        reducedMotion: Kirigami.Units.longDuration <= 0
        iconComponent: Kirigami.Icon {
            source: window.bannerImage || window.bannerIcon || (window.notification && window.notification.appIcon)
                || "preferences-desktop-notification"
        }
        onActivated: window.activated()
        onCloseRequested: window.closeRequested()
        onActionRequested: name => window.actionRequested(name)
        onJobControlRequested: control => window.jobControlRequested(control)
        onReplyRequested: text => window.replyRequested(text)
        onReplyingChanged: if (replying) window.requestActivate()
        onExpired: window.expired()
    }
}
