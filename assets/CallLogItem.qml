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

Container {
    property alias name: nameLabel.text
    property alias iconSource: listImage.imageSource
    property alias iconColor: listImage.filterColor
    property alias attribution: attrLabel.text
    property alias startTime: timeLabel.text
    Container {
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        
        Container {
            preferredHeight: ui.du(10)
            layout: DockLayout {
            }
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 7
            }
            
            Label {
                id: nameLabel
                textStyle.fontSize: FontSize.Medium
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Top
            }
            
            Container {
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Bottom
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                ImageView {
                    id: listImage
                    maxHeight: ui.du(4)
                    maxWidth: ui.du(4)
                }
                Label {
                    id: attrLabel
                    textStyle.fontSize: FontSize.Small
                }
            }
            Label {
                id: timeLabel
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Top
                textStyle.fontSize: FontSize.Small
            }
        }
        /*
         ImageButton {
         maxHeight: ui.du(9)
         maxWidth: ui.du(9)
         horizontalAlignment: HorizontalAlignment.Center
         verticalAlignment: VerticalAlignment.Center
         defaultImageSource: "asset:///images/text.png"
         layoutProperties: StackLayoutProperties {
         spaceQuota: 1
         }
         onClicked: {
         }
         }*/
    }
    Divider {
    }
}