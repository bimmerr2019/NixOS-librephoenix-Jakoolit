{ pkgs, ... }:
let
  # Import myAliases directly
  myAliases = import ./myAliases.txt;

  # Read the script content from scripts.sh
  scriptContent = builtins.readFile ./scripts.sh;

  # Create a file with the script content
  scriptFile = pkgs.writeText "shell-functions.sh" scriptContent;
in
{
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
      source ${scriptFile}
    '';
  };

  home.packages = with pkgs; [
    disfetch lolcat cowsay onefetch
    krabby
    fzf
    yt-dlp
    gnugrep gnused
    bat eza bottom fd bc
    direnv nix-direnv
  ];

  programs.zoxide.enable = true;

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;
}
