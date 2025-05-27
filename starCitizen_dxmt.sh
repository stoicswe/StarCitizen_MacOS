# Set the maximum number of open files 1048576
# ulimit -n 67840
ulimit -n 1048576
#sudo launchctl limit maxfiles 128000 524288

# Set the log name
# Create timestamped log name
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
logbase="$HOME/StarCitizenConfigs/starcitizen_logs/starcitizen_dxmt_$timestamp"
logfile="$logbase.log"

# Ensure log directory exists
mkdir -p "$HOME/StarCitizenConfigs/starcitizen_logs"

# Add a numeric suffix if file exists
i=1
while [[ -f "$logfile" ]]; do
    logfile="${logbase}_$i.log"
    ((i++))
done

# Set some global vars for the run
export VK_ICD_FILENAMES="$HOME/vulkan_icd/MoltenVK_icd.json"

# Begin execution
MTL_HUD_ENABLED=1 \
ROSETTA_AVX_ENABLE=1 \
ROSETTA_ADVERTISE_AVX=1 \
WINEARCH=win64 \
EOS_USE_ANTICHEATCLIENTNULL=1 \
DXVK_CONFIG_FILE=$HOME/StarCitizenConfigs/dxvk_dxmt.conf \
WINEDLLOVERRIDES="d3d11=n;dxgi=n" \
SteamGameId=starcitizen \
    /Applications/CrossOver.app/Contents/SharedSupport/CrossOver/bin/cxstart \
        --bottle "Star Citizen" \
        -- "C:\\Program Files\\Roberts Space Industries\\RSI Launcher\\RSI Launcher.exe" \
        --disable-gpu --no-sandbox --in-process-gpu --disable-gpu-compositing \
        2>&1 | tee "$logfile"
