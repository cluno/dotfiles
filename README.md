Requirements
---------
#### brew
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    
#### brew conf
    echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile
    brew doctor
    
#### brew bundle (coreutils, tmux, vim, zsh & etc)
    cd ~/.dotfiles
    brew bundle brewfile 

#### python
    sudo easy_install pip
    pip install pygit2
    pip install psutil
    
    ln -s /usr/local/Cellar/python/2.7.7_1/Frameworks/Python.framework/Versions/Current/lib/python2.7/config /usr/local/lib/python2.7/config

#### prezto for zsh
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
        ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done
    chsh -s /bin/zsh
    
#### janus for vim
    curl -Lo- https://bit.ly/janus-bootstrap | bash
     
dotfiles
-------
#### checkout
    git clone --recursive git@github.com:cluno/dotfiles.git ~/.dotfiles

#### symbolic links    
    ln -s ~/.dotfiles/janus ~/.janus
    ln -s ~/.dotfiles/.vimrc.after ~/.vimrc.after
    ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
    ln -s ~/.dotfiles/.ctags ~/.ctags
    ln -s ~/.dotfiles/.zpreztorc ~/.zpreztorc
    
Theme
-----
#### powerline
    pip install git+git://github.com/Lokaltog/powerline

#### tmux
    echo source /usr/local/lib/python2.7/site-packages/powerline/bindings/tmux.conf >> ~/.tmux.conf 

#### prezto
    cd ~/.zprezto/module/prompt/function
    ln -s ~/.dotfiles/prompt_superlinh_setup
    
#### vim
use vim-airline in ~/.janus