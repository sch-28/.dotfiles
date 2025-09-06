## needed programs
```
sudo pacman -S bob zsh tmux zoxide kitty stow ly polybar rofi kmonad
```

## stow
```
sudo rm -rf /etc/ly/config.ini
sudo sh stow-all.sh
```

## setup ly
```
sudo systemctl stop lightdm
sudo systemctl disable lightdm
sudo systemctl enable ly
```


## adjust sudo settings
```
sudo visudo
```

## install ohmyzsh & adjust shell
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s $(which zsh)
```

## wlan 
```
systemctl status NetworkManager
nmcli device wifi list
sudo nmcli device wifi connect "NAME" password "PASSWORD"
```
