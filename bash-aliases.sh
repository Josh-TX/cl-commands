alias e="nano "
alias i="sudo apt install "
alias ll="ls -al"
alias s="sudo"
alias ss="sudo systemctl"
alias ipv4="ip a | grep -Eo 192\.168\.[0-9]+\.[0-9]+\/"

# lists all the SSH hosts defined in the config
alias ssh-hosts="grep -P \"^Host ([^*]+)$\" $HOME/.ssh/config | sed 's/Host //'"

# lists users with id > 1000
alias u="{ echo -e 'user name:password:user Id:group id:shell'; getent passwd | awk -F : \"\\\$3 >= 1000 && \\\$1 != \\\"nobody\\\" {print}\" | cut -d : -f 5-6 --complement; }  | column -t -s ':'"

# lists groups with id > 1000
alias g="{ echo -e 'group name:group Id:secondary group members'; getent group | awk -F : \"\\\$3 >= 1000 && \\\$1 != \\\"nogroup\\\" {print}\" | cut -d : -f 2 --complement; }  | column -t -s ':'"