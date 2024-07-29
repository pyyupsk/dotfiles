# VS Code Configuration

This directory contains the configuration settings for Visual Studio Code to enhance your coding experience with a customized theme and settings.

## VS Code Settings

Below is the `settings.json` configuration:

```json
{
    "editor.cursorBlinking": "phase",
    "editor.minimap.enabled": false,
    "editor.renderWhitespace": "none",
    "editor.tabCompletion": "on",
    "editor.cursorSurroundingLines": 15,
    "editor.cursorStyle": "line",
    "window.commandCenter": false,
    "workbench.layoutControl.enabled": false,
    "workbench.iconTheme": "material-icon-theme",
    "workbench.colorTheme": "Everblush Theme",
    "editor.accessibilitySupport": "off",
    "window.menuBarVisibility": "compact"
}
```

### Settings Definitions

-   **editor.cursorBlinking**: Sets the cursor blinking style to "phase".
-   **editor.minimap.enabled**: Disables the minimap.
-   **editor.renderWhitespace**: Disables rendering of whitespace characters.
-   **editor.tabCompletion**: Enables tab completion for suggestions.
-   **editor.cursorSurroundingLines**: Adds surrounding lines for the cursor for better visibility.
-   **editor.cursorStyle**: Sets the cursor style to "line".
-   **window.commandCenter**: Disables the command center.
-   **workbench.layoutControl.enabled**: Disables the layout control.
-   **workbench.iconTheme**: Sets the icon theme to "material-icon-theme".
-   **workbench.colorTheme**: Sets the color theme to "Everblush Theme".
-   **editor.accessibilitySupport**: Disables accessibility support.
-   **window.menuBarVisibility**: Sets the menu bar visibility to "compact".

## Theme "Everblush Theme"

To use the Everblush theme, follow these steps:

### Build from Source

1. Clone the Everblush repository:
    ```sh
    git clone https://github.com/pyyupsk/Everblush.git
    ```
2. Navigate to the VS Code theme directory:
    ```sh
    cd Everblush/vscode
    ```
3. Install `vsce` globally:
    ```sh
    npm i -g vsce
    ```
4. Build the theme:
    ```sh
    npm run build
    ```

This command will create a `.vsix` file in the `vscode` directory.

### Install from VSIX

1. Open VSCode.
2. Open the Command Palette (`Ctrl+Shift+P` on Windows/Linux or `Cmd+Shift+P` on macOS).
3. Type `Extensions: Install from VSIX...` and select it.
4. Select the `.vsix` file you created in the `vscode` directory.

### Apply Theme

1. Press `Ctrl+K Ctrl+T` (Cmd+K Cmd+T on macOS) to open the theme selector.
2. Select "Everblush Theme" from the list of installed themes.

## Material Icon Theme (Optional)

To further enhance your VS Code setup with a beautiful icon theme:

1. Install the Material Icon Theme from the [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme).
    - Click the "Install" button.
2. After installation, set it as your icon theme:
    - VS Code will navigate to the marketplace and install the extension.
    - Click on the "Set File Icon Theme" button.

Enjoy your customized VS Code setup!
