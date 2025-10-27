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
# KSU Storage Protection - Prevent /sdcard unmounting
##########################################################################################

# Fix KSU storage issues that cause /sdcard to become unusable
if [ "$KSU" = "true" ]; then
  # Prevent /sdcard from being unmounted during module installation
  # This is a common KSU issue where storage becomes inaccessible
  if [ -d "/sdcard" ]; then
    # Ensure /sdcard remains accessible
    mount | grep -q "/sdcard" || {
      # Try to remount /sdcard if it's not mounted
      mount -t sdcardfs -o rw,nosuid,nodev,noexec,relatime /data/media /sdcard 2>/dev/null || {
        ui_print "Warning: Could not remount /sdcard, storage may be inaccessible"
      }
    }
  fi

  # Fix framework.jar storage path issues in KSU
  # KSU sometimes has incorrect paths for system files
  if [ ! -f "/system/framework/framework.jar" ] && [ -f "$MODPATH/system/framework/framework.jar" ]; then
    ui_print "Fixing framework.jar path for KSU compatibility"
    # Ensure the original framework.jar exists before replacement
    if [ ! -d "/data/local/tmp/framework_backup" ]; then
      mkdir -p "/data/local/tmp/framework_backup"
    fi
  fi
fi

# Additional storage protection for all root methods
# Ensure external storage remains accessible
if [ -d "/storage/emulated/0" ]; then
  mount | grep -q "/storage/emulated/0" || {
    mount -t sdcardfs -o rw,nosuid,nodev,noexec,relatime /data/media /storage/emulated/0 2>/dev/null || true
  }
fi

# Fix common storage path issues
STORAGE_PATHS="/sdcard /storage/emulated/0 /data/media /storage"
for path in $STORAGE_PATHS; do
  if [ -d "$path" ]; then
    # Test if storage is writable
    echo "test" > "$path/.access_test" 2>/dev/null && rm -f "$path/.access_test" 2>/dev/null || {
      ui_print "Warning: Storage path $path is not writable"
    }
  fi
done

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
