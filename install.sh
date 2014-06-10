#!/bin/bash
#
# dotfiels install script for Mac & Ubuntu
# (Not tested yet for Ubuntu)

set -e

DOTDIR=$HOME/.dotfiles

test -e /etc/*-rel-* &> /dev/null && OS="Ubuntu"
if [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ]; then
  install='sudo apt-get -y install'
  remove='sudo apt-get purge --auto-remove'
fi

OS=$(uname -s)
if [ "$OS" = "Darwin" ]; then
  install='brew install'
  remove='brew uninstall'
  unlink='brew unlink'
  link='brew link --overwrite'
fi

echo "Detected OS: $OS"

function install_brew {
  echo "Installing Homebrew..."

  if [ -f /usr/local/bin/brew ]; then
    echo "Homebrew already installed"
    brew update
    brew doctor

 else
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

    brew update
    brew doctor

    if [ ! -f $HOME/.bash_profile ]; then
      touch $HOME/.bash_profile
    fi

    echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile
    source $HOME/.bash_profile
  fi
}

function remove_brew {
  cd `brew --prefix`
  rm -rf Cellar
  brew prune
  rm `git ls-files`
  rm -r Library/Homebrew Library/Aliases Library/Formula Library/Contributions
  rm -rf .git
  rm -rf ~/Library/Caches/Homebrew
  rm -rf ~/Library/Logs/Homebrew
  rm -rf /Library/Caches/Homebrew
}

function install_python {
  echo "Installing python..."

  if [ "$OS" = "Darwin" ]; then

    if [ ! -f /usr/local/bin/cmake ]; then
      $install cmake
    fi

    if [ ! -f /usr/local/bin/python ]; then
      $install python
      $link python
    fi

    if [ ! -f /usr/local/lib/libgit2.dylib ]; then
      $install libgit2
    fi

  elif [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ]; then

	# TODO: Not tested
    if [ ! -f /usr/bin/cmake ]; then
      $install cmake
    fi

    if [ ! -f /usr/bin/python ]; then
      $install python
    fi

    if [ ! -f /usr/lib/libgit2.so ]; then
      $install libgit2
    fi

  fi

  echo "Installing python packages for powerline"
  export CFLAGS=-Qunused-arguments
  export CPPFLAGS=-Qunused-arguments
  sudo easy_install pip
  sudo pip install -U setuptools
  pip install pygit2
  pip install psutil

  echo "Create symbolic link: /usr/local/lib/python2.7/config"
  LATEST_VER=$(ls -1 '/usr/local/Cellar/python' | xargs -n1 | sort -n | tail -1)
  ln -s /usr/local/Cellar/python/$LATEST_VER/Frameworks/Python.framework/Versions/Current/lib/python2.7/config /usr/local/lib/python2.7/config
}

function install_zsh {
  echo "Installing zsh..."

  if [ -d $HOME/.oh-my-zsh ]; then
    echo "Delete oh-my-zsh..."
    rm -rf $HOME/.oh-my-zsh
  fi

  echo "Backup .z* files..."
  BAKDIR=$HOME/.backup/$(date +%m%d-%H%M)
  mkdir -p $BAKDIR
  pushd $HOME >> /dev/null
  ls -1a | grep "^.z[a-z_]*" | xargs -I {} bash -c 'mv $HOME/"{}" '${BAKDIR}
  popd >> /dev/null

  if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    if [ ! -d $HOME/.zprezto ]; then
      echo "Installing prezto..."
      git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

      pushd $HOME/.zprezto/runcoms >> /dev/null
      ls -1 | xargs -n1 | sort -n | tail -6 | xargs -I {} ln -s `pwd`/{} $HOME/.{}
      echo "Created prezto symbolic links"
      popd >> /dev/null
    fi
 else
    $install zsh
    if [ ! '$(echo $SHELL)' = '$(which zsh)' ]; then
      chsh -s $(which zsh)
    fi
    install_zsh
  fi
}

function install_tmux {
  echo "Installing tmux..."
  if [ "$OS" = "Darwin" ]; then
    if [ ! -f /usr/bin/local/tmux ]; then
      $install tmux
      $install reattach-to-user-namespace
    fi
  elif [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ]; then
    if [ ! -f /usr/bin/tmux ]; then
      $install tmux
    fi
  fi
}

function install_vim {
  echo "Installing vim and ctags..."
  if [ "$OS" = "Darwin" ]; then
    $install vim -env-std --override-system-vim

    if [ ! -f /usr/bin/local/ctags ]; then
      $install ctags
    fi
  elif [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ]; then
    $install vim

    if [ ! -f /usr/bin/ctags ]; then
      $install ctags
    fi
  fi

  echo "Installing janus..."
  if [ ! -f $HOME/.vim ]; then
    BAKDIR=$HOME/.backup/$(date +%m%d-%H%M)
    mv $HOME/.vim $BAKDIR
  fi
  if [ ! -f $HOME/.vim/janus ]; then
    curl -Lo- https://bit.ly/janus-bootstrap | bash
  fi
}

function install_powerline {
  echo "Installing powerline..."
  pip install git+git://github.com/Lokaltog/powerline
}

function install_dotfiles {
  echo "Installing dotfiles..."

  pushd $HOME >> /dev/null
  echo "ln -sf $DOTDIR/janus $HOME/.janus"
  ln -sf $DOTDIR/janus $HOME/.janus

  dotfiles=('.ctags' '.tmux.conf' '.vimrc.before' '.vimrc.after' '.zpreztorc')
  for file in "${dotfiles[@]}"; do
    echo ln -sf $DOTDIR/$file
    ln -sf $DOTDIR/$file
  done
  popd >> /dev/null

  echo "Installing zprezto theme..."
  ln -sf $DOTDIR/prompt_superlinh_setup $HOME/.zprezto/modules/prompt/functions
}

function all {
  echo "Installing all packages except brew..."

  install_dotfiles
  install_zsh
  install_python
  install_vim
  install_tmux
  install_powerline
}

function usage {
  printf '\nUsage: %s [-abdlptz]\n\n' $(basename $0) >&2
  printf 'options:\n' >&2
  printf -- ' -a: (default) install (A)ll packages except brew\n' >&2
  printf -- ' -b: install (B)rew\n' >&2
  printf -- ' -d: install (D)ot files\n' >&2
  printf -- ' -l: install Power(L)ine\n' >&2
  printf -- ' -p: install (P)ython\n' >&2
  printf -- ' -r: (R)emove brew\n' >&2
  printf -- ' -t: install (T)mux\n' >&2
  printf -- ' -v: install (V)im\n' >&2
  printf -- ' -z: install (Z)sh\n' >&2
}

if [ $# -eq 0 ]; then
  all
else
  while getopts 'abdlprtvz' OPTION; do
    case $OPTION in
      a)    all;;
      b)    install_brew;;
      d)    install_dotfiles;;
      l)    install_powerline;;
      p)    install_python;;
      r)    remove_brew;;
      t)    install_tmux;;
      v)    install_vim;;
      z)    install_zsh;;
      ?)    usage;;
    esac
  done
  shift $(($OPTIND - 1))
fi
