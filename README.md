# slidetoattack
*Demonstration of the use of side-facing character sprites in an isometrically projected 2D game stage*

[![GitHub](https://img.shields.io/github/license/musicofmusix/slidetoattack)](./LICENSE)
[![LOVE](https://img.shields.io/badge/L%C3%96VE-11.4-blue)](https://github.com/love2d/love/releases/tag/11.4)
[![Spine](https://img.shields.io/badge/Spine-3.8-red)](https://github.com/EsotericSoftware/spine-runtimes/tree/3.8)

<p align="center">
  <img width=80% src="https://user-images.githubusercontent.com/18087232/156870313-ad67a2c7-fb2c-4e8a-b491-041a40ab5ef3.png">
</p>

## Rationale
Wouldn't it be great to take chracter sprites made for sidescrollers and utilise them in an isometric environment? Having access to the decades worth of assets will definitely help many isometric projects.

However, this is not as easy as slapping sprites on an isometric stage and calling it a day. The horizontal viewing angle of 45 degrees means that any sort of interaction with adjacent sprites suffer from a y-axis offset:
<p align="center">
  <img width=80% src="https://user-images.githubusercontent.com/18087232/156870478-f560237f-48de-483d-b5b6-f4727c480f05.png">
</p>

Then how about rotating the entire stage 45 degrees clockwise or anticlockwise every time an interaction happens? This works rather well for the popular "isometric board game" aesthetic, and this project is a demonstration of that:

<p align="center">
  <img width=80% src="https://user-images.githubusercontent.com/18087232/156870537-b76d83ba-9219-4e6c-bffe-04b85208f705.png">
</p>

## Features
- A fully code-drawn isometric stage with its size configurable by the user
- Four-way sliding on screen to rotate stage and trigger sprite interactions
<p align="center">
  <img width=60% src="https://user-images.githubusercontent.com/18087232/156870611-5552fd62-fe87-4664-8c3f-bb5066ea7c71.gif">
</p>

- Movement and interaction (attack) functionality for characters
<p align="center">
  <img width=60% src="https://user-images.githubusercontent.com/18087232/156870682-8dd1df57-6b09-4168-a879-30cb37c26d8a.gif">
</p>

- [Spine](http://esotericsoftware.com) animation support for sprite attack, hurt, and death animations
- Works for most common screen aspect ratios and is framerate-independent

## Running the Demo
[LÖVE](https://love2d.org) 11.4 is required on any supported platform, although any 11.X version will work. The [LÖVE wiki ](https://love2d.org/wiki/Getting_Started) contains instructions on executing a LÖVE program for each platform.

The character sprites shown in the gifs above are not part of the hosted code; one must include their own Spine character sprites alongside the [Spine-Lua](https://github.com/EsotericSoftware/spine-runtimes/tree/3.8/spine-lua) and [Spine-LOVE](https://github.com/EsotericSoftware/spine-runtimes/tree/3.8/spine-love) runtimes. This demo was tested with Spine 3.8 sprites and runtimes.

Note that one must also obtain a [Spine License](https://esotericsoftware.com/spine-purchase) for full use of the runtimes. For legal details, please refer to the [Spine Runtimes License Agreement](http://esotericsoftware.com/spine-runtimes-license) and [Spine Editor License Agreement](http://esotericsoftware.com/spine-editor-license#s2)(Section 2).

Place the `spine-lua` and `spine-love` directories in the project root `/`. For each sprite place its .json, .atlas and .png file inside a subfolder in `/assets`. All raw assets are accessed though the wrapper module `/assets/assetmapping.lua`; use the `/assetmapping_template.lua` template provided.

Three animations are used: `Idle`, `Attack`, `Hurt`, and `Die`. These strings are hardcoded at the moment; make sure such animations exist in the sprites included. During the `Attack` animation, it is expected for the sprite to call an `onAttack` Spine event, triggered when an attack connects ("hits") with its target. No other events are required.

Additionally, it is reccomended to add a font to `/assets/font` for text rendering.

## Issues
- Running on various screen aspect ratios and resolutions work but resizing is bugged. It is disabled by default in `main.lua`.
- For older commits, the interface/wrapper for handling sprite assets is not implemented well; getting them to work may require some tinkering.

## Licensing
This project is distributed under the MIT license. Please feel free to use, modify, or simply take the concept and create derivative work. This is merely a demo after all. See `LICENSE` for more information.

## Acknowledgements
- [yurakr](https://graphicriver.net/user/yurakr) for creating the character sprites used in the above images. Purchased from [ GraphicRiver](https://graphicriver.net)
- [rsms](https://rsms.me) for the [Inter](https://rsms.me/inter) typeface, also used in the above images.
