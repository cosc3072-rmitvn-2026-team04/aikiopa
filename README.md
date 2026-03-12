
AIKIOPA
=======

COSC3072 Games Studio 1 Project, Team 04, RMIT Vietnam 2026.

## 📦 Dependencies

- Godot 4.6-stable
- Godot Export Template 4.6.stable
- Git
- Windows 10 and above (x64)

Make sure you have installed these dependencies before continuing.

You might want to use a package manager. My recommendations are: [winget](https://github.com/microsoft/winget-cli), [chocolatey](https://chocolatey.org/), or [scoop](https://scoop.sh/).

For Linux/Mac users, you are suggested to run a Windows virtual machine.

**Note**: Our project targets Windows 10 and above (x64) PCs only, and our development environment is set up entirely around the Windows ecosystem.


## 🧩 Project Structure

```yaml
📂.
├── 📂.github/          # GitHub Actions workflows
├── 📂.vscode/          # Visual Studio Code config
├── 📂assets/           # Assets (art, music, sfx, etc.)
├── 📂scenes/           # Scene files (`.tscn`)
├── 📂scripts/          # GDScript files (`.gd`)
├── 📂shaders/          # Shader files (`.gdshader`)
├── 📂build/            # Export artifacts (`.exe`)
├── .editorconfig
├── .gitattributes
├── .gitignore
├── build.ps1           # Export/build automation script
├── export_presets.cfg  # Godot export config
├── icon.svg            # Project icon
├── project.godot       # Godot project config
├── LICENSE             # License information
└── README.md           # This file
```


### Code Editor/IDE:

Recommended plugins if you decide to use [Visual Studio Code](https://code.visualstudio.com/):
- [godot-tools](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools).
- [Godot Files](https://marketplace.visualstudio.com/items?itemName=alfish.godot-files).


## 🧰 Export, Testing, and Deploy

To export and play the game locally for testing and release, run the following command from the root directory:

- Release export:
    ```shell
    ./build.ps1 -c -m release
    ```
- Debug export:
    ```shell
    ./build.ps1 -c -m debug
    ```

You can find export output under `build/` directory. Artifact archive (`.zip` files) can be found in `artifact/` directory.

To clean exported files, run the following command:

```shell
./build.ps1 -c

```

For further information, use:

```shell
./build.ps1 -h

```


## 📃 Coding Conventions

- We follow the [GDScript style guide](https://docs.godotengine.org/en/4.6/tutorials/scripting/gdscript/gdscript_styleguide.html).
- Prefer verbose documentation comments in custom classes where applicable. See [GDScript documentation comments](https://docs.godotengine.org/en/4.6/tutorials/scripting/gdscript/gdscript_documentation_comments.html).
