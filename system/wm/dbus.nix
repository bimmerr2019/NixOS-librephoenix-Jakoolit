{ pkgs, ... }:

{
  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf pkgs.gnome.gnome-keyring ];
  };

  programs.dconf = {
    enable = true;
  };
}
