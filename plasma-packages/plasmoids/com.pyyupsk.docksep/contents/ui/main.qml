import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.largeSpacing
        Layout.maximumWidth: Layout.minimumWidth
        Layout.fillHeight: true

        Rectangle {
            anchors.centerIn: parent
            width: 1
            height: parent.height * 0.6
            color: Kirigami.Theme.textColor
            opacity: 0.25
        }
    }
}
