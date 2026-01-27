{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.python;
in
{
  options.my.home.python.enable = mkEnableOption "Enable python config";
  config = mkIf cfg.enable {
    programs = {
      pyenv.enable = true;
      uv.enable = true;
      direnv.stdlib = ''
        layout_uv() {
            VIRTUAL_ENV="''${VIRTUAL_ENV:=$(pwd)/.venv}"

            if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
                log_status "No uv project exists. Executing \`uv init\` to create one."
                if [ ! -f "$PWD/pyproject.toml" ]; then
                    uv init --no-readme
                    rm hello.py
                fi
                uv venv
                VIRTUAL_ENV="$(pwd)/.venv"
            fi

            PATH_add "$VIRTUAL_ENV/bin"
            export UV_ACTIVE=1  # or VENV_ACTIVE=1
            export VIRTUAL_ENV
        }
      '';
    };
  };
}
