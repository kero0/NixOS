% ZELLIJ-RENUMBER(1) | My tools

# NAME

zellij-renumber - keep zellij's default tab names matching their positions

# SYNOPSIS

**zellij-renumber**

# DESCRIPTION

zellij names new tabs "Tab #N" by the order they were made, so the names go
stale when a tab before them closes. **zellij-renumber** renames every tab
still called "Tab #N" to its position in the current session; tabs you've
named yourself are left alone.

The new-tab and close keys (the prefix and **c** or **x**, and **c** or **x**
in tab mode) run it right after, so you don't normally run it yourself.

# SEE ALSO

**zellij**(1)
