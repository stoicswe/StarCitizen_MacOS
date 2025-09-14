cd ~/Github/wine
patch -p1 --no-backup < ~/Github/wine-patches/10.2+_eac_fix.patch
patch -p1 --no-backup < ~/Github/wine-patches/eac_60101_timeout.patch
cd ~/Github
