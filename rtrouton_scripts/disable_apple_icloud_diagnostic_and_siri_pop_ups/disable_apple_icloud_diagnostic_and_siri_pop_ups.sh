#!/bin/bash

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
sw_vers=$(sw_vers -productVersion)

# Determine OS build number

sw_build=$(sw_vers -buildVersion)

# Checks first to see if the Mac is running 10.7.0 or higher. 
# If so, the script checks the system default user template
# for the presence of the Library/Preferences directory. Once
# found, the iCloud, Diagnostic and Siri pop-up settings are set 
# to be disabled.

if [[ ${osvers} -ge 7 ]]; then

 for USER_TEMPLATE in ls -l "/System/Library/User Template/" | grep .lproj | awk '{print $9}'
  do
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeeSiriSetup -bool TRUE      
  done
  
 # Checks first to see if the Mac is running 10.7.0 or higher.
 # If so, the script checks the existing user folders in /Users
 # for the presence of the Library/Preferences directory.
 #
 # If the directory is not found, it is created and then the
 # iCloud, Diagnostic and Siri pop-up settings are set to be disabled.

 for USERNAME in dscl . list /Users UniqueID | awk ' $2 >= 500 {print $1}'  
  do
    USER_HOME=$(dscl . read "/Users/$username" NFSHomeDirectory | awk '{print $2}')
    if [ ! -d "${USER_HOME}"/Library/Preferences ]; then
      /bin/mkdir -p "${USER_HOME}"/Library/Preferences
      /usr/sbin/chown "${USERNAME}" "${USER_HOME}"/Library
      /usr/sbin/chown "${USERNAME}" "${USER_HOME}"/Library/Preferences
    fi
    if [ -d "${USER_HOME}"/Library/Preferences ]; then
      /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
      /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
      /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
      /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
      /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant DidSeeSiriSetup -bool TRUE
      /usr/sbin/chown "${USERNAME}" "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant.plist
      fi
    fi
  done
fi

exit 0
