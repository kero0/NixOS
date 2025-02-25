{
  programs.zsh.initExtra = ''
    export PATH=$HOME/.nix-profile/bin:$PATH
    if [ -d "$HOME/platform-tools" ] ; then
        export PATH="$HOME/platform-tools:$PATH"
    fi

    if [ -d "$HOME/.local/bin" ] ; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    if [ -d "$HOME/.local/bin" ] ; then
        export PATH="/snap/bin:$PATH"
    fi

    if [ -d "$HOME/Android/Sdk" ] ; then
        export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
    fi

    if [ -d "$HOME/.config/.android" ] ; then
        export ANDROID_SDK_HOME="$HOME/.config/.android"
        export ANDROID_AVD_HOME="$ANDROID_SDK_HOME/avd"
    fi

    if which ccache > /dev/null ; then
        export USE_CCACHE=1
        export CCACHE_EXEC=$(command -v ccache)
        export CCACHE_DIR=/mnt/ccache
    fi

    [ "$TERM" = "xterm-kitty" ] && export TERM="xterm-256color"
  '';
}
