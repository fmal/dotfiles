gifify() {
    if [[ -n "$1" ]]; then
        if [[ $2 == '--good' ]]; then
            ffmpeg -i $1 -r 10 -vcodec png out-static-%05d.png
            time convert -verbose +dither -layers Optimize -resize 600x600\> out-static*.png  GIF:- | gifsicle --colors 128 --delay=5 --loop --optimize=3 --multifile - > $1.gif
            rm out-static*.png
        else
            ffmpeg -i $1 -s 600x400 -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > $1.gif
        fi
    else
        echo "proper usage: gifify <input_movie.mov>. You DO need to include extension."
    fi
}

# Install a grunt plugin and save to devDependencies
function gi() {
    sudo npm install --save-dev grunt-"$@"
}

# Install a grunt-contrib plugin and save to devDependencies
function gci() {
    sudo npm install --save-dev grunt-contrib-"$@"
}

# See the chmod numbers for the files in a directory
function show-permissions() {
    ls -l | awk '{k=0;for(i=0;i<=8;i++)k+=((substr($1,i+2,1)~/[rwx]/) \
            *2^(8-i));if(k)printf("%0o ",k);print}'
}

# create a new file in the current directory and then open it in Sublime
new() {
    touch $1 && subl $1
}
