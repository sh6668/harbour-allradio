/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

/* Modified to be a sailfish/jolla style value-slider by nesnomis. */
/* Contact: Niels Simonsen <nesnomis@gmail.com>              */

import QtQuick 2.0
import Sailfish.Silica 1.0

// TODO: Investigate using one quarter of the image mirrored in two directions
// TODO: Investigate using a scaled down version of the image

Item {
    id: valuePicker

    property int value
    property int max
    property int min

    property real _scaleRatio: valueCircle.width / 408

    width: valueCircle.width
    height: valueCircle.height

    onValueChanged: {
        value = (value < 1 ? 1 : (value > max ? max : value))

        if (mouse.changingProperty == 0) {
            var delta = (value - valueIndicator.value)
            valueIndicator.value += (delta % (max - 1))
        }
    }

    function _xTranslation(value, bound) {
        // Use sine to map range of 0-bound to the X translation of a circular locus (-1 to 1)
        return Math.sin((value % bound) / bound * Math.PI * 2)
    }

    function _yTranslation(value, bound) {
        // Use cosine to map range of 0-bound to the Y translation of a circular locus (-1 to 1)
        return Math.cos((value % bound) / bound * Math.PI * 2)
    }

    Image {
        id: valueCircle

        source: "../timepicker.png"
        opacity: 0.1
    }

    GlassItem {
        id: valueIndicator
        falloffRadius: 0.22
        radius: 0.25
        anchors.centerIn: valueCircle
        color: mouse.changingProperty == 2 ? Theme.highlightColor : Theme.primaryColor

        property real value

        transform: Translate {
            // The ss band is 72px wide, ending at 204px from the center
            x: _scaleRatio*168 * _xTranslation(valueIndicator.value, max)
            y: -_scaleRatio*168 * _yTranslation(valueIndicator.value, max)
        }

        Behavior on value {
            id: valueAnimation
            SmoothedAnimation { velocity: 80 }
            enabled: !mouse.isMoving || mouse.isLagging
        }
    }

    MouseArea {
        id: mouse

        property int changingProperty
        property bool isMoving
        property bool isLagging

        anchors.fill: parent
        preventStealing: true

        function radiusForCoord(x, y) {
            // Return the distance from the mouse position to the center
            return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2))
        }

        function angleForCoord(x, y) {
            // Return the angular position in degrees, rising anticlockwise from the positive X-axis
            var result = Math.atan(y / x) / (Math.PI * 2) * 360

            // Adjust for various quadrants
            if (x < 0)  {
                result += 180
            } else if (y < 0) {
                result += 360
            }
            return result
        }

        function remapAngle(value, bound) {
            // Return the angle in degrees mapped to the adjusted range 0 - (bound-1) and
            // translated to the clockwise from positive Y-axis orientation
            return Math.round(bound - (((value - 90) / 360) * bound)) % bound
        }

        function remapMouse(mouseX, mouseY) {
            // Return the mouse coordinates in cartesian coords relative to the circle center
            return { x: mouseX - (width / 2), y: 0 - (mouseY - (height / 2)) }
        }

        function propertyForRadius(radius) {
            // Return the property associated with clicking at radius distance from the center
            if (radius < 204) {
                return 2 // Minutes
            }
            return 0
        }

        function updateForAngle(angle) {
            // Update the selected property for the specified angular position
                 // Minutes
                // Map angular position to 0-59
                var m = remapAngle(angle, max)

                // Round single touch to the nearest 5 min mark
                if (!isMoving) m = (Math.round(m/5) * 5) % (max - 1)

                var delta = (m - valueIndicator.value) % (max - 1)

                // It is not possible to make jumps of more than 30 minutes - reverse the direction
                if (delta > 60) {
                    delta -= max
                } else if (delta < -60) {
                    delta += max
                }
                if (isMoving && isLagging) {
                    if (Math.abs(delta) < 2) {
                        isLagging = false
                    }
                }

                valueIndicator.value += delta

                valuePicker.value = m
        }

        onPressed: {
            var coords = remapMouse(mouseX, mouseY)
            var radius = radiusForCoord(coords.x, coords.y)

            changingProperty = propertyForRadius(radius)
            if (changingProperty != 0) {
                preventStealing = true
                var angle = angleForCoord(coords.x, coords.y)

                isLagging = true
                updateForAngle(angle)
            } else {
                // Outside the minutes band - allow pass through to underlying component
                preventStealing = false
            }
        }
        onPositionChanged: {
            if (changingProperty > 0) {
                var coords = remapMouse(mouseX, mouseY)
                var angle = angleForCoord(coords.x, coords.y)

                isMoving = true
                updateForAngle(angle)
            }
        }
        onReleased: {
            changingProperty = 0
            isMoving = false
            isLagging = false
        }
    }
}
