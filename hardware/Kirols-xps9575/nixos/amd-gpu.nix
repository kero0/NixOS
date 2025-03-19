{ pkgs, ... }:
{
  boot.initrd.kernelModules = [ "amdgpu" ];
  # services.xserver.videoDrivers = [ "amdgpu" ];

  systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      clinfo
      amdvlk

      # intel
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      amdvlk
      intel-vaapi-driver
    ];
  };
  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    amdgpuBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver

  # environment.variables = { ROC_ENABLE_PRE_VEGA = "1"; };
}
