final: prev: {
  tmuxPlugins = prev.tmuxPlugins // {
    sensible = prev.tmuxPlugins.sensible.overrideAttrs (prev: {
      postInstall =
        (prev.postInstall or "")
        + ''
          sed -e 's|\$SHELL|${final.bashInteractive}/bin/bash|g' -i $target/sensible.tmux
        '';
    });
  };
}
