##########################################################################################
#
# Framework Patcher V2 Config Script
#
##########################################################################################

##########################################################################################
# Framework Files Replacement
##########################################################################################

REPLACE="
/system/framework/framework.jar
/system/framework/services.jar
/system/system_ext/framework/miui-services.jar
"

##########################################################################################
# Storage Compatibility for KSU and SUFS
##########################################################################################

# Ensure proper storage paths for different root methods
# This handles cases where MODPATH might not be set correctly
if [ -z "$MODPATH" ]; then
  if [ "$KSU" = "true" ] || [ "$SUFS" = "true" ]; then
    MODPATH="/data/adb/modules/mod_frameworks"
  else
    MODPATH="/data/adb/modules/mod_frameworks"
  fi
fi

# Additional compatibility for different storage locations
if [ ! -d "$MODPATH" ]; then
  if [ -d "/data/adb/modules_update/mod_frameworks" ]; then
    MODPATH="/data/adb/modules_update/mod_frameworks"
  elif [ -d "/data/modules/mod_frameworks" ]; then
    MODPATH="/data/modules/mod_frameworks"
  fi
fi

##########################################################################################
# Permissions
##########################################################################################

set_permissions() {
  # Set proper permissions for framework files
  set_perm_recursive $MODPATH/system/framework 0 0 0755 0644 u:object_r:system_file:s0
  set_perm_recursive $MODPATH/system/system_ext/framework 0 0 0755 0644 u:object_r:system_file:s0
}

##########################################################################################
# MMT Extended Logic - Don't modify anything after this
##########################################################################################

SKIPUNZIP=1
unzip -qjo "$ZIPFILE" 'common/functions.sh' -d $TMPDIR >&2
. $TMPDIR/functions.sh
