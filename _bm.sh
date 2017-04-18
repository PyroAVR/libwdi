#!/bin/sh
# Create and upload a Zadig release
# !!!THIS SCRIPT IS FOR INTERNAL DEVELOPER USE ONLY!!!

target_dir=/e/dailies/libwdi

type -P git &>/dev/null || { echo "Git not found. Aborting." >&2; exit 1; }
type -P sed &>/dev/null || { echo "Set not found. Aborting." >&2; exit 1; }
type -P upx &>/dev/null || { echo "UPX executable not found. Aborting." >&2; exit 1; }

zadig_version=`sed -n 's/^.*\"FileVersion\", \"\(.*\)\..*\"/\1/p' examples/zadig.rc`
echo Building Zadig v$zadig_version...

git clean -fdx
./autogen.sh --disable-shared

cd libwdi
make
cd ../examples
make zadig.exe
type -P SetACL &>/dev/null && { SetACL -on ./zadig.exe -ot file -actn ace -ace "n:S-1-5-18;p:read,read_ex;s:y"; }
upx --lzma zadig.exe
cp zadig.exe $target_dir/zadig_$zadig_version.exe
cmd.exe /k zadig_sign.bat "$target_dir/zadig_$zadig_version.exe"
cd ..
