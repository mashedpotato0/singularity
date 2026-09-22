pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    property bool dndEnabled: SettingsService.dnd
    property var notificationList: []
    property var toastList: []
    readonly property int unreadCount: notificationList.length

    Connections {
        target: SettingsService
        function onDndChanged() {
            root.dndEnabled = SettingsService.dnd;
        }
    }

    signal newToast(var notif)

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: notification => {
            try {
                notification.tracked = true;
            } catch (e) {}

            let notifId = notification.id;
            let item = {
                id: notifId,
                notification: notification,
                appName: notification.appName || "System",
                appIcon: notification.appIcon || "",
                summary: notification.summary || "Notification",
                body: notification.body || "",
                urgency: notification.urgency || 1,
                timeStr: Qt.formatTime(new Date(), "hh:mm AP"),
                timestamp: Date.now()
            };

            let current = root.notificationList.slice();
            current.unshift(item);
            root.notificationList = current;

            if (!root.dndEnabled) {
                let toasts = root.toastList.slice();
                toasts.unshift(item);
                root.toastList = toasts;
                root.newToast(item);
            }
        }
    }

    function dismissNotification(item) {
        if (!item) return;
        try {
            if (item.notification && typeof item.notification.dismiss === "function") {
                item.notification.dismiss();
            }
        } catch (e) {
            // QObject might be destroyed
        }
        removeNotificationById(item.id);
        removeToastById(item.id);
    }

    function removeNotificationById(id) {
        root.notificationList = root.notificationList.filter(n => n && n.id !== id);
    }

    function removeToastById(id) {
        root.toastList = root.toastList.filter(t => t && t.id !== id);
    }

    function clearAll() {
        let list = root.notificationList ? root.notificationList.slice() : [];
        for (let i = 0; i < list.length; i++) {
            let item = list[i];
            if (item) {
                try {
                    if (item.notification && typeof item.notification.dismiss === "function") {
                        item.notification.dismiss();
                    }
                } catch (e) {
                    // QObject might be destroyed
                }
            }
        }
        root.notificationList = [];
        root.toastList = [];
    }

    function toggleDnd() {
        let newState = !root.dndEnabled;
        root.dndEnabled = newState;
        SettingsService.set("dnd", newState);
    }
}
