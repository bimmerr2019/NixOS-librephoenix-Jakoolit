# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, systemSettings, userSettings, ... }:
{
  imports =
    [ ../../system/hardware-configuration.nix
      ../../system/hardware/systemd.nix # systemd config
      ../../system/hardware/kernel.nix # Kernel config
      ../../system/hardware/power.nix # Power management
      ../../system/hardware/time.nix # Network time sync
      ../../system/hardware/opengl.nix
      ../../system/hardware/printing.nix
      ../../system/hardware/bluetooth.nix
      ../../system/hardware/nvidia-drivers.nix
      ../../system/hardware/nvidia-prime-drivers.nix
      (./. + "../../../system/wm"+("/"+userSettings.wm)+".nix") # My window manager
      #../../system/app/flatpak.nix
      ../../system/app/virtualization.nix
      ( import ../../system/app/docker.nix {storageDriver = null; inherit pkgs userSettings lib;} )
      #../../system/security/doas.nix
      ../../system/security/gpg.nix
      ../../system/security/blocklist.nix
      ../../system/security/firewall.nix
      ../../system/security/firejail.nix
      ../../system/security/openvpn.nix
      ../../system/security/automount.nix
      ../../system/style/stylix.nix
      # Uncomment the line below to install Invidious (also set the enable flag to true below)
      # ../../system/invidious/invidious.nix
      
      # Uncomment the line below to remove Invidious  (also set the enable flag to false below)
      # ../../system/invidious/invidious_rm.nix
    ];

  # Enable ollama
  services.ollama = {
     enable = true;
     port = 11434;
  };
  # Enable Invidious
  services.invidious = {
     enable = true;
     port = 3000;
  };
  services.invidious.settings = lib.mkForce {
    check_tables = true;
    db = {
      dbname = "invidious";
      host = "";
      password = "";
      port = 3000;
      user = "invidious";
    };
    host_binding = "0.0.0.0";
    default_user_preferences = {
      locale = "en-US";
      region = "US";
    };
    captions = [
      "English"
      "English (auto-generated)"
    ];
  };

  # Fix nix path
  nix.nixPath = [ "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
                  "nixos-config=$HOME/dotfiles/system/configuration.nix"
                  "/nix/var/nix/profiles/per-user/root/channels"
                ];

  # Ensure nix flakes are enabled
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # wheel group gets trusted access to nix daemon
  nix.settings.trusted-users = [ "@wheel" ];

  # I'm sorry Stallman-taichou
  nixpkgs.config.allowUnfree = true;

  # Kernel modules
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" "cpufreq_powersave" ];

  # Bootloader
  # Use systemd-boot if uefi, default to grub otherwise
  boot.loader.systemd-boot.enable = if (systemSettings.bootMode == "uefi") then true else false;
  boot.loader.efi.canTouchEfiVariables = if (systemSettings.bootMode == "uefi") then true else false;
  boot.loader.efi.efiSysMountPoint = systemSettings.bootMountPath; # does nothing if running bios rather than uefi
  boot.loader.grub.enable = if (systemSettings.bootMode == "uefi") then false else true;
  boot.loader.grub.device = systemSettings.grubDevice; # does nothing if running uefi rather than bios

  # Networking
  networking.hostName = systemSettings.hostname; # Define your hostname.
  networking.networkmanager.enable = true; # Use networkmanager

#Put appImages in the /opt diretory:
  # Create /opt/appimages directory
  system.activationScripts = {
    createAppImageDir = ''
      mkdir -p /opt/appimages
      chown root:users /opt/appimages
      chmod 775 /opt/appimages
    '';
  };

  # Timezone and locale
  time.timeZone = systemSettings.timezone; # time zone
  i18n.defaultLocale = systemSettings.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.locale;
    LC_IDENTIFICATION = systemSettings.locale;
    LC_MEASUREMENT = systemSettings.locale;
    LC_MONETARY = systemSettings.locale;
    LC_NAME = systemSettings.locale;
    LC_NUMERIC = systemSettings.locale;
    LC_PAPER = systemSettings.locale;
    LC_TELEPHONE = systemSettings.locale;
    LC_TIME = systemSettings.locale;
  };

  # User account
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [ "networkmanager" "wheel" "input" "dialout" ];
    packages = [];
    uid = 1000;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    neovim
    wget
    git
    openssl #required by Rainbow borders
    cryptsetup
    home-manager
    wpa_supplicant
    # Yubikey
    gnupg
    yubikey-personalization
    yubikey-manager
    pcsclite
    pcsctools
    (pkgs.writeScriptBin "comma" ''
      if [ "$#" = 0 ]; then
        echo "usage: comma PKGNAME... [EXECUTABLE]";
      elif [ "$#" = 1 ]; then
        nix-shell -p $1 --run $1;
      elif [ "$#" = 2 ]; then
        nix-shell -p $1 --run $2;
      else
        echo "error: too many arguments";
        echo "usage: comma PKGNAME... [EXECUTABLE]";
      fi
    '')
  # Optionally, add a convenient way to run AppImages
    (writeShellScriptBin "run-appimage" ''
      ${appimage-run}/bin/appimage-run /opt/appimages/$1
    '')
  # Add a desktop file for each appimage here:
    (makeDesktopItem {
      name = "LMStudio";
      desktopName = "LM Studio";
      exec = "${pkgs.appimage-run}/bin/appimage-run /opt/appimages/LM_Studio-0.3.2.AppImage";
      icon = ""; # Leave empty if there's no icon
      comment = "LM Studio Application";
      categories = [ "Utility" ];
      terminal = false;
    })
    (makeDesktopItem {
      name = "Logseq";
      desktopName = "Logseq";
      exec = "${pkgs.appimage-run}/bin/appimage-run /opt/appimages/Logseq-linux-x64-0.10.9.AppImage";
      icon = ""; # Leave empty if there's no icon
      comment = "Logseq Application";
      categories = [ "Utility" ];
      terminal = false;
    })

  ];

  #touch yubikey for sudo
  security.pam.services.sudo = {
    u2fAuth = true;
  };

  # I use zsh btw
  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
  };

  #yubikey stuff:
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  fonts.fontDir.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # It is ok to leave this unchanged for compatibility purposes
  system.stateVersion = "22.11";

}
