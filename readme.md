# Not Shadow Content

Removes the drop shadow that Zen Browser casts on the web content panel.

By default Zen renders the active page inside a rounded container with a
`box-shadow` (the `--zen-big-shadow` variable), which separates the page from
the window chrome. This mod removes that shadow, leaving the border radius
intact.

Only the main web content is affected. The bookmarks sidebar, Glance and split
view keep their own shadows.

## Installation

Install it from the [Zen Mods Registry](https://www.zen-browser.app/mods), or
manually by copying `chrome.css` into your profile:

```
<profile>/chrome/zen-themes/not-shadow-content/chrome.css
```

You can find your profile folder in Zen under `about:support` → Profile Folder.

## Preferences

None. Enable or disable the mod from Settings → Mods.

## Compatibility

Tested on Zen Browser 1.22.3b. No JavaScript, no network requests, no
permissions required.
