{ config, pkgs, lib, ...  }:
let
  # Import myAliases directly
  myAliases = import ./myAliases.txt;

  # Read the script content from scripts.sh
  scriptContent = builtins.readFile ./scripts.sh;

  # Create a file with the script content
  scriptFile = pkgs.writeText "shell-functions.sh" scriptContent;

  # take each script in dotlocalbin and make it available to nixos
  scriptDir = ./dotlocalbin;
  scriptFiles = builtins.attrNames (builtins.readDir scriptDir);
  nsxiv-fullscreen = pkgs.callPackage ./nsxiv-wrapper.nix {};
  mbsyncExtraConfig = builtins.readFile ./mbsync-config.txt;
in
{
  home.file = lib.genAttrs
    (map (name: ".local/bin/${name}") scriptFiles)
    (name: {
      source = scriptDir + "/${builtins.baseNameOf name}";
      executable = true;
    });

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
  home.sessionVariables = {
    DISABLE_AUTO_TITLE="true";
    SUDO_EDITOR="nvim";
    EDITOR="nvim";
    VISUAL="nvim";
    PDFVIEWER="zathura";
    TERMINAL="kitty";
    TERMINAL_PROG="kitty";
    BROWSER="qutebrowser";
    HISTSIZE=1000000;
    SAVEHIST=1000000;
    SYSTEMD_PAGER="vim";
    FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git";
    FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND";
    FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git";
    FZF_DEFAULT_OPTS="--margin=15% --border=rounded";
    FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'";
    FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'";
    BAT_THEME="tokyonight_night";
  };
  programs.home-manager.enable = true;
  programs.mbsync = {
    enable = true;
    extraConfig = mbsyncExtraConfig;
  };
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    shellAliases = myAliases;
    # ohMyZsh = {
    #     enable = true;
    #     plugins = ["git"];
    #     theme = "xiong-chiamiov-plus";
    # };
    initExtra = ''
       if [ -f "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" ]; then
         . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
       fi
       source ${scriptFile}
       PROMPT=" ◉ %U%F{magenta}%n%f%u@%U%F{blue}%m%f%u:%F{yellow}%~%f %F{green}→%f "
    '';
  };

	    # krabby random --no-mega --no-gmax --no-regional --no-title -s;
     #  source <(fzf --zsh);
	    # HISTFILE=~/.zsh_history;
	    # HISTSIZE=10000;
	    # SAVEHIST=10000;
	    # setopt appendhistory;
     #  source ${scriptFile}
     #  PROMPT=" ◉ %U%F{magenta}%n%f%u@%U%F{blue}%m%f%u:%F{yellow}%~%f
     #   %F{green}→%f "
     #  RPROMPT="%F{red}▂%f%F{yellow}▄%f%F{green}▆%f%F{cyan}█%f%F{blue}▆%f%F{magenta}▄%f%F{white}▂%f"
     #  [ $TERM = "dumb" ] && unsetopt zle && PS1='$ '
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = myAliases;
    initExtra = ''
      if [ -f "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" ]; then
        . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
      fi
      source ${scriptFile}
    '';
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html"=["qutebrowser-hyprprofile.desktop"];
      "x-scheme-handler/http"=["qutebrowser-hyprprofile.desktop"];
      "x-scheme-handler/https"=["qutebrowser-hyprprofile.desktop"];
      "x-scheme-handler/about"=["qutebrowser-hyprprofile.desktop"];
      "x-scheme-handler/unknown"=["qutebrowser-hyprprofile.desktop"];
      "text/x-shellscript"=["nvim.desktop"];
      "text/x-script.python"=["nvim.desktop"];
      "application/pdf"=["org.pwmt.zathura-pdf-mupdf.desktop"];
      "application/epub+zip"=["org.pwmt.zathura-pdf-mupdf.desktop"];
      "image/jpeg"=["nsxiv-fullscreen.desktop"];
      "image/png"=["nsxiv-fullscreen.desktop"];
      "text/plain" = ["nvim.desktop"];
      "text/markdown" = ["nvim.desktop"];
      "text/x-python" = ["nvim.desktop"];
      # Add more text-based MIME types as needed
    };
  };
  xdg.desktopEntries.nsxiv-fullscreen = {
    name = "NSXIV Fullscreen";
    genericName = "Image Viewer";
    exec = "${nsxiv-fullscreen}/bin/nsxiv-fullscreen %F";
    icon = "nsxiv";
    terminal = false;
    categories = [ "Graphics" "Viewer" ];
    mimeType = [ "image/bmp" "image/gif" "image/jpeg" "image/jpg" "image/png" "image/tiff" "image/x-bmp" "image/x-portable-anymap" "image/x-portable-bitmap" "image/x-portable-graymap" "image/x-tga" "image/x-xpixmap" ];
  };
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    comment = "Edit text files";
    exec = "nvim %F";
    icon = "nvim";
    mimeType = [
      "text/english"
      "text/x-makefile"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-java"
      "text/x-moc"
      "text/x-pascal"
      "text/x-tcl"
      "text/x-tex"
      "application/x-shellscript"
      "text/x-c"
      "text/x-c++"
      "text/plain"
      "text/x-markdown"
      "text/x-python"
      # Add more MIME types as needed
    ];
    categories = [ "Utility" "TextEditor" ];
    terminal = true;
    type = "Application";
  };
  home.packages = with pkgs; [
    disfetch lolcat cowsay onefetch
    krabby
    fzf
    yt-dlp
    nsxiv
    nsxiv-fullscreen
    gnugrep gnused
    bat eza bottom fd bc
    direnv nix-direnv
  ];

  programs.zoxide.enable = true;

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;
}
