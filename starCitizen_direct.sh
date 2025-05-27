# Set the maximum number of open files 1048576
# ulimit -n 67840
ulimit -n 1048576
#sudo launchctl limit maxfiles 128000 524288

# Set the log name
# Create timestamped log name
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
logbase="$HOME/StarCitizenConfigs/starcitizen_logs/starcitizen_direct_$timestamp"
logfile="$logbase.log"

# Ensure log directory exists
mkdir -p "$HOME/StarCitizenConfigs/starcitizen_logs"

# Add a numeric suffix if file exists
i=1
while [[ -f "$logfile" ]]; do
    logfile="${logbase}_$i.log"
    ((i++))
done

# Begin execution
#launchctl limit maxfiles 65536 524288
# "C:\\Program Files\\Roberts Space Industries\\RSI Launcher\\RSI Launcher.exe --disable-gpu --no-sandbox --in-process-gpu --disable-gpu-compositing"
ulimit -n 1048576
export CX_BOTTLE="$HOME/Library/Application Support/CrossOver/Bottles/Star Citizen/"
export MTL_HUD_ENABLED=1
export ROSETTA_AVX_ENABLE=1
export ROSETTA_ADVERTISE_AVX=1
export WINEARCH=win64
export EOS_USE_ANTICHEATCLIENTNULL=1
export WINEDLLOVERRIDES="d3d11=n;dxgi=n"
export VK_ICD_FILENAMES="/opt/homebrew/share/vulkan/icd.d/MoltenVK_icd.json"
export DXVK_CONFIG_FILE=$HOME/StarCitizenConfigs/dxvk_dxmt.conf
export DYLD_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_LIBRARY_PATH"
export VK_LOADER_DEBUG=all
export SteamGameId=starcitizen

VK_ICD_FILENAMES="/opt/homebrew/share/vulkan/icd.d/MoltenVK_icd.json" \
/Applications/CrossOver.app/Contents/SharedSupport/CrossOver/bin/cxstart \
    -- C:\\Program\ Files\\Roberts\ Space\ Industries\\RSI\ Launcher\\RSI\ Launcher.exe \
    --disable-gpu --no-sandbox --in-process-gpu --disable-gpu-compositing \
    2>&1 | tee "$logfile"
