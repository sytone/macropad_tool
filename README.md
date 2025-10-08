# Contents

-   [Project Description](#project-description)
    -   [Note](#note)
    -   [DONATIONS WELCOME](#donations-welcome)
-   [Installation](#installation)
-   [Configuration Mappings](#configuration-mappings)
    -   [Orientation](#orientation)
    -   [Macropad Setup](#macropad-setup)
    -   [Layers](#layers)
-   [Usage](#usage)
    -   [udev rules for linux](#udev-rules-for-linux)
    -   [Supported keys](#supported-keys)
    -   [Validate configuration](#validate-configuration)
    -   [Program the keyboard](#program-the-keyboard)
    -   [LED Support](#led-support)
-   [Windows](#windows)
    -   [Compiling](#compiling)
    -   [Running the Application](#running-the-application)

# Project Description

## Note

This started as a fun project to learn about rust and USB. It is a hobby
project and changes/features are implemented as my free time permits.
Please use caution before using this software as I assume no
responsibility if it does not work or causes problems with your device.

## DONATIONS WELCOME

[![](https://cdn.buymeacoffee.com/buttons/default-orange.png)](https://www.buymeacoffee.com/kamaaina)

Obviously I do not have all types of macropad nor do I intend to
purchase them. However, if people want to donate macropads so support
can be added for more devices, that is a big way to help grow this
project.

This is an utility for programming small keyboards like this one:

![*images/keyboard-6-1.png*](images/keyboard-6-1.png)
![*images/keyboard-12-2.png*](images/keyboard-12-2.png)
![*images/keyboard-3-1.jpg*](images/keyboard-3-1.jpg)
![*images/keyboard-4-0.png*](images/keyboard-4-0.png)
![*images/keyboard-6-1_2.png*](images/keyboard-6-1_2.png)
![*images/keyboard-15-3.jpg*](images/keyboard-15-3.jpg)

Many of these keyboards are popular on AliExpress and Amazon, but the
seller usually makes you download a windows exe file from a google drive
account to program it. It also assumes

-   you use Windows (which I do not)
-   is clunky/shady (imho)
-   most importantly does not expose all keyboard features

# Installation

Clone the repository and build the tool

``` example
cargo build --release
```

# Configuration Mappings

The README.md file is written in emacs org mode. To get a sample
configuration file, just tangle this file (C-c C-v t) from within emacs

## Orientation

Normal macropad orienation is when buttons are on the left side and
rotary encoders are on the right. However, you may want to use the
macropad in another orienation. To avoid remapping button positions in
your head, just set it here.

Possible values are: (horizontal)

-   Normal: buttons on the left, rotary encoders on the right
-   UpsideDown: buttons on the right, rotary encoders on the left

(vertical)

-   Clockwise: buttons on the top, rotary encoders on the bottom
-   CounterClockwise: buttons on the bottom, rotary encoders on the top

``` ron
(
    device: (
        // Normal, Clockwise, CounterClockwise, UpsideDown
        orientation: Normal,
```

## Macropad Setup

There are different models of macropad with different numbers of buttons
and rotary encoders. Set it here for proper handling. Count rows and
columns with the macropad in normal orienation, with rotary encoders on
the right side.

``` ron
    rows: 3,
    cols: 4,
    knobs: 2,
),
```

## Layers

The current layer is changed using a button on the side of the macropad
and displayed with LEDs on top (only for the moment of changing). All
macropads I saw had three layers

``` ron
layers: [
    (
```

### Buttons

Array of buttons. In horizontal orienations it\'s \`rows\` rows
\`columns\` buttons each. In vertical: \`columns\` rows \`rows\` buttons

Each entry is either a sequence of keychords or a mouse event. A
keychord is a combination of one key with optional modifiers, like
\'b\', \'ctrl-alt-a\' or \'win-rctrl-backspace\'. It can also be just
modifiers without a key: \'ctrl-alt\'

You can combine up to 17 chords into a sequence using commas:
\'ctrl-c,ctrl-v\'

If you have a 0x884x product id, you can use the delay feature. This
puts a delay between each key sequence. In the example below, when
typeing out \'foo@bar.com\' it will insert a 1000 msec delay between
each keystroke. the maximum delay is 6000 msec. For all other product
id\'s, the software will ignore the delay value when programming the
macropad

``` ron
buttons: [
    [(delay: 0, mapping: "ctrl-b"), (delay: 0, mapping: "ctrl-leftbracket"), (delay: 0, mapping: "ctrl-m") (delay: 0, mapping: "d")],
    [(delay: 0, mapping: "ctrl-e"), (delay: 0, mapping: "ctrl-rightbracket"), (delay: 0, mapping: "ctrl-slash"), (delay: 0, mapping: "d")],
    [(delay: 0, mapping: "space"), (delay: 1000, mapping: "f,o,o,shift-2,b,a,r,dot,c,o,m"), (delay: 0, mapping: "shift-p"), (delay: 0, mapping: "d")],
```

### Rotary Encoders

Rotary encoders (aka knobs) are listed from left to right if horizontal
and from top to bottom if vertical. They can be rotated
counter-clockwise (ccw) or clockwise (cw) and pressed down like a button

``` ron
    knobs: [
        (ccw: (delay: 0, mapping: "3"), press: (delay: 0, mapping: "3"), cw: (delay: 0, mapping: "3")),
        (ccw: (delay: 0, mapping: "volumedown"), press: (delay: 0, mapping: "mute"), cw: (delay: 0, mapping: "volumeup")),
    ],
),
```

### Mouse Events

Mouse events are clicks (\'click\', \'rclick\', \'mclick\') or wheel
events (\'wheelup\', \'wheeldown\') with one optional modifier, only
\'ctrl\', \'shift\' and \'alt\' are supported (\'ctrl-wheeldown\')
Clicks may combine several buttons, like this: \'click-rclick\'

``` ron
(
    buttons: [
        [(delay: 0, mapping: "click"), (delay: 0, mapping: "mclick"), (delay: 0, mapping: "rclick"), (delay: 0, mapping: "d")],
        [(delay: 0, mapping: "wheelup"), (delay: 0, mapping: "wheeldown"), (delay: 0, mapping: "space"), (delay: 0, mapping: "d")],
        [(delay: 0, mapping: "ctrl-wheelup"), (delay: 0, mapping: "ctrl-wheeldown"), (delay: 0, mapping: "right"), (delay: 0, mapping: "d")],
    ],
    knobs: [
        (ccw: (delay: 0, mapping: "3"), press: (delay: 0, mapping: "3"), cw: (delay: 0, mapping: "3")),
        (ccw: (delay: 0, mapping: "volumedown"), press: (delay: 0, mapping: "mute"), cw: (delay: 0, mapping: "volumeup")),
    ],
),
```

### Multimedia Support

Multimedia commands are also supported. Howerver, they cannot be mixed
with normal keys and modifiers

``` ron
        (
            buttons: [
                [(delay: 0, mapping: "ctrl-m"), (delay: 0, mapping: "ctrl-slash"), (delay: 0, mapping: "space"), (delay: 0, mapping: "p")],
                [(delay: 0, mapping: "volumeup"), (delay: 0, mapping: "volumedown"), (delay: 0, mapping: "play"), (delay: 0, mapping: "next")],
                [(delay: 0, mapping: "ctrl-rightbracket"), (delay: 0, mapping: "ctrl-leftbracket"), (delay: 0, mapping: "right"), (delay: 0, mapping: "left")],
            ],
            knobs: [
                (ccw: (delay: 0, mapping: "3"), press: (delay: 0, mapping: "3"), cw: (delay: 0, mapping: "3")),
                (ccw: (delay: 0, mapping: "volumedown"), press: (delay: 0, mapping: "mute"), cw: (delay: 0, mapping: "volumeup")),
            ],
        ),
    ],
)
```

# Usage

## udev rules for linux

To access the device without being root, copy the 80-macropad.rules to
/etc/udev/rules.d and reload udev

``` example
sudo cp 80-macropad.rules /etc/udev/rules.d
sudo udevadm trigger
```

## Supported keys

A list of supported keys can be found by running

``` example
macropad-tool show-keys
```

## Validate configuration

``` example
macropad-tool validate -h
macropad-tool validate # by default looks for a mapping.ron file
macropad-tool validate -c <ron_file>  # to specify a different configuration file
```

## Program the keyboard

Needs root access or ensure udev rules was added. For Windows, need
Administrator command prompt

``` example
macropad-tool program -h
macropad-tool program # by defult looks for a mapping.ron file
macropad-tool program -c <ron_file>  # to specify a different configuration file
```

## LED Support

Some keyboards support LEDs and you can program the different modes via
the led command

``` example
macropad-tool led <mode> <layer> <color> # Only for 884x model
macropad-tool led 1 1 red 
macropad-tool led -h  # the help menu about different modes/colors
```

# Windows

## Compiling

Installing rust with the installer prompts to install visual studio
community edition (which is free) and is sufficient to build the
executable

## Debugging

To see the debug logs set the `RUST_LOG` environment variable. Example: `$env:RUST_LOG = "debug"`

## Running the Application

-   You will need to install the USB Development Kit to be able to talk
    to the macropad. <https://github.com/daynix/UsbDk/releases>

NOTE: Make sure you reboot after installing USB Development Kit. 

# Hardware Chipsets

To get the list of USB devices in Windows use `Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' } | Sort-Object InstanceId | ft -AutoSize`

My device is listed as follows, so the chipset is **k884x**
```
Status Class     FriendlyName                         InstanceId
------ -----     ------------                         ----------
OK     USB       USB Composite Device                 USB\VID_1189&PID_8842\CD70134330393831
OK     HIDClass  USB Input Device                     USB\VID_1189&PID_8842&MI_00\7&1EC24542&0&0000
OK     HIDClass  USB Input Device                     USB\VID_1189&PID_8842&MI_01\7&1EC24542&0&0001
```

To validate your configuration

```
.\macropad-tool.exe validate -d -p "0x8842"
```

