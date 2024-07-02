{ config, pkgs, ... }:
{
  environment.variables.EDITOR = "nvim";
  environment.systemPackages = with pkgs; [
    # List of user-specific packages
    neovim
    git
    gcc
    bat
    ripgrep-all
    ripgrep
    fzf
    zoxide
    khal
    difftastic
    python3
    unzip
    nmap
    whois
    tree-sitter
    fd
    gnuplot
    gnumake
    llvm
    dart
    flutter
    ffmpeg
    wget
    docker
    jq
    go
    nodejs
    ruff
    jdk
    csharp-ls
    fsautocomplete
    dotnet-sdk_8
    dotnet-runtime_8
    dotnet-sdk_7
    dotnet-runtime_7
    glow
    pandoc
    cmake
    git-cliff
    rustup
    rust-analyzer
    cargo-nextest
    # zplug
    # zsh-autosuggestions
    # zsh-autocomplete
    # zsh-completions
    # nix-zsh-completions
    clip
    # Add more packages as needed
  ];
  programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;

      # interactiveShellInit = "source ~/dots/bash/.bashrc";
      shellInit = "source ~/dots/bash/.bashrc;";
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases.update = "sudo nixos-rebuild switch";
      ohMyZsh = {
        enable = true;
        # https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
        plugins = [ "dotnet" "colored-man-pages" "extract" "golang" "command-not-found" ];
        theme = "bira";
      };
  };
  users.defaultUserShell = pkgs.zsh;
}
