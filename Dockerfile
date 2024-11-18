FROM ubuntu:latest AS dependencies
RUN apt update
RUN apt install -y gpp
RUN apt install -y git
RUN apt install -y gnuplot
RUN apt install -y clang-tools
RUN apt install -y wget
RUN apt install -y nload
RUN apt install -y RUN apt install -y locales
RUN apt install -y bat
RUN apt install -y htop
RUN apt install -y neovim
RUN apt install -y inkscape
RUN apt install -y wine
RUN apt install -y ca-certificates
RUN apt install -y eza
RUN apt install -y whois
RUN apt install -y fzf
RUN apt install -y zoxide
RUN apt install -y gcc
RUN apt install -y tree-sitter-cli
RUN apt install -y software-properties-common
RUN apt install -y curl
RUN apt install -y nmap
RUN apt install -y neofetch
RUN apt install -y rustup
RUN apt install -y ripgrep
RUN apt install -y apt-transport-https 
RUN apt install -y lsb-release
RUN apt install zsh -y
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
RUN	git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
RUN apt install -y nodejs
RUN apt install -y npm
RUN apt install -y openjdk-17-jdk
RUN apt install -y shellcheck
RUN apt-get update -y
RUN apt-get install -y dotnet-sdk-8.0
RUN apt-get install -y aspnetcore-runtime-8.0
RUN apt install -y golang-go
RUN apt install -y zip
RUN apt install -y unzip
RUN apt install -y python3-pip
RUN apt install -y python3-venv 
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN python3 -m venv mytest_env
RUN apt install -y byobu

FROM dependencies AS nvim-deps
COPY . /root/dots
ENV XDG_CONFIG_HOME=/root/dots
RUN nvim --headless "+Lazy! sync" +qa
RUN nvim --headless "+MasonInstallAll" +qa



FROM nvim-deps AS final
ENV XDG_CONFIG_HOME=/root/dots
ENV SHELL=/bin/zsh
WORKDIR /root
RUN rm -f /root/.zshrc
RUN ln -sf /root/dots/.config/.zshrc /root/.zshrc 
RUN chsh -s $(which zsh)
RUN mkdir -p /root/.byobu
RUN ln -sf /root/dots/.config/.tmux.conf /root/.byobu/.tmux.conf


CMD ["/bin/zsh"]
