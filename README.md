<div align="center">
	<img src="icon.svg" alt="Logo" width="160" height="160">

<h3 align="center">Pixel space background generator</h3>

  <p align="center">
   Port to Godot 4 for the pixel space background generator by deep-fold
	<br />
	·
	<a href="https://github.com/ninetailsrabbit/pixel-space-background-generator/issues/new?assignees=ninetailsrabbit&labels=%F0%9F%90%9B+bug&projects=&template=bug_report.md&title=">Report Bug</a>
	·
	<a href="https://github.com/ninetailsrabbit/pixel-space-background-generator/issues/new?assignees=ninetailsrabbit&labels=%E2%AD%90+feature&projects=&template=feature_request.md&title=">Request Features</a>
  </p>
</div>

<br>
<br>

- [📦 Installation](#-installation)
- [Getting started 🚀](#getting-started-)
  - [Features 👾](#features-)
- [How to use 🪛](#how-to-use-)
  - [Export background image 🖼️](#export-background-image-️)

# 📦 Installation

1. [Download Latest Release](https://github.com/ninetailsrabbit/pixel-space-background-generator/releases/latest)
2. Unpack the `addons/pixel_space_background_generator` folder into your `/addons` folder within the Godot project
3. Enable this addon within the Godot settings: `Project > Project Settings > Plugins`

To better understand what branch to choose from for which Godot version, please refer to this table:
|Godot Version|pixel-space-background-generator Branch|pixel-space-background-generator Version|
|---|---|--|
|[![GodotEngine](https://img.shields.io/badge/Godot_4.3.x_stable-blue?logo=godotengine&logoColor=white)](https://godotengine.org/)|`main`|`1.x`|

# Getting started 🚀

This project brings the [Pixel space background generator](https://deep-fold.itch.io/space-background-generator) created by the user [Deep-Fold](https://github.com/Deep-Fold) to the Godot 4 version.

## Features 👾

- **Create backgrounds directly in your scene:** Generate unique pixel art space backgrounds at runtime using a dedicated node in your Godot scene tree.
- **Customize with ease:** Exportable parameters allow you to fine-tune the space background generation process, tailoring them to your specific needs.
- **Export to image:**: Export your generated background as `.png` to reuse as texture in your projects.

# How to use 🪛

Open the scene `pixelspace_background_generator.tscn` provided by the plugin and modify the parameters to achieve the desired background.

This scene also works on runtime and you can change the parameters to create backgrounds dinamically in your game.

## Export background image 🖼️

The Image export currently **only works in-game**. If you export from the editor it will use the preview window with the zoom level and grey areas will appear.
