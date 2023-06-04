alias e="nano "
alias i="sudo apt install "
alias ll="ls -al"
alias s="sudo"
alias ss="sudo systemctl"
alias ipv4="ip a | grep -Eo 192\.168\.[0-9]+\.[0-9]+\/"

# lists all the SSH hosts defined in the config
alias ssh-hosts="grep -P \"^Host ([^*]+)$\" $HOME/.ssh/config | sed 's/Host //'"