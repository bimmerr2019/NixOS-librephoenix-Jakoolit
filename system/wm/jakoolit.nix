{ inputs, pkgs, userSettings, lib, ... }: 
let
  pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  username = userSettings.username; # Replace with your actual username
in
{
  # Import wayland config
  imports = [ ./wayland.nix
              ./pipewire.nix
              ./dbus.nix
            ];

  # Security
  security = {
    pam.services.login.enableGnomeKeyring = true;
    pam.services.sddm.enableGnomeKeyring = true;
  };

  services.gnome.gnome-keyring.enable = true;

  programs = {
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland = {
        enable = true;
      };
      portalPackage = pkgs-hyprland.xdg-desktop-portal-hyprland;
    };
  };

  environment = {
    plasma5.excludePackages = [ pkgs.kdePackages.systemsettings ];
    plasma6.excludePackages = [ pkgs.kdePackages.systemsettings ];
  };

  services.xserver.excludePackages = [ pkgs.xterm ];
  system.activationScripts = {
    sddm-face = ''
      mkdir -p /usr/share/sddm/faces/
      cp ${../../rickie.png} /usr/share/sddm/faces/${username}.face.icon
      chmod 644 /usr/share/sddm/faces/${username}.face.icon
      chown root:root /usr/share/sddm/faces/${username}.face.icon
    '';
  };

  services.xserver = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      enableHidpi = true;
      theme = "chili";
      package = pkgs.sddm;
      settings = {
        Theme = {
          FacesDir = "/usr/share/sddm/faces";
        };
      };
    };
  };

  # Ensure the directories exist
  environment.systemPackages = [ pkgs.coreutils ];
}
