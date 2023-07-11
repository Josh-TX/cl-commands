wget -q https://github.com/Josh-TX/cl-commands/raw/main/scripts/bash-aliases.sh -O ~/.bash_aliases; source ~/.bash_aliases
wget -q https://github.com/Josh-TX/cl-commands/raw/main/scripts/bash-prompt.sh -O ~/.bash_prompt; source ~/.bash_prompt
echo $'source ~/.bash_aliases\nsource ~/.bash_prompt' > ~/.bash_profile