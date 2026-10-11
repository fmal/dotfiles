# See the chmod numbers for the files in a directory
function show-permissions() {
  ls -l | awk '{k=0;for(i=0;i<=8;i++)k+=((substr($1,i+2,1)~/[rwx]/) \
      *2^(8-i));if(k)printf("%0o ",k);print}'
}

# create a new file in the current directory and then open it in VSCode
new() {
  touch $1 && code $1
}
