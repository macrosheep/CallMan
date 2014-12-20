/*
 * Copyright (c) 2013-2014 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.3
        
TabbedPane {
    property alias attrOnCall: attrOnCallBtn.checked
    property alias attrOnConnected: attrOnConnectedBtn.checked
    property alias attrOnDisconnected: attrOnDisconnectedBtn.checked
    property alias attrHub: attrHubBtn.checked
    property alias vibrationOnConnected: vibrationOnConnectedSlider.value
    property alias vibrationOnDisconnected: vibrationOnDisconnectedSlider.value
    
    id: mainPane
    showTabsOnActionBar: true
    
    Menu.definition: MenuDefinition {
        helpAction: HelpActionItem {
            
        }
        actions:  [
            ActionItem {
                title: qsTr("About") + Retranslate.onLocaleOrLanguageChanged
                onTriggered: {
                    aboutSheet.open()
                }
            }
        ]
    }

    Tab {
        id: callLogTab
        title: qsTr("Call Log") + Retranslate.onLocaleOrLanguageChanged
        imageSource: "asset:///images/calllog.png"
        Page {
            id: callLogPage
            
            titleBar: TitleBar {
                id: segmentedTitle
                kind: TitleBarKind.Segmented
                scrollBehavior: TitleBarScrollBehavior.Sticky
                
                options: [
                    Option {
                        text: qsTr("All") + Retranslate.onLocaleOrLanguageChanged
                        imageSource: "asset:///images/call.png"
                        value: "all"
                    },
                    Option {
                        text: qsTr("Missed") + Retranslate.onLocaleOrLanguageChanged
                        imageSource: "asset:///images/missed.png"
                        value: "missed"
                    }
                    /*
                     Option {
                     text: qsTr("In") + Retranslate.onLocaleOrLanguageChanged
                     imageSource: "asset:///images/incoming.png"
                     value: "in"
                     },
                     Option {
                     text: qsTr("Out") + Retranslate.onLocaleOrLanguageChanged
                     imageSource: "asset:///images/outgoing.png"
                     value: "out"
                     }*/
]

onSelectedValueChanged: {
app.filterModel(selectedValue.toString())
}
            }
            
            Container {
                ListView {
                    objectName: "callLogList"
                    
                    listItemComponents: [
                        ListItemComponent {
                            type: "header"
                            
                            Header {
                                title: ListItemData
                            }
                        },
                        
                        ListItemComponent {
                            type: "item"
                            
                            CallLogItem {
                                name: ListItemData.name
                                iconSource: imageSource()
                                iconColor: filterColor()
                                attribution: ListItemData.city + " | " + ListItemData.carrier
                                startTime: ListItemData.time
                                
                                function imageSource() {
                                    if (ListItemData.callType == 3) {
                                        return "asset:///images/outgoing.png"
                                    } else if (ListItemData.callType == 1) {
                                        return "asset:///images/incoming.png"
                                    } else if (ListItemData.callType == 2) {
                                        return "asset:///images/missed.png"
                                    } else {
                                    }
                                }
                                function filterColor() {
                                    if (ListItemData.callType == 3) {
                                        return Color.DarkGreen
                                    } else if (ListItemData.callType == 1) {
                                        return Color.DarkCyan
                                    } else if (ListItemData.callType == 2) {
                                        return Color.Red
                                    } else {
                                    }
                                }
                            }
                            /*
                             ExpandableView {
                             id: callLogExpandView
                             maxCollapsedHeight: ui.du(10)
                             expandMode: ExpandMode.Default
                             collapseMode: CollapseMode.None
                             
                             Container {
                             layout: StackLayout {
                             
                             }                     
                             Container {
                             id: listItemBtns
                             preferredWidth: ui.du(150)
                             
                             layout: GridLayout {
                             columnCount: 2
                             }
                             ImageButton {
                             horizontalAlignment: HorizontalAlignment.Center
                             defaultImageSource: "asset:///images/text.png"
                             }
                             ImageButton {
                             horizontalAlignment: HorizontalAlignment.Center
                             defaultImageSource: "asset:///images/call.png"
                             }
                             }
                             }
                             }*/
                        }
                        ]
                        onTriggered: {
                        app.onListItemTriggered(indexPath)
                        }
                }
            }
        } //page1
    } //Tab1
    Tab {
        id: searchTab
        title: qsTr("Search") + Retranslate.onLocaleOrLanguageChanged
        imageSource: "asset:///images/search.png"
        
        Page {
            titleBar: TitleBar {
                title: qsTr("Query") + Retranslate.onLocaleOrLanguageChanged       
                scrollBehavior: TitleBarScrollBehavior.Sticky      
            }
            Container {
                layout: StackLayout {
                }
                topPadding: ui.du(2)
                leftPadding: ui.du(2)
                rightPadding: ui.du(2)
                bottomPadding: ui.du(2)
                
                Label {
                    horizontalAlignment:HorizontalAlignment.Left
                    textStyle.fontSize: FontSize.Large
                    textStyle.color: Color.Gray
                    textStyle.fontWeight: FontWeight.Bold
                    // Localized text with the dynamic translation and locale updates support
                    text: qsTr("Query phone number attribution") + Retranslate.onLocaleOrLanguageChanged              
                }
                TextField {
                    id: pnum
                    topMargin: ui.du(2)
                    preferredHeight: ui.du(2)
                    preferredWidth: ui.du(150)
                    inputMode: TextFieldInputMode.PhoneNumber
                    hintText: qsTr("Please enter mobile number or area code") + Retranslate.onLocaleOrLanguageChanged
                    clearButtonVisible: true
                    maximumLength: 20
                    textStyle.fontSize: FontSize.Medium
                    input {
                        submitKey: SubmitKey.Search
                        onSubmitted: {
                            app.search(pnum.text);
                        }
                    }
                }
                Label {
                    horizontalAlignment:HorizontalAlignment.Left
                    textStyle.fontSize: FontSize.Small
                    textStyle.fontStyle: FontStyle.Italic
                    textStyle.fontWeight: FontWeight.Bold
                    multiline: true
                    // Localized text with the dynamic translation and locale updates support
                    text: qsTr("NOTE:\n1.You can just input the first 7 characters of the mobile phone number\n2.This function is only for Chinese Mainland users") + Retranslate.onLocaleOrLanguageChanged              
                }
            }
        } //tab2page
    } //tab2
    Tab {
        id: settingsTab
        title: qsTr("Settings") + Retranslate.onLocaleOrLanguageChanged
        imageSource: "asset:///images/settings.png"
        
        Page {
            
            titleBar: TitleBar {
                title: qsTr("Settings") + Retranslate.onLocaleOrLanguageChanged       
                scrollBehavior: TitleBarScrollBehavior.Sticky
            }
            
            ScrollView {
                Container {
                    layout: StackLayout {
                    }
                    topPadding: ui.du(2)
                    leftPadding: ui.du(2)
                    rightPadding: ui.du(2)
                    bottomPadding: ui.du(2)
                    
                    Label {
                        horizontalAlignment:HorizontalAlignment.Left
                        verticalAlignment: VerticalAlignment.Top
                        textStyle.fontSize: FontSize.Large
                        textStyle.color: Color.Gray
                        textStyle.fontWeight: FontWeight.Bold
                        // Localized text with the dynamic translation and locale updates support
                        text: qsTr("Show phone number attribution") + Retranslate.onLocaleOrLanguageChanged              
                    }
                    Container {
                        topMargin: ui.du(2)
                        preferredHeight: ui.du(2)
                        preferredWidth: ui.du(150)
                        layout: DockLayout {
                        }
                        Label {
                            horizontalAlignment:HorizontalAlignment.Left
                            verticalAlignment: VerticalAlignment.Top
                            textStyle.fontSize: FontSize.Medium
                            // Localized text with the dynamic translation and locale updates support
                            text: qsTr("On incoming/outgoing") + Retranslate.onLocaleOrLanguageChanged              
                        }
                        // Create a ToggleButton
                        ToggleButton {
                            id: attrOnCallBtn
                            horizontalAlignment: HorizontalAlignment.Right
                            verticalAlignment: VerticalAlignment.Top
                            checked: false
                            onCheckedChanged: {
                                if (checked) {
                                    app.enableAttribution("onCall");
                                } else {
                                    app.disableAttribution("onCall");
                                }
                            }
                        }
                    }
                    Container {
                        topMargin: ui.du(2)
                        preferredHeight: ui.du(2)
                        preferredWidth: ui.du(150)
                        layout: DockLayout {
                        }
                        Label {
                            horizontalAlignment:HorizontalAlignment.Left
                            verticalAlignment: VerticalAlignment.Top
                            textStyle.fontSize: FontSize.Medium
                            // Localized text with the dynamic translation and locale updates support
                            text: qsTr("On connected") + Retranslate.onLocaleOrLanguageChanged              
                        }
                        // Create a ToggleButton
                        ToggleButton {
                            id: attrOnConnectedBtn
                            horizontalAlignment: HorizontalAlignment.Right
                            //verticalAlignment: VerticalAlignment.Top
                            checked: false
                            onCheckedChanged: {
                                if (checked) {
                                    app.enableAttribution("onConnected");
                                } else {
                                    app.disableAttribution("onConnected");
                                }
                            }
                        }
                    }
                    Container {
                        topMargin: ui.du(2)
                        preferredHeight: ui.du(2)
                        preferredWidth: ui.du(150)
                        layout: DockLayout {
                        }
                        Label {
                            horizontalAlignment:HorizontalAlignment.Left
                            verticalAlignment: VerticalAlignment.Top
                            textStyle.fontSize: FontSize.Medium
                            // Localized text with the dynamic translation and locale updates support
                            text: qsTr("On disconnected") + Retranslate.onLocaleOrLanguageChanged              
                        }
                        // Create a ToggleButton
                        ToggleButton {
                            id: attrOnDisconnectedBtn
                            horizontalAlignment: HorizontalAlignment.Right
                            verticalAlignment: VerticalAlignment.Top
                            checked: false
                            onCheckedChanged: {
                                if (checked) {
                                    app.enableAttribution("onDisconnected");
                                } else {
                                    app.disableAttribution("onDisconnected");
                                }
                            }
                        }
                    }
                    Container {
                        topMargin: ui.du(2)
                        preferredHeight: ui.du(2)
                        preferredWidth: ui.du(150)
                        layout: DockLayout {
                        }
                        Label {
                            horizontalAlignment:HorizontalAlignment.Left
                            verticalAlignment: VerticalAlignment.Top
                            textStyle.fontSize: FontSize.Medium
                            // Localized text with the dynamic translation and locale updates support
                            text: qsTr("Show in hub") + Retranslate.onLocaleOrLanguageChanged              
                        }
                        // Create a ToggleButton
                        ToggleButton {
                            id: attrHubBtn
                            horizontalAlignment: HorizontalAlignment.Right
                            verticalAlignment: VerticalAlignment.Top
                            checked: false
                            onCheckedChanged: {
                                if (checked) {
                                    app.enableAttribution("hub");
                                } else {
                                    app.disableAttribution("hub");
                                }
                            }
                        }
                    }
                    Divider {
                        topMargin: ui.du(2)
                    }
                    Label {
                        horizontalAlignment:HorizontalAlignment.Left
                        textStyle.fontSize: FontSize.Large
                        textStyle.color: Color.Gray
                        textStyle.fontWeight: FontWeight.Bold
                        // Localized text with the dynamic translation and locale updates support
                        text: qsTr("Vibration") + Retranslate.onLocaleOrLanguageChanged              
                    }
                    Container {
                        topMargin: ui.du(2)
                        preferredHeight: ui.du(2)
                        preferredWidth: ui.du(150)
                        layout: StackLayout {
                        }
                        Container {
                            preferredWidth: ui.du(150)
                            layout: DockLayout {
                            }
                            Label {
                                horizontalAlignment:HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Top
                                textStyle.fontSize: FontSize.Medium
                                // Localized text with the dynamic translation and locale updates support
                                text: qsTr("On connected") + Retranslate.onLocaleOrLanguageChanged
                            }
                            Label {
                                id: vSliderValue
                                horizontalAlignment:HorizontalAlignment.Right
                                verticalAlignment: VerticalAlignment.Top
                                textStyle.fontSize: FontSize.Medium
                                // Localized text with the dynamic translation and locale updates support
                                text: "0"
                            }
                        }
                        // Create a slider
                        Slider {
                            id: vibrationOnConnectedSlider
                            horizontalAlignment: HorizontalAlignment.Left
                            verticalAlignment: VerticalAlignment.Center
                            fromValue: 0
                            toValue: 1
                            onValueChanged: {
                                app.setVibration("onConnected", value.toFixed(1));
                                vSliderValue.text = value.toFixed(1)
                            }
                        }
                    }
                    Container {
                        topMargin: ui.du(2)
                        preferredHeight: ui.du(2)
                        preferredWidth: ui.du(150)
                        layout: StackLayout {
                        }
                        Container {
                            preferredWidth: ui.du(150)
                            layout: DockLayout {
                            }
                            Label {
                                horizontalAlignment:HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Top
                                textStyle.fontSize: FontSize.Medium
                                // Localized text with the dynamic translation and locale updates support
                                text: qsTr("On disconnected") + Retranslate.onLocaleOrLanguageChanged
                                }
                            Label {
                                id: vSliderValue2
                                horizontalAlignment:HorizontalAlignment.Right
                                verticalAlignment: VerticalAlignment.Top
                                textStyle.fontSize: FontSize.Medium
                                // Localized text with the dynamic translation and locale updates support
                                text: "0"
                            }
                        }
                        // Create a slider
                        Slider {
                            id: vibrationOnDisconnectedSlider
                            horizontalAlignment: HorizontalAlignment.Left
                            verticalAlignment: VerticalAlignment.Center
                            fromValue: 0
                            toValue: 1
                            onValueChanged: {
                                app.setVibration("onDisconnected", value.toFixed(1));
                                vSliderValue2.text = value.toFixed(1)
                            }
                        }
                    }
                    Divider {
                        topMargin: ui.du(2)
                    }
                    Label {
                        horizontalAlignment:HorizontalAlignment.Left
                        textStyle.fontSize: FontSize.Large
                        textStyle.color: Color.Gray
                        textStyle.fontWeight: FontWeight.Bold
                        // Localized text with the dynamic translation and locale updates support
                        text: qsTr("Call Log") + Retranslate.onLocaleOrLanguageChanged
                    }
                    Container {
                        topMargin: ui.du(2)
                        preferredHeight: ui.du(2)
                        preferredWidth: ui.du(150)
                        layout: DockLayout {
                        }
                        // Create a ToggleButton
                        Button {
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            text: qsTr("Clear") + Retranslate.onLocaleOrLanguageChanged
                            onClicked: {
                                app.clearCalllog();
                            }
                        }
                    }
                    Divider {
                        topMargin: ui.du(2)
                    }
                } //stack container
            } //scrollview
        } //tab3page
    } //tab3
    
    attachedObjects: [
        Sheet {
            id: aboutSheet
            Page {
                titleBar: TitleBar {
                    title: qsTr("About") + Retranslate.onLocaleOrLanguageChanged
                }
                Container {
                    topPadding: ui.du(10)
                    layout: StackLayout {
                        
                    }
                    ImageView {
                        imageSource: "asset:///images/icon.png"
                        horizontalAlignment: HorizontalAlignment.Center
                    }
                    Label {
                        text: qsTr("CallMan v1.0.0.6") + Retranslate.onLocaleOrLanguageChanged
                        horizontalAlignment: HorizontalAlignment.Center
                    }
                    Label {
                        text: "@懒羊羊Macro"
                        horizontalAlignment: HorizontalAlignment.Center
                    }
                }
                actions: [
                    ActionItem {
                        title: qsTr("Close") + Retranslate.onLocaleOrLanguageChanged
                        ActionBar.placement: ActionBarPlacement.OnBar
                        imageSource: "asset:///images/close.png"
                        onTriggered: {
                            aboutSheet.close();
                        }
                    }
                ]
            }
        }
    ]
} //tabbedPane
