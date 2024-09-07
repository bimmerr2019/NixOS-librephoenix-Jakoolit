{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    kitty
  ];
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = lib.mkForce "0.85";
      modify_font = "cell_width 90%";
    };
    extraConfig = ''
      map alt+u open_url_with_hints
    '';
  };
}
