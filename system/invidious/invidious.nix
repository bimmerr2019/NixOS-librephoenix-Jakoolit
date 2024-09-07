{ config, lib, pkgs, ... }:

let
  invidious-update-script = pkgs.writeShellScript "update-invidious" ''
    set -e
    REPO_PATH="/home/invidious/invidious"
    if [ ! -d "$REPO_PATH" ]; then
      ${pkgs.git}/bin/git clone https://github.com/iv-org/invidious "$REPO_PATH"
    else
      cd "$REPO_PATH"
      ${pkgs.git}/bin/git pull
    fi
    chown -R invidious:users "$REPO_PATH"
  '';
in
{
  # Add the required packages
  environment.systemPackages = with pkgs; [
    crystal
    shards
    gnumake
    gcc
    binutils
    librsvg
    postgresql
    open-sans
    git
    # Add these new packages
    sqlite
    sqlite.dev
    pkg-config
    openssl
    zlib
    libevent
    libyaml
    pcre2
  ];

  # Create the invidious user
  users.users.invidious = {
    isNormalUser = true;
    home = "/home/invidious";
    description = "Invidious user";
    extraGroups = [ "users" "wheel" "networkmanager" "docker" ];
    shell = pkgs.bash;
    uid = 1001;  # Specify a UID to ensure consistency
  };

  # Use systemd to run the script after user creation
  systemd.services.setup-invidious = {
    description = "Setup Invidious repository";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "users.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "invidious";
      ExecStart = "${invidious-update-script}";
    };
  };

  # Enable PostgreSQL service
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;  # Or whichever version you prefer
    enableTCPIP = true;
  };

  # Ensure the PostgreSQL service starts on boot
  systemd.services.postgresql.wantedBy = [ "multi-user.target" ];

  # Add this to make sure development libraries are available
  environment.variables = {
    PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
    NIX_LDFLAGS = "-L${pkgs.sqlite.out}/lib -L${pkgs.sqlite.dev}/lib";
  };

  # Modify the existing sessionVariables to append to LD_LIBRARY_PATH
  environment.sessionVariables = {
    LD_LIBRARY_PATH = lib.mkForce (lib.concatStringsSep ":" [
      "${pkgs.sqlite.out}/lib"
      "${pkgs.sqlite.dev}/lib"
      "${pkgs.openssl.out}/lib"
      "${pkgs.zlib.out}/lib"
      "${pkgs.libevent.out}/lib"
      "${pkgs.libyaml.out}/lib"
      "${pkgs.libxml2.out}/lib"
      "$LD_LIBRARY_PATH"
    ]);
  };
}
