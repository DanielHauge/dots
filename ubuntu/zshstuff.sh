echo 'deb <http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-autosuggestions/xUbuntu_22.04/> /' | sudo tee /etc/apt/sources.list.d/shells:zsh-users:zsh-autosuggestions.list
curl -fsSL <https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/xUbuntu_22.04/Release.key> | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_zsh-users_zsh-autosuggestions.gpg > /dev/null
echo 'deb <http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/xUbuntu_22.04/> /' | sudo tee /etc/apt/sources.list.d/shells:zsh-users:zsh-syntax-highlighting.list
curl -fsSL <https://download.opensuse.org/repositories/shells:zsh-users:zsh-syntax-highlighting/xUbuntu_22.04/Release.key> | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_zsh-users_zsh-syntax-highlighting.gpg > /dev/null
sudo apt update
sudo apt install zsh-syntax-highlighting
sudo apt install zsh-autosuggestions
apt install zsh
