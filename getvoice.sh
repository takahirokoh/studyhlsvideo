#!/usr/bin/env bash

_download() {
  local filename=$1
  local base_url=$2
  if [ -e $filename ]; then
    echo "$filename exists. skipped..."
  else
    sleep 1
    echo "downloading $filename"
    curl -O $base_url/$filename
  fi
}

_download_recursively() {
  local filename=$1
  local base_url=$2

  _download $filename $base_url
  echo $filename | grep 'm3u8$' > /dev/null
  if [ $? -eq 0 ]; then
    # for .m3u8 file. 
    while read LINE
    do
      echo ${LINE} | sed -e "s/[\r\n]\+//g" | grep '^#.*\|^\s*$' > /dev/null
      if [ $? -eq 0 ]; then
        continue
      fi
      _download_recursively $LINE $base_url
    done < $filename
  fi
}

_process() {
  cd $1
  if [ -e audio.wav ]; then
    echo "$1.wav exists. skipped..."
    cd ..
    return
  fi
  local base_url="https://streams.tbs.co.jp/flvfiles/_definst_/newsi/news${1}_33.mp4"
  _download_recursively playlist.m3u8 $base_url
  if [ -e "$1.ts" ]; then
    echo "$1.ts exists. skipped..."
  else
    cat *.ts > $1.ts
  fi 
  ffmpeg -i $1.ts $1.wav
  cd .. 
}

for x in $(cat -)
do
  _process $x
  echo 'done for ' $x
done
