import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: sleepTimerPage
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        VerticalScrollDecorator {}
            PageHeader { title: ((sleepTime > 0) ? ("Remaning time: "  + (sleepTime) + " minutes") : "choose time: " + minutes.value )}

            ValuePicker {
                id: minutes
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                max: 121
                min: 1
                value: sleepTime
            }
            Label {
                text: minutes.value
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.secondaryHighlightColor
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeHuge
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 40
                spacing: Theme.paddingLarge

                Button {
                        text: ((sleepTime > 0) ? ("Change") : ("Start"))
                        onPressed: sleepTime = minutes.value
                    }
                Button {
                        text: "Stop"
                        onPressed: sleepTime = 0;
                    }
            }
    }
}
