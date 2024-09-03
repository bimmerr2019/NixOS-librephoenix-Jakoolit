{ inputs, config, lib, pkgs, userSettings, systemSettings, pkgs-nwg-dock-hyprland, ... }: 
let
  pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  python-packages = pkgs.python3.withPackages (
    ps:
     with ps; [
        requests
        pyquery # needed for hyprland-dots Weather script
        ]
    );
in
{
  imports = [
    ../../app/terminal/alacritty.nix
    ../../app/terminal/kitty.nix
    (import ../../app/dmenu-scripts/networkmanager-dmenu.nix {
      dmenu_command = "fuzzel -d"; inherit config lib pkgs;
    })
    ../input/nihongo.nix
  ] ++
  (if (systemSettings.profile == "personal") then
    [ (import ./hyprprofiles/hyprprofiles.nix {
        dmenuCmd = "fuzzel -d"; inherit config lib pkgs; })]
  else
    []);

  gtk.cursorTheme = {
    package = pkgs.quintom-cursor-theme;
    name = if (config.stylix.polarity == "light") then "Quintom_Ink" else "Quintom_Snow";
    size = 36;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    # plugins = [
    #   inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
    #   inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
    #   inputs.hyprgrass.packages.${pkgs.system}.default
    # ];
    settings = { };
    extraConfig = ''
# Sourcing external config files

# Default Configs
$configs = $HOME/.config/hypr/configs

source=$configs/Settings.conf
source=$configs/Keybinds.conf

# User Configs
$UserConfigs = $HOME/.config/hypr/UserConfigs

source= $UserConfigs/Startup_Apps.conf
source= $UserConfigs/ENVariables.conf
source= $UserConfigs/Monitors.conf
source= $UserConfigs/Laptops.conf
source= $UserConfigs/LaptopDisplay.conf
source= $UserConfigs/WindowRules.conf
source= $UserConfigs/UserKeybinds.conf
source= $UserConfigs/UserSettings.conf
source= $UserConfigs/WorkspaceRules.conf
    '';
    xwayland = { enable = true; };
    systemd.enable = true;
  };

  home.packages = (with pkgs; [
  # JAKOOLIT PROGRAMS FOR HYPRLAND FOLLOW
	  ags        
    btop
    cava
    cliphist
    dunst
    mpdris2
    signal-desktop
    sc-im
    nekoray
    eog
    gnome-system-monitor
    file-roller
    gtk-engine-murrine #for gtk themes
    hyprcursor # requires unstable channel
    jq
    kitty
	  libsForQt5.qtstyleplugin-kvantum #kvantum
	  networkmanagerapplet
    nwg-look # requires unstable channel
    nvtopPackages.full
	  playerctl
    pyprland
    qt5ct
    qt6ct
    qt6Packages.qtstyleplugin-kvantum #kvantum
    rofi-wayland
    swappy
    swaynotificationcenter
    swww
    unzip
    wl-clipboard
    wlogout
    yad
  # END JAKOOLIT PROGRAMS FOR HYPRLAND FOLLOW


    alacritty
    zathura
    kitty
    feh
    pam_u2f
    killall
    polkit_gnome
    nwg-launchers
    papirus-icon-theme
    (pkgs.writeScriptBin "nwggrid-wrapper" ''
      #!/bin/sh
      if pgrep -x "nwggrid-server" > /dev/null
      then
        nwggrid -client
      else
        GDK_PIXBUF_MODULE_FILE=${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache nwggrid-server -layer-shell-exclusive-zone -1 -g adw-gtk3 -o 0.55 -b ${config.lib.stylix.colors.base00}
      fi
    '')
    libva-utils
    libinput-gestures
    gsettings-desktop-schemas
    (pkgs.makeDesktopItem {
      name = "nwggrid";
      desktopName = "Application Launcher";
      exec = "nwggrid-wrapper";
      terminal = false;
      type = "Application";
      noDisplay = true;
      icon = "/home/"+userSettings.username+"/.local/share/pixmaps/hyprland-logo-stylix.svg";
    })
    (hyprnome.override (oldAttrs: {
        rustPlatform = oldAttrs.rustPlatform // {
          buildRustPackage = args: oldAttrs.rustPlatform.buildRustPackage (args // {
            pname = "hyprnome";
            version = "unstable-2024-05-06";
            src = fetchFromGitHub {
              owner = "donovanglover";
              repo = "hyprnome";
              rev = "f185e6dbd7cfcb3ecc11471fab7d2be374bd5b28";
              hash = "sha256-tmko/bnGdYOMTIGljJ6T8d76NPLkHAfae6P6G2Aa2Qo=";
            };
            cargoDeps = oldAttrs.cargoDeps.overrideAttrs (oldAttrs: rec {
              name = "${pname}-vendor.tar.gz";
              inherit src;
              outputHash = "sha256-cQwAGNKTfJTnXDI3IMJQ2583NEIZE7GScW7TsgnKrKs=";
            });
            cargoHash = "sha256-cQwAGNKTfJTnXDI3IMJQ2583NEIZE7GScW7TsgnKrKs=";
          });
        };
     })
    )
    # gnome.zenity
    zenity
    wlr-randr
    wtype
    ydotool
    wl-clipboard
    hyprland-protocols
    hyprpicker
    inputs.hyprlock.packages.${pkgs.system}.default
    # hypridle
    # hyprpaper
    fnott
    keepmenu
    pinentry-gnome3
    wev
    grim
    slurp
    libsForQt5.qt5.qtwayland
    qt6.qtwayland
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    wlsunset
    pavucontrol
    pamixer
    tesseract4
    (pkgs.writeScriptBin "screenshot-ocr" ''
      #!/bin/sh
      imgname="/tmp/screenshot-ocr-$(date +%Y%m%d%H%M%S).png"
      txtname="/tmp/screenshot-ocr-$(date +%Y%m%d%H%M%S)"
      txtfname=$txtname.txt
      grim -g "$(slurp)" $imgname;
      tesseract $imgname $txtname;
      wl-copy -n < $txtfname
    '')
    (pkgs.writeScriptBin "nwg-dock-wrapper" ''
      #!/bin/sh
      if pgrep -x ".nwg-dock-hyprl" > /dev/null
      then
        nwg-dock-hyprland
      else
        nwg-dock-hyprland -f -x -i 64 -nolauncher -a start -ml 8 -mr 8 -mb 8
      fi
    '')
    (pkgs.writeScriptBin "sct" ''
      #!/bin/sh
      killall wlsunset &> /dev/null;
      if [ $# -eq 1 ]; then
        temphigh=$(( $1 + 1 ))
        templow=$1
        wlsunset -t $templow -T $temphigh &> /dev/null &
      else
        killall wlsunset &> /dev/null;
      fi
    '')
    (pkgs.writeScriptBin "obs-notification-mute-daemon" ''
      #!/bin/sh
      while true; do
        if pgrep -x .obs-wrapped > /dev/null;
          then
            pkill -STOP fnott;
          else
            pkill -CONT fnott;
        fi
        sleep 10;
      done
    '')
    (pkgs.writeScriptBin "suspend-unless-render" ''
      #!/bin/sh
      if pgrep -x nixos-rebuild > /dev/null || pgrep -x home-manager > /dev/null || pgrep -x kdenlive > /dev/null || pgrep -x FL64.exe > /dev/null || pgrep -x blender > /dev/null || pgrep -x flatpak > /dev/null;
      then echo "Shouldn't suspend"; sleep 10; else echo "Should suspend"; systemctl suspend; fi
    '')
    (pkgs.makeDesktopItem {
      name = "emacsclientnewframe";
      desktopName = "Emacs Client New Frame";
      exec = "emacsclient -c -a emacs";
      terminal = false;
      icon = "emacs";
      type = "Application";
    })])
    ++ [python-packages
	      inputs.wallust.packages.${pkgs.system}.wallust
       ]
  ++
  (with pkgs-hyprland; [ ])
  ++ (with pkgs-nwg-dock-hyprland; [
    (nwg-dock-hyprland.overrideAttrs (oldAttrs: {
      patches = ./patches/noactiveclients.patch;
    }))
  ]);
  home.file.".local/share/pixmaps/hyprland-logo-stylix.svg".source =
    config.lib.stylix.colors {
      template = builtins.readFile ../../pkgs/hyprland-logo-stylix.svg.mustache;
      extension = "svg";
    };
  home.file.".config/nwg-dock-hyprland/style.css".text = ''
    window {
      background: rgba(''+config.lib.stylix.colors.base00-rgb-r+'',''+config.lib.stylix.colors.base00-rgb-g+'',''+config.lib.stylix.colors.base00-rgb-b+'',0.0);
      border-radius: 20px;
      padding: 4px;
      margin-left: 4px;
      margin-right: 4px;
      border-style: none;
    }

    #box {
      /* Define attributes of the box surrounding icons here */
      padding: 10px;
      background: rgba(''+config.lib.stylix.colors.base00-rgb-r+'',''+config.lib.stylix.colors.base00-rgb-g+'',''+config.lib.stylix.colors.base00-rgb-b+'',0.55);
      border-radius: 20px;
      padding: 4px;
      margin-left: 4px;
      margin-right: 4px;
      border-style: none;
    }
    button {
      border-radius: 10px;
      padding: 4px;
      margin-left: 4px;
      margin-right: 4px;
      background: rgba(''+config.lib.stylix.colors.base03-rgb-r+'',''+config.lib.stylix.colors.base03-rgb-g+'',''+config.lib.stylix.colors.base03-rgb-b+'',0.55);
      color: #''+config.lib.stylix.colors.base07+'';
      font-size: 12px
    }

    button:hover {
      background: rgba(''+config.lib.stylix.colors.base04-rgb-r+'',''+config.lib.stylix.colors.base04-rgb-g+'',''+config.lib.stylix.colors.base04-rgb-b+'',0.55);
    }

  '';
  home.file.".config/nwg-dock-pinned".text = ''
    nwggrid
    Alacritty
    emacsclientnewframe
    qutebrowser
    #brave-browser
    writer
    impress
    calc
    draw
    krita
    xournalpp
    obs
    kdenlive
    flstudio
    blender
    openscad
    Cura
    virt-manager
  '';
  # home.file.".config/hypr/hypridle.conf".text = ''
  #   general {
  #     lock_cmd = pgrep hyprlock || hyprlock
  #     before_sleep_cmd = loginctl lock-session
  #     ignore_dbus_inhibit = false
  #   }
  #
  #   # FIXME memory leak fries computer inbetween dpms off and suspend
  #   #listener {
  #   #  timeout = 150 # in seconds
  #   #  on-timeout = hyprctl dispatch dpms off
  #   #  on-resume = hyprctl dispatch dpms on
  #   #}
  #   listener {
  #     timeout = 165 # in seconds
  #     on-timeout = loginctl lock-session
  #   }
  #   listener {
  #     timeout = 180 # in seconds
  #     #timeout = 5400 # in seconds
  #     on-timeout = systemctl suspend
  #     on-resume = hyprctl dispatch dpms on
  #   }
  # '';
  # home.file.".config/hypr/hyprlock.conf".text = ''
  #   background {
  #     monitor =
  #     path = screenshot
  #
  #     # all these options are taken from hyprland, see https://wiki.hyprland.org/Configuring/Variables/#blur for explanations
  #     blur_passes = 4
  #     blur_size = 5
  #     noise = 0.0117
  #     contrast = 0.8916
  #     brightness = 0.8172
  #     vibrancy = 0.1696
  #     vibrancy_darkness = 0.0
  #   }
  #
  #   # doesn't work yet
  #   image {
  #     monitor =
  #     path = /home/emmet/.dotfiles/user/wm/hyprland/nix-dark.png
  #     size = 150 # lesser side if not 1:1 ratio
  #     rounding = -1 # negative values mean circle
  #     border_size = 0
  #     rotate = 0 # degrees, counter-clockwise
  #
  #     position = 0, 200
  #     halign = center
  #     valign = center
  #   }
  #
  #   input-field {
  #     monitor =
  #     size = 200, 50
  #     outline_thickness = 3
  #     dots_size = 0.33 # Scale of input-field height, 0.2 - 0.8
  #     dots_spacing = 0.15 # Scale of dots' absolute size, 0.0 - 1.0
  #     dots_center = false
  #     dots_rounding = -1 # -1 default circle, -2 follow input-field rounding
  #     outer_color = rgb(''+config.lib.stylix.colors.base07-rgb-r+'',''+config.lib.stylix.colors.base07-rgb-g+'', ''+config.lib.stylix.colors.base07-rgb-b+'')
  #     inner_color = rgb(''+config.lib.stylix.colors.base00-rgb-r+'',''+config.lib.stylix.colors.base00-rgb-g+'', ''+config.lib.stylix.colors.base00-rgb-b+'')
  #     font_color = rgb(''+config.lib.stylix.colors.base07-rgb-r+'',''+config.lib.stylix.colors.base07-rgb-g+'', ''+config.lib.stylix.colors.base07-rgb-b+'')
  #     fade_on_empty = true
  #     fade_timeout = 1000 # Milliseconds before fade_on_empty is triggered.
  #     placeholder_text = <i>Input Password...</i> # Text rendered in the input box when it's empty.
  #     hide_input = false
  #     rounding = -1 # -1 means complete rounding (circle/oval)
  #     check_color = rgb(''+config.lib.stylix.colors.base0A-rgb-r+'',''+config.lib.stylix.colors.base0A-rgb-g+'', ''+config.lib.stylix.colors.base0A-rgb-b+'')
  #     fail_color = rgb(''+config.lib.stylix.colors.base08-rgb-r+'',''+config.lib.stylix.colors.base08-rgb-g+'', ''+config.lib.stylix.colors.base08-rgb-b+'')
  #     fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i> # can be set to empty
  #     fail_transition = 300 # transition time in ms between normal outer_color and fail_color
  #     capslock_color = -1
  #     numlock_color = -1
  #     bothlock_color = -1 # when both locks are active. -1 means don't change outer color (same for above)
  #     invert_numlock = false # change color if numlock is off
  #     swap_font_color = false # see below
  #
  #     position = 0, -20
  #     halign = center
  #     valign = center
  #   }
  #
  #   label {
  #     monitor =
  #     text = Hello, ''+userSettings.name+''
  #     color = rgb(''+config.lib.stylix.colors.base07-rgb-r+'',''+config.lib.stylix.colors.base07-rgb-g+'', ''+config.lib.stylix.colors.base07-rgb-b+'')
  #     font_size = 25
  #     font_family = ''+userSettings.font+''
  #
  #     rotate = 0 # degrees, counter-clockwise
  #
  #     position = 0, 160
  #     halign = center
  #     valign = center
  #   }
  #
  #   label {
  #     monitor =
  #     text = $TIME
  #     color = rgb(''+config.lib.stylix.colors.base07-rgb-r+'',''+config.lib.stylix.colors.base07-rgb-g+'', ''+config.lib.stylix.colors.base07-rgb-b+'')
  #     font_size = 20
  #     font_family = Intel One Mono
  #     rotate = 0 # degrees, counter-clockwise
  #
  #     position = 0, 80
  #     halign = center
  #     valign = center
  #   }
  # '';
  services.swayosd.enable = true;
  services.swayosd.topMargin = 0.5;
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oldAttrs: {
      postPatch = ''
        # use hyprctl to switch workspaces
        sed -i 's/zext_workspace_handle_v1_activate(workspace_handle_);/const std::string command = "hyprctl dispatch focusworkspaceoncurrentmonitor " + std::to_string(id());\n\tsystem(command.c_str());/g' src/modules/wlr/workspace_manager.cpp
        sed -i 's/gIPC->getSocket1Reply("dispatch workspace " + std::to_string(id()));/gIPC->getSocket1Reply("dispatch focusworkspaceoncurrentmonitor " + std::to_string(id()));/g' src/modules/hyprland/workspaces.cpp
      '';
      patches = [./patches/waybarpaupdate.patch ./patches/waybarbatupdate.patch];
    });
  };
  home.file.".config/gtklock/style.css".text = ''
    window {
      background-image: url("''+config.stylix.image+''");
      background-size: auto 100%;
    }
  '';
  home.file.".config/nwg-launchers/nwggrid/style.css".text = ''
    button, label, image {
        background: none;
        border-style: none;
        box-shadow: none;
        color: #'' + config.lib.stylix.colors.base07 + '';

        font-size: 20px;
    }

    button {
        padding: 5px;
        margin: 5px;
        text-shadow: none;
    }

    button:hover {
        background-color: rgba('' + config.lib.stylix.colors.base07-rgb-r + "," + config.lib.stylix.colors.base07-rgb-g + "," + config.lib.stylix.colors.base07-rgb-b + "," + ''0.15);
    }

    button:focus {
        box-shadow: 0 0 10px;
    }

    button:checked {
        background-color: rgba('' + config.lib.stylix.colors.base07-rgb-r + "," + config.lib.stylix.colors.base07-rgb-g + "," + config.lib.stylix.colors.base07-rgb-b + "," + ''0.15);
    }

    #searchbox {
        background: none;
        border-color: #'' + config.lib.stylix.colors.base07 + '';

        color: #'' + config.lib.stylix.colors.base07 + '';

        margin-top: 20px;
        margin-bottom: 20px;

        font-size: 20px;
    }

    #separator {
        background-color: rgba('' + config.lib.stylix.colors.base00-rgb-r + "," + config.lib.stylix.colors.base00-rgb-g + "," + config.lib.stylix.colors.base00-rgb-b + "," + ''0.55);

        color: #'' + config.lib.stylix.colors.base07 + '';
        margin-left: 500px;
        margin-right: 500px;
        margin-top: 10px;
        margin-bottom: 10px
    }

    #description {
        margin-bottom: 20px
    }
  '';
  home.file.".config/nwg-launchers/nwggrid/terminal".text = "alacritty -e";
  home.file.".config/nwg-drawer/drawer.css".text = ''
    window {
        background-color: rgba('' + config.lib.stylix.colors.base00-rgb-r + "," + config.lib.stylix.colors.base00-rgb-g + "," + config.lib.stylix.colors.base00-rgb-b + "," + ''0.55);
        color: #'' + config.lib.stylix.colors.base07 + ''
    }

    /* search entry */
    entry {
        background-color: rgba('' + config.lib.stylix.colors.base01-rgb-r + "," + config.lib.stylix.colors.base01-rgb-g + "," + config.lib.stylix.colors.base01-rgb-b + "," + ''0.45);
    }

    button, image {
        background: none;
        border: none
    }

    button:hover {
        background-color: rgba('' + config.lib.stylix.colors.base02-rgb-r + "," + config.lib.stylix.colors.base02-rgb-g + "," + config.lib.stylix.colors.base02-rgb-b + "," + ''0.45);
    }

    /* in case you wanted to give category buttons a different look */
    #category-button {
        margin: 0 10px 0 10px
    }

    #pinned-box {
        padding-bottom: 5px;
        border-bottom: 1px dotted;
        border-color: #'' + config.lib.stylix.colors.base07 + '';
    }

    #files-box {
        padding: 5px;
        border: 1px dotted gray;
        border-radius: 15px
        border-color: #'' + config.lib.stylix.colors.base07 + '';
    }
  '';
  home.file.".config/libinput-gestures.conf".text = ''
  gesture swipe up 3	hyprctl dispatch hyprexpo:expo toggle
  gesture swipe down 3	nwggrid-wrapper

  gesture swipe right 3	hyprnome
  gesture swipe left 3	hyprnome --previous
  gesture swipe up 4	hyprctl dispatch movewindow u
  gesture swipe down 4	hyprctl dispatch movewindow d
  gesture swipe left 4	hyprctl dispatch movewindow l
  gesture swipe right 4	hyprctl dispatch movewindow r
  gesture pinch in	hyprctl dispatch fullscreen 1
  gesture pinch out	hyprctl dispatch fullscreen 1
  '';

  home.file.".ssh/config".source = ./ssh_config;


  services.udiskie.enable = true;
  services.udiskie.tray = "always";
  programs.fuzzel.enable = true;
  programs.fuzzel.package = pkgs.fuzzel.overrideAttrs (oldAttrs: {
      patches = ./patches/fuzzelmouseinput.patch;
    });
  programs.fuzzel.settings = {
    main = {
      font = userSettings.font + ":size=20";
      dpi-aware = "no";
      show-actions = "yes";
      terminal = "${pkgs.alacritty}/bin/alacritty";
    };
    colors = {
      background = config.lib.stylix.colors.base00 + "bf";
      text = config.lib.stylix.colors.base07 + "ff";
      match = config.lib.stylix.colors.base05 + "ff";
      selection = config.lib.stylix.colors.base08 + "ff";
      selection-text = config.lib.stylix.colors.base00 + "ff";
      selection-match = config.lib.stylix.colors.base05 + "ff";
      border = config.lib.stylix.colors.base08 + "ff";
    };
    border = {
      width = 3;
      radius = 7;
    };
  };
  services.fnott.enable = true;
  services.fnott.settings = {
    main = {
      anchor = "bottom-right";
      stacking-order = "top-down";
      min-width = 400;
      title-font = userSettings.font + ":size=14";
      summary-font = userSettings.font + ":size=12";
      body-font = userSettings.font + ":size=11";
      border-size = 0;
    };
    low = {
      background = config.lib.stylix.colors.base00 + "e6";
      title-color = config.lib.stylix.colors.base03 + "ff";
      summary-color = config.lib.stylix.colors.base03 + "ff";
      body-color = config.lib.stylix.colors.base03 + "ff";
      idle-timeout = 150;
      max-timeout = 30;
      default-timeout = 8;
    };
    normal = {
      background = config.lib.stylix.colors.base00 + "e6";
      title-color = config.lib.stylix.colors.base07 + "ff";
      summary-color = config.lib.stylix.colors.base07 + "ff";
      body-color = config.lib.stylix.colors.base07 + "ff";
      idle-timeout = 150;
      max-timeout = 30;
      default-timeout = 8;
    };
    critical = {
      background = config.lib.stylix.colors.base00 + "e6";
      title-color = config.lib.stylix.colors.base08 + "ff";
      summary-color = config.lib.stylix.colors.base08 + "ff";
      body-color = config.lib.stylix.colors.base08 + "ff";
      idle-timeout = 0;
      max-timeout = 0;
      default-timeout = 0;
    };
  };
}
