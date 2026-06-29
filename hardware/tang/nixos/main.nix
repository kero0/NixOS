{
  security.sudo.wheelNeedsPassword = false;
  networking.wireless.enable = true;
  # Preserve space by sacrificing documentation and history
  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };
}
