# ghostty-dir-colors

Auto-color your [Ghostty](https://ghostty.org) terminal tabs based on your working directory. Each project gets a consistent, unique background tint — no configuration needed.

![demo concept: different tabs with subtle color differences based on directory](https://img.shields.io/badge/ghostty-tabs_by_directory-blue)

## How it works

- Hashes your project directory path into an HSL hue
- Sets the terminal background via OSC 11 escape sequence
- Ghostty automatically updates the tab color to match
- Same directory → same color, always
- Fires on every `cd` via zsh's `chpwd` hook

## Install

```bash
# Clone
git clone https://github.com/feral-reserve/ghostty-dir-colors.git

# Source in your .zshrc
echo 'source /path/to/ghostty-dir-colors/ghostty-dir-colors.zsh' >> ~/.zshrc
```

Or just copy `ghostty-dir-colors.zsh` wherever you want and source it.

## Configuration

Three variables at the top of the script:

| Variable | Default | Description |
|----------|---------|-------------|
| `_dir_color_depth` | `3` | Path components used as the color key. `3` means `~/dev/myproject/src` and `~/dev/myproject/docs` share a color (keyed on `dev/myproject`). |
| `_dir_color_sat` | `40` | Color saturation (0–100). Higher = more vivid. |
| `_dir_color_lit` | `12` | Lightness (0–100). Keep low for dark backgrounds. |

Your home directory (`~`) always gets a neutral default (`#0e0e0e`).

## Requirements

- [Ghostty](https://ghostty.org) terminal
- zsh
- `md5` (macOS) or `md5sum` (Linux)

## How it actually works

1. On every `cd`, the script takes your current path, strips `$HOME`, and grabs the first N components as a "project key"
2. That key gets MD5-hashed and the first 4 hex chars become a hue (0–359)
3. The hue + fixed saturation/lightness produce a dark background color
4. An OSC 11 escape sequence tells Ghostty to update the background
5. Ghostty's tab inherits the background color automatically

No lookup tables. No config files per project. Just math.

## License

MIT
