alias e="nano "
alias i="sudo apt install "
alias ll="ls -al"

# lists all the SSH hosts defined in the config
alias ssh-hosts="grep -P \"^Host ([^*]+)$\" $HOME/.ssh/config | sed 's/Host //'"
echo aliases loaded