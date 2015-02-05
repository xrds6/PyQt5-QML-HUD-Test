/*
* SidePanel.qml
*
* Copyright (C) 2009-2011 basysKom GmbH
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

import QtQuick 2.2

Item {
    id:root


    property int currentPageIndex: 0
    property alias pages: container.children

    property int mode: 0 // left: 0; right: 0;
    property alias label: handle.label
    property alias tabColumn: tabs.children

    signal hiding() // Panel is about to hide
    signal appearing()  // Panel has finished showing up

    width: 300
    height: parent.height
    opacity: 0.5
    x: (mode == 0) ? -width -1 : parent.width
    visible: false

    state: 'hidden'

    states: [
        State {
            name:'shown'
        },
        State {
            name:'hidden'
        }
    ]

    onStateChanged: { p.animationDuration = 250}

    function showPanel() {
        slideIn.running = true
        root.state = 'shown';
        root.appearing()
    }

    function hidePanel() {
        slideOut.running = true
        root.state = 'hidden';
        root.hiding()
    }

    function togglePanel() {
        if(state == 'hidden') {
            showPanel();
        } else {
            hidePanel();
        }
    }

    function showPage(pageIndex) {
        root.currentPageIndex = pageIndex;

        for(var i = 0; i < container.children.length; i++) {
            container.children[i].state = (i == root.currentPageIndex ? 'shown' : 'hidden');
//            tabs.children[i].state = (i == root.currentPageIndex ? 'active' : 'normal');
        }
    }

    Component.onCompleted: {

//        for(var i = 0; i < container.children.length; i++) {
//            var tab = tabTemplate.createObject(tabs);

//            tab.pageIndex = i;
//            tab.label = container.children[i].pageTitle;
//            tab.mode = root.mode

//            if(i == 0) tab.state = 'active';
//        }

        showPage(0);
        visible = true
    }

    PropertyAnimation{
        id: slideIn
        target: root
        property: "x"
        from: (mode == 0) ? -root.width -1: root.parent.width
        to: (mode == 0) ? 0 : root.parent.width - root.width
        duration: p.animationDuration
        easing.type: Easing.OutQuad
    }

    PropertyAnimation{
        id: slideOut
        target: root
        property: "x"
        from: (mode == 0) ? 0 : parent.width - root.width
        to: (mode == 0) ? -root.width -1 : parent.width
        duration: p.animationDuration
        easing.type: Easing.OutQuad
    }

    QtObject {
        id: p
        property int animationDuration: 0

    }

    Component {
        id: tabTemplate
        SidePanelTab {
            onClicked: {
                if(root.state == 'hidden') {
                    root.state = 'shown';
                }

                root.showPage(index);
            }

            colorEmboss: style.panelBackground
            colorActive: style.panelBackground
        }
    }

    TabletCommonStyle {id:style}

    MouseArea { anchors.fill: parent; z: -1 }

    Image {
//        opacity: 0.2
        id: headerBckg
        source: "images/sidebar_top.png"
        width: parent.width
        y: 0
    }

    Rectangle {
        id: background
        opacity: 0.2
        width: parent.width - 0.5 // this forces the painter to round down.
        // note: images seem to round down by default
        height: parent.height - headerBckg.height
        y: headerBckg.height
        color: style.panelBackground
    }

//    Image {
//        id: background

//        width: parent.width
//        height: parent.height - headerBckg.height
//        y: headerBckg.height
//        source: "images/sidebar_tile_bg.png"
//        fillMode: Image.Tile
//    }

    Rectangle {
        id: handleBckg
        color: style.basysBlue
        anchors.fill: handle
        z: -1
        anchors.margins: -2
    }

    SidePanelTab {
        id: handle

        panelHidden: root.state == "hidden"
        onClicked: {
            root.togglePanel()
            forceActiveFocus()
        }
        onSwiped: {
            root.togglePanel()
            forceActiveFocus()
        }

        state: 'active'
        width: 50
        mode: root.mode
        colorActive: style.panelBackground
        colorEmboss: style.panelBackground

        x: (root.mode == 0) ? parent.width : -width
        y: style.sideBarHeaderHeight + 50
        z: 1
    }

    Coverview{

    }

    Column {
        id:tabs
        height:parent.height - 150
        anchors {
            left: (root.mode == 0) ? background.right : undefined
            right: (root.mode == 0) ? undefined : background.left
            top: handle.bottom
            topMargin: 30
        }
        spacing:5
        visible: root.x == 0 | root.x == root.parent.width - root.width -1
    }

    Item {
        id:container
        anchors.fill:parent
        clip: true
    }
}
