# Set the maximum number of open files 1048576
# ulimit -n 67840
ulimit -n 1048576
#sudo launchctl limit maxfiles 128000 524288

# Set the log name
# Create timestamped log name
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
logbase="$HOME/StarCitizenConfigs/starcitizen_logs/starcitizen_wine_$timestamp"
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
MTL_HUD_ENABLED=1 \
ROSETTA_AVX_ENABLE=1 \
ROSETTA_ADVERTISE_AVX=1 \
WINEARCH=win64 \
EOS_USE_ANTICHEATCLIENTNULL=1 \
WINEDLLOVERRIDES="d3d11=b;dxgi=b" \
PROTON_USE_WINED3D=1 \
SteamGameId=starcitizen \
    /Applications/CrossOver.app/Contents/SharedSupport/CrossOver/bin/cxstart \
        --bottle "Star Citizen" \
        -- "C:\\Program Files\\Roberts Space Industries\\RSI Launcher\\RSI Launcher.exe" \
        --disable-gpu --no-sandbox --in-process-gpu --disable-gpu-compositing \
        2>&1 | tee "$logfile"
