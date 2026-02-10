{
  pkgs,
  config,
  osConfig,
  ...
}:
{
  home.sessionVariables = {
    PRESSURE_VESSEL_FILESYSTEMS_RW =
      # trying to construct $XDG_RUNTIME_DIR at compile time
      "/run/user/1000/monado_comp_ipc";
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    WMR_HANDTRACKING = "0";
    VIT_SYSTEM_LIBRARY_PATH = "${pkgs.basalt-monado}/lib/libbasalt.so";
    # Enable debugging if needed
    XRT_DEBUG_GUI = "0";
  };
  xdg = {
    configFile = {
      "openxr/1/active_runtime.json".source =
        "${osConfig.services.monado.package}/share/openxr/1/openxr_monado.json";
      "openvr/openvrpaths.vrpath".text = ''
        {
          "config" :
          [
            "${config.xdg.dataHome}/Steam/config"
          ],
          "external_drivers" : null,
          "jsonid" : "vrpathreg",
          "log" :
          [
            "${config.xdg.dataHome}/Steam/logs"
          ],
          "runtime" :
          [
            "${pkgs.opencomposite}/lib/opencomposite"
          ],
          "version" : 1
        }
      '';
    };
    dataFile."monado/hand-tracking-models".source = pkgs.fetchgit {
      url = "https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models";
      sha256 = "x/X4HyyHdQUxn3CdMbWj5cfLvV7UyQe1D01H93UCk+M=";
      fetchLFS = true;
    };
  };
}
