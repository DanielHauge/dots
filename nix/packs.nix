{ pkgs, ... }:
{
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
    dotnet-sdk
    dotnet-runtime
    dotnet-sdk_7
    dotnet-runtime_7
    glow
    pandoc
    cmake
    git-cliff
    rustup
    cargo-nextest
    zplug
    zsh-autosuggestions
    zsh-autocomplete
    clip
    # Add more packages as needed
  ];
  programs.zsh = {
      enable = true;
      enableCompletion = true;
      interactiveShellInit = "source ~/dots/bash/.bashrc";
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases.update = "sudo nixos-rebuild switch";
      ohMyZsh = {
        enable = true;
        plugins = [  ];
        theme = "bira";
      };
  };
  users.defaultUserShell = pkgs.zsh;
}