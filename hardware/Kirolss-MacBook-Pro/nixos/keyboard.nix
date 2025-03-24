{
  system.keyboard.enableKeyMapping = true;
  system.keyboard.userKeyMapping = [
    # caps lock to ctrl
    {
      HIDKeyboardModifierMappingSrc = 30064771129;
      HIDKeyboardModifierMappingDst = 30064771296;
    }
    # swap ctrl and fn
    {
      HIDKeyboardModifierMappingSrc = 30064771296;
      HIDKeyboardModifierMappingDst = 1095216660483;
    }
    {
      HIDKeyboardModifierMappingSrc = 1095216660483;
      HIDKeyboardModifierMappingDst = 30064771296;
    }
  ];

}
