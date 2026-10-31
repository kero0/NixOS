{ config, ... }:
{
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      #ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      AppleKeyboardUIMode = 3;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false;
    };
    finder = {
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXSortFoldersFirst = true;
      FXEnableExtensionChangeWarning = false;
    };
    trackpad.Clicking = true;
    screencapture.location = "${config.my.user.homedir}/Pictures";
    loginwindow.GuestEnabled = false;
  };
}
