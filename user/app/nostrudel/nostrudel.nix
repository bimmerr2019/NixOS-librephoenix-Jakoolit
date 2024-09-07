{ config, pkgs, lib, ...  }:
{
  home.activation = {
    setupOrUpdateNostrudel = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -d "$HOME/nostrudel" ]; then
        echo "Updating existing nostrudel installation..."
        cd "$HOME/nostrudel"
        ${pkgs.git}/bin/git pull https://github.com/hzrd149/nostrudel.git
      else
        echo "Setting up nostrudel for the first time..."
        ${pkgs.git}/bin/git clone https://github.com/hzrd149/nostrudel.git "$HOME/nostrudel"
      fi
      cd "$HOME/nostrudel" && ${pkgs.yarn}/bin/yarn install
    '';
  };
}
