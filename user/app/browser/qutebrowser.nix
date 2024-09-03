{ config, pkgs, userSettings, ... }:
let generateHomepage = name: font: config:
  ''<!DOCTYPE html>
    <html>

    <head>
      <title>My Local Dashboard Awesome Homepage</title>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <style>
        /*body*/
        body {
            background-color: #''+config.lib.stylix.colors.base00+''

        }
        /*paragraphs*/
        p {
            font-family:''+font+'';

            font-size:24px;
            text-align:center;
            color: #''+config.lib.stylix.colors.base08+'';

            line-height: 1.35;
            margin-top: 0;
            margin-bottom: 0;
        }
        .open {
          color: #''+config.lib.stylix.colors.base09+'';
          font-weight: bold;
        }
        .quickmarks {
          color: #''+config.lib.stylix.colors.base0A+'';
          font-weight: bold;
        }
        .history {
          color: #''+config.lib.stylix.colors.base0B+'';
          font-weight: bold;
        }
        .newtab {
          color: #''+config.lib.stylix.colors.base0C+'';
          font-weight: bold;
        }
        .close {
          color: #''+config.lib.stylix.colors.base0D+'';
          font-weight: bold;
        }

        /*div*/
        div {
            margin:auto;
            width:50%;
            text-align:center;
        }
        /*class made for ascii art icon*/
        .icon {
            line-height:10%
        }
      </style>
    </head>

    <body>
      <!--start with cool qutebrowser ascii art-->
      <br>
      <br>
      <br>
      <div class="icon">
           <img width="300" src="logo.png">
      </div>
      <br>
      <br>
      <br>
      <!--qutebrowser title-->
      <p style="color:#''+config.lib.stylix.colors.base01+''">Welcome to Qutebrowser</p>
      <br>
      <p><b>''+name+" "+''Profile</b></p>
      <br>
      <!--basic keyboard commands-->
      <div>
        <p class="open"> [o] [Search] </p>
        <p class="quickmarks"> [b] [Quickmarks] </p>
        <p class="history"> [S h] [History] </p>
        <p class="newtab"> [t] [New tab] </p>
        <p class="close"> [x] [Close tab] </p>
      </div>
    </body>

    </html>
  '';
in
{

  home.packages = [ pkgs.qutebrowser
                    (pkgs.callPackage ./qute-containers.nix { dmenuCmd = "fuzzel -d"; })
                  ];
  # home.sessionVariables = { DEFAULT_BROWSER = "${pkgs.qutebrowser}/bin/qutebrowser"; };
  # xdg.mimeApps.defaultApplications = {
  # "text/html" = "org.qutebrowser.qutebrowser.desktop";
  # "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
  # "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
  # "x-scheme-handler/about" = "org.qutebrowser.qutebrowser.desktop";
  # "x-scheme-handler/unknown" = "org.qutebrowser.qutebrowser.desktop";
  # };
  home.file.".config/qutebrowser/userscripts/container-open".source = "${(pkgs.callPackage ./qute-containers.nix { dmenuCmd = "fuzzel -d"; })}/bin/container-open";
  home.file.".config/qutebrowser/userscripts/containers_config".source = "${(pkgs.callPackage ./qute-containers.nix { dmenuCmd = "fuzzel -d"; })}/bin/containers_config";

  programs.qutebrowser.enable = true;
  programs.qutebrowser.extraConfig = ''
import sys
import os.path
secretsExists = False
secretFile = os.path.expanduser("~/.config/qutebrowser/qutesecrets.py")

if (os.path.isfile(secretFile)):
    sys.path.append(os.path.dirname(secretFile))
    import qutesecrets
    secretsExists = True

config.set('qt.args',['ignore-gpu-blacklist','enable-gpu-rasterization','enable-native-gpu-memory-buffers','num-raster-threads=4'])
config.load_autoconfig(False)
c.aliases = {
    "w": "session-save",
    "q": "quit",
    "wq": "quit --save",
    "ad": "adblock-update",
}

# set dark mode
#config.set("colors.webpage.darkmode.enabled", True)

## setup umpv:
config.unbind("m")
# config.bind('mm', 'spawn umpv {url}')
# config.bind("mm", "hint links spawn ~/.local/bin/umpv {hint-url}")
config.bind("mm", "hint links spawn /usr/bin/yt-dlp {hint-url}")

# for music to play in background
config.bind("P", "hint links spawn mpv {hint-url} --no-video")

#c.colors.webpage.preferred_color_scheme = "dark"
c.content.javascript.clipboard = "access-paste"

## Enable JavaScript.
## Type: Bool
c.content.javascript.enabled = True
c.content.local_content_can_access_file_urls = True
c.content.local_content_can_access_remote_urls = True
c.downloads.location.directory = "/home/''+userSettings.username+''/Downloads"
c.downloads.remove_finished = 20000
# c.fonts.default_size = "18pt"

base00 = "#''+config.lib.stylix.colors.base00+''"
base01 = "#''+config.lib.stylix.colors.base01+''"
base02 = "#''+config.lib.stylix.colors.base02+''"
base03 = "#''+config.lib.stylix.colors.base03+''"
base04 = "#''+config.lib.stylix.colors.base04+''"
base05 = "#''+config.lib.stylix.colors.base05+''"
base06 = "#''+config.lib.stylix.colors.base06+''"
base07 = "#''+config.lib.stylix.colors.base07+''"
base08 = "#''+config.lib.stylix.colors.base08+''"
base09 = "#''+config.lib.stylix.colors.base09+''"
base0A = "#''+config.lib.stylix.colors.base0A+''"
base0B = "#''+config.lib.stylix.colors.base0B+''"
base0C = "#''+config.lib.stylix.colors.base0C+''"
base0D = "#''+config.lib.stylix.colors.base0D+''"
base0E = "#''+config.lib.stylix.colors.base0E+''"
base0F = "#''+config.lib.stylix.colors.base0F+''"

config.set('content.cookies.accept', 'no-3rdparty', 'chrome-devtools://*')
config.set('content.cookies.accept', 'no-3rdparty', 'devtools://*')

config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}; rv:90.0) Gecko/20100101 Firefox/90.0', 'https://accounts.google.com/*')
config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99 Safari/537.36', 'https://*.slack.com/*')

config.set('content.images', True, 'chrome-devtools://*')
config.set('content.images', True, 'devtools://*')

config.set('content.javascript.enabled', True, 'chrome-devtools://*')
config.set('content.javascript.enabled', True, 'devtools://*')
config.set('content.javascript.enabled', True, 'chrome://*/*')
config.set('content.javascript.enabled', True, 'qute://*/*')
config.set('zoom.default', '180%')
config.set('content.javascript.enabled', True, 'qute://*/*')

c.tabs.favicons.scale = 1.0
c.tabs.last_close = 'close'
c.tabs.position = 'top'
c.tabs.width = '3%'
c.window.transparent = True
c.colors.webpage.darkmode.enabled = ''+(if (config.stylix.polarity == "dark") then "True" else "False")+''

c.colors.webpage.preferred_color_scheme = "''+config.stylix.polarity+''"
c.colors.webpage.darkmode.policy.images = 'never'

c.url.searchengines = {
    "DEFAULT": "https://lili2023.dedyn.io/?q={}",
    "a": "https://www.amazon.com/s?k={}",
    "aw": "https://wiki.archlinux.org/?search={}",
    "re": "https://old.reddit.com/r/{}",
    "ub": "https://urbandictionary.com/define.php?term={}",
    "yt": "http://localhost:3000/results?search_query={}",
    "ww": "https://en.wikipedia.org/?search={}",
    "tpb": "http://thepiratebay.org/search/{}",
    "eb": "http://ebay.com/sch/{}",
    "ddg": "http://duckduckgo.com/?q={}",
    "star": "https://github.com/stars?utf8=%E2%9C%93&q={}",
    "so": "https://google.com/search?q=site:stackoverflow.com {}",
    "gl": "http://www.google.com/search?q={}&btnI=Im+Feeling+Lucky",
    "ghi": "https://github.com/{}/issues",
    "wa": "http://www.wolframalpha.com/input/?i={}",
    "ha": "https://google.com/search?q=site:hackage.haskell.org {}",
    "gamedev": "http://gamedev.stackexchange.com/search?q={}",
    "npm": "https://npmjs.org/search?q={}",
    "cargo": "https://crates.io/search?q={}",
    "zen": "http://brandalliance.zendesk.com/search?query={}",
    "g": "https://www.google.com/search?q={}",
    "st": "https://yifysubtitles.ch/search?q={}",
    "alert": "http://alrt.io/{}",
    "hackage": "http://hackage.haskell.org/package/{}",
    "travis": "https://travis-ci.org/{}",
    "ttx": "https://testnet.smartbit.com.au/tx/{}/",
    "e": "https://www.google.com/search?q=site%3Apackage.elm-lang.org+{}&btnI=Im+Feeling+Lucky",
    "key": "https://www.npmjs.org/browse/keyword/{}",
    "h": "http://holumbus.fh-wedel.de/hayoo/hayoo.html?query={}",
    "hoogle": "http://www.haskell.org/hoogle/?hoogle={}",
    "github": "http://github.com/search?q={}",
    "ph": "http://phind.com/search?q={}",
    "ai": "https://chat.openai.com/chat?q={}",
    "ba": "http://blockstream.info/address/{}",
    "bgg": "http://www.boardgamegeek.com/metasearch.php?searchtype=game&search={}",
    "pgp": "http://pgp.mit.edu/pks/lookup?search={}&op=index",
    "gh": "https://github.com/{}",
    "cd": "https://docs.rs/{}/latest",
    "crate": "https://crates.io/crates/{}",
    "repo": "http://npmrepo.com/{}",
    "ec": "http://package.elm-lang.org/packages/elm-lang/{}/latest",
    "btx": "https://blockstream.info/tx/{}",
}

# toggle to remove the bars for a clean look.
config.bind(
    "xx",
    "config-cycle statusbar.show never always;; config-cycle tabs.show never always",
)

config.bind("aa", 'cmd-set-text -s :bookmark-add {url} "{title}"')
config.set("fonts.hints", "bold 20px default_family")
## Page(s) to open at the start.
## Type: List of FuzzyUrl, or FuzzyUrl
# c.url.start_pages = ["http://localhost:3000/feed/subscriptions"]
c.url.start_pages = ["https://homepage.motard.site/"]
#config.set('completion.open_categories',["searchengines","quickmarks","bookmarks"])

#config.set('downloads.location.directory', '~/Downloads')

c.fileselect.handler = "external"
c.fileselect.multiple_files.command = [
    "alacritty",
    "-e",
    "yazi",
    "--chooser-file={}",
]
c.fileselect.single_file.command = [
    "alacritty",
    "-e",
    "yazi",
    "--chooser-file={}",
]
c.window.transparent = True
# c.zoom.default = "175%"
config.bind("K", "tab-next")
config.bind("J", "tab-prev")

# # bindings from doom emacs
# config.bind('<Alt-x>', 'cmd-set-text :')
# config.bind('<Space>.', 'cmd-set-text :')
# config.bind('<Space>b', 'bookmark-list')
# config.bind('<Space>h', 'history')
# config.bind('<Space>gh', 'open https://github.com')
# config.bind('<Space>gl', 'open https://gitlab.com')
# config.bind('<Space>gc', 'open https://codeberg.org')
# if (secretsExists):
#     config.bind('<Space>gg', 'open '+qutesecrets.mygiteadomain)
# config.bind('<Ctrl-p>', 'completion-item-focus prev', mode='command')
# config.bind('<Ctrl-n>', 'completion-item-focus next', mode='command')
# config.bind('<Ctrl-p>', 'fake-key <Up>', mode='normal')
# config.bind('<Ctrl-n>', 'fake-key <Down>', mode='normal')
# config.bind('<Ctrl-p>', 'fake-key <Up>', mode='insert')
# config.bind('<Ctrl-n>', 'fake-key <Down>', mode='insert')

# # bindings from vimium
# config.bind('t', 'open -t')
# config.bind('x', 'tab-close')
# config.bind('yf', 'hint links yank')

# # spawn external programs
# config.bind(',m', 'hint links spawn mpv {hint-url}')
# config.bind(',co', 'spawn container-open')
# config.bind(',cf', 'hint links userscript container-open')

# TODO stylix user CSS
# current_stylesheet_directory = '~/.config/qutebrowser/themes/'
# current_stylesheet = base16_theme+'-all-sites.css'
# current_stylesheet_path = current_stylesheet_directory + current_stylesheet
# config.set('content.user_stylesheets', current_stylesheet_path)
#config.bind(',s', 'set content.user_stylesheets \'\' ')
#config.bind(',S', 'set content.user_stylesheets '+current_stylesheet_path)

# theming
c.colors.completion.fg = base05
c.colors.completion.odd.bg = base01
c.colors.completion.even.bg = base00
c.colors.completion.category.fg = base0A
c.colors.completion.category.bg = base00
c.colors.completion.category.border.top = base00
c.colors.completion.category.border.bottom = base00
c.colors.completion.item.selected.fg = base05
c.colors.completion.item.selected.bg = base02
c.colors.completion.item.selected.border.top = base02
c.colors.completion.item.selected.border.bottom = base02
c.colors.completion.item.selected.match.fg = base0B
c.colors.completion.match.fg = base0B
c.colors.completion.scrollbar.fg = base05
c.colors.completion.scrollbar.bg = base00
c.colors.contextmenu.disabled.bg = base01
c.colors.contextmenu.disabled.fg = base04
c.colors.contextmenu.menu.bg = base00
c.colors.contextmenu.menu.fg =  base05
c.colors.contextmenu.selected.bg = base02
c.colors.contextmenu.selected.fg = base05
c.colors.downloads.bar.bg = base00
c.colors.downloads.start.fg = base00
c.colors.downloads.start.bg = base0D
c.colors.downloads.stop.fg = base00
c.colors.downloads.stop.bg = base0C
c.colors.downloads.error.fg = base08
c.colors.hints.fg = base00
c.colors.hints.bg = base0A
c.colors.hints.match.fg = base05
c.colors.keyhint.fg = base05
c.colors.keyhint.suffix.fg = base05
c.colors.keyhint.bg = base00
c.colors.messages.error.fg = base00
c.colors.messages.error.bg = base08
c.colors.messages.error.border = base08
c.colors.messages.warning.fg = base00
c.colors.messages.warning.bg = base0E
c.colors.messages.warning.border = base0E
c.colors.messages.info.fg = base05
c.colors.messages.info.bg = base00
c.colors.messages.info.border = base00
c.colors.prompts.fg = base05
c.colors.prompts.border = base00
c.colors.prompts.bg = base00
c.colors.prompts.selected.bg = base02
c.colors.prompts.selected.fg = base05
c.colors.statusbar.normal.fg = base0B
c.colors.statusbar.normal.bg = base00
c.colors.statusbar.insert.fg = base00
c.colors.statusbar.insert.bg = base0D
c.colors.statusbar.passthrough.fg = base00
c.colors.statusbar.passthrough.bg = base0C
c.colors.statusbar.private.fg = base00
c.colors.statusbar.private.bg = base01
c.colors.statusbar.command.fg = base05
c.colors.statusbar.command.bg = base00
c.colors.statusbar.command.private.fg = base05
c.colors.statusbar.command.private.bg = base00
c.colors.statusbar.caret.fg = base00
c.colors.statusbar.caret.bg = base0E
c.colors.statusbar.caret.selection.fg = base00
c.colors.statusbar.caret.selection.bg = base0D
c.colors.statusbar.progress.bg = base0D
c.colors.statusbar.url.fg = base05
c.colors.statusbar.url.error.fg = base08
c.colors.statusbar.url.hover.fg = base05
c.colors.statusbar.url.success.http.fg = base0C
c.colors.statusbar.url.success.https.fg = base0B
c.colors.statusbar.url.warn.fg = base0E
c.colors.tabs.bar.bg = base00
c.colors.tabs.indicator.start = base0D
c.colors.tabs.indicator.stop = base0C
c.colors.tabs.indicator.error = base08
c.colors.tabs.odd.fg = base05
c.colors.tabs.odd.bg = base01
c.colors.tabs.even.fg = base05
c.colors.tabs.even.bg = base00
c.colors.tabs.pinned.even.bg = base0C
c.colors.tabs.pinned.even.fg = base07
c.colors.tabs.pinned.odd.bg = base0B
c.colors.tabs.pinned.odd.fg = base07
c.colors.tabs.pinned.selected.even.bg = base02
c.colors.tabs.pinned.selected.even.fg = base05
c.colors.tabs.pinned.selected.odd.bg = base02
c.colors.tabs.pinned.selected.odd.fg = base05
c.colors.tabs.selected.odd.fg = base05
c.colors.tabs.selected.odd.bg = base02
c.colors.tabs.selected.even.fg = base05
c.colors.tabs.selected.even.bg = base02

font = "''+userSettings.font+''"

c.fonts.default_family = font
c.fonts.default_size = '24pt'

c.fonts.web.family.standard = font
c.fonts.web.family.serif = font
c.fonts.web.family.sans_serif = font
c.fonts.web.family.fixed = font
c.fonts.web.family.fantasy = font
c.fonts.web.family.cursive = font
  '';

  home.file.".config/qutebrowser/containers".text = ''
Teaching
Tech
Gamedev
Bard
  '';

  home.file.".config/qutebrowser/qute-home.html".text = generateHomepage "Default" userSettings.font config;
  home.file.".config/qutebrowser/logo.png".source = ./qutebrowser-logo.png;
  home.file.".browser/Teaching/config/qute-home.html".text = generateHomepage "Teaching" userSettings.font config;
  home.file.".browser/Teaching/config/logo.png".source = ./qutebrowser-logo.png;
  home.file.".browser/Tech/config/qute-home.html".text = generateHomepage "Tech" userSettings.font config;
  home.file.".browser/Tech/config/logo.png".source = ./qutebrowser-logo.png;
  home.file.".browser/Gaming/config/qute-home.html".text = generateHomepage "Gaming" userSettings.font config;
  home.file.".browser/Gaming/config/logo.png".source = ./qutebrowser-logo.png;
  home.file.".browser/Gamedev/config/qute-home.html".text = generateHomepage "Gamedev" userSettings.font config;
  home.file.".browser/Gamedev/config/logo.png".source = ./qutebrowser-logo.png;
  home.file.".browser/Bard/config/qute-home.html".text = generateHomepage "Bard" userSettings.font config;
  home.file.".browser/Bard/config/logo.png".source = ./qutebrowser-logo.png;

}
