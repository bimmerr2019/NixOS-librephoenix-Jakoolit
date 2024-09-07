{ config, pkgs, lib, ...  }:
{
  home.sessionPath = [
    "$HOME/go/bin"
  ];
  home.activation = {
    installOrUpdateHnText = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -f "$HOME/go/bin/hn-text" ]; then
        echo "Updating hn-text..."
      else
        echo "Installing hn-text for the first time..."
      fi
      ${pkgs.go}/bin/go install github.com/piqoni/hn-text@latest
    '';
  };
}
