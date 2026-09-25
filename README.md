# Not Shadow Content

Removes the drop shadow that [Zen Browser](https://zen-browser.app) casts on the
web content panel, leaving the rounded corners intact.

## What it changes

Zen renders the active page inside a rounded container that carries a
`box-shadow`, which separates the page from the window chrome. This mod clears
that shadow on the web content only.

Everything else keeps the shadow it came with:

- Glance
- Split view
- The bookmarks sidebar
- The toolbar and its panels
- Download animations

The mod sets `box-shadow: none` directly on the content containers rather than
overriding Zen's `--zen-big-shadow` variable. Because `box-shadow` is not an
inherited property, nothing leaks into the rest of the interface, and no value
from Zen's internals has to be hardcoded.

## Install

```bash
git clone https://github.com/EmanuelMendoza20/not-shadow-content.git
cd not-shadow-content
./install.sh
```

The script locates your profile automatically, copies `chrome.css` into
`<profile>/chrome/zen-themes/not-shadow-content/`, and registers the mod in
`zen-themes.json`, keeping a backup of the original as `zen-themes.json.bak`.
Running it again just updates the files, so it is safe to re-run after pulling
changes.

If you have more than one profile, point it at the one you want:

```bash
ZEN_PROFILE="~/Library/Application Support/zen/Profiles/<profile>.Default (release)" ./install.sh
```

Restart Zen, or toggle the mod off and on in Settings → Mods.

### Manual install

If you would rather not run a script, copy `chrome.css` into your profile:

```
<profile>/chrome/zen-themes/not-shadow-content/chrome.css
```

You can find your profile folder in Zen under `about:support` → Profile Folder.
Locally installed mods can be enabled from Settings → Mods.

## Uninstall

```bash
./install.sh --remove
```

Toggling the mod off in Settings → Mods is enough if you only want to disable it.
To remove it completely, delete the `not-shadow-content` folder and the matching
entry in `zen-themes.json`.

## Compatibility

Tested on Zen Browser 1.22.3b (build 126.9.22). The mod is a single CSS file:
no JavaScript, no network requests, and no permissions required.

## License

MIT. See [LICENSE](LICENSE).
