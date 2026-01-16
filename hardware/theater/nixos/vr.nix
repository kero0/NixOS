{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
  services.monado = {
    enable = true;
    defaultRuntime = true;
  };
  environment.systemPackages = with pkgs; [
    basalt-monado
    monado-vulkan-layers
    opencomposite
    wayvr
    xrizer
  ];
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    WMR_HANDTRACKING = "0";
    VIT_SYSTEM_LIBRARY_PATH = "${pkgs.basalt-monado}/lib/libbasalt.so";
    # Enable debugging if needed
    XRT_DEBUG_GUI = "0";
  };
  services.monado.package =
    with pkgs;
    monado.overrideAttrs (
      finalAttrs: previousAttrs: {
        src = fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "thaytan";
          repo = "monado";
          rev = "dev-constellation-controller-tracking";
          hash = "sha256-KB+LNwmnlXQAS1vRUy9eLn/ECkPNePUmoFW0O2obYno=";
        };

        patches = [ ];
      }
    );
  boot.kernelPatches = [
    {
      name = "amdgpu-ignore-ctx-privileges";
      patch = pkgs.fetchpatch {
        name = "cap_sys_nice_begone.patch";
        url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
        hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
      };
    }
  ];
}
