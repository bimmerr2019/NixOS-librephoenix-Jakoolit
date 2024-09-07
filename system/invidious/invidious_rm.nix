{ config, pkgs, lib, ... }:

{
  # Disable the PostgreSQL service
  services.postgresql.enable = lib.mkForce false;

  # Disable the Invidious service
  systemd.services.invidious.enable = lib.mkForce false;

  # Clean up script
  system.activationScripts.cleanupInvidious = lib.mkForce ''
    # Stop the Invidious service if it's running
    systemctl stop invidious.service || true

    # Remove the Invidious directory
    rm -rf /home/invidious

    # Remove the PostgreSQL database and user
    if [ -d /var/lib/postgresql ]; then
      if sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='invidious'" | grep -q 1; then
        sudo -u postgres psql -c 'DROP DATABASE invidious;'
      fi
      if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='kemal'" | grep -q 1; then
        sudo -u postgres psql -c 'DROP USER kemal;'
      fi
    fi

    # Remove PostgreSQL data directory
    rm -rf /var/lib/postgresql

    # Remove log file
    rm -f /var/log/invidious.log

    # Remove the invidious user and group
    userdel invidious 2>/dev/null || true
    groupdel invidious 2>/dev/null || true
  '';
}
