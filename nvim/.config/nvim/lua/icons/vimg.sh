 #!/usr/bin/env bash

SCRIPT=`realpath $0`

readonly BASH_BINARY="$(which bash)"
declare -x PREVIEW_ID="preview"

declare -x TMP_FOLDER="/tmp/vimg"
mkdir -p $TMP_FOLDER

function render_at_size {
  max_width="${1}"
  max_height="${2}"
  img_path="${3}"

  # animation is turned off as it does werid things with the terminal output
  # chafa --animate=off --center=on --clear --size "${max_width}x${max_height}" "${img_path}"
  rsvg-convert -w 512 -h 512 "${img_path}"  | chafa --animate=off --center=on --clear -f symbols -
}

function draw_preview {
    if ! command -v chafa &> /dev/null; then
      echo "chafa could not be found in your path,\nplease install it to display media content"
      exit
    fi

    if [[ "$1" == "imagepreview" ]]; then
      render_at_size "${5}" "${6}" "${2}" "${7}"
      # viu -b -w ${5} -h ${6} "${2}"

    elif [[ "$1" == "gifpreview" ]]; then
      # This is static for now, feel free to re-introduce FIFO to make
      # animations work again, plaing viu gifs (removing the -s flag) causes
      # the preview window to scroll weirdly
      render_at_size "${5}" "${6}" "${2}" "${7}"

    elif [[ "$1" == "videopreview" ]]; then
      if ! command -v viu &> /dev/null; then
        echo "ffmpegthumbnailer could not be found in your path,\nplease install it to display video previews"
        exit
      fi
      path="${2##*/}"
      echo -e "Loading preview..\nFile: $path"
      ffmpegthumbnailer -i "$2" -o "${TMP_FOLDER}/${path}.png" -s 0 -q 10
      clear
      render_at_size "${5}" "${6}" "${TMP_FOLDER}/${path}.png" "${7}"

    elif [[ "$1" == "pdfpreview" ]]; then
      path="${2##*/}"
        echo -e "Loading preview..\nFile: $path"
        [[ ! -f "${TMP_FOLDER}/${path}.png" ]] && pdftoppm -png -singlefile "$2" "${TMP_FOLDER}/${path}.png"
        clear
        render_at_size "${5}" "${6}" "${TMP_FOLDER}/${path}.png" "${7}"
    fi
}

function parse_options {
    extension="${1##*.}"
    case $extension in
    jpg | png | jpeg | webp | svg)
        draw_preview  imagepreview "$1" $2 $3 $4 $5 $6
    ;;

    gif)
        draw_preview  gifpreview "$1" $2 $3 $4 $5 $6
    ;;

    avi | mp4 | wmv | dat | 3gp | ogv | mkv | mpg | mpeg | vob |  m2v | mov | webm | mts | m4v | rm  | qt | divx)
        draw_preview  videopreview "$1" $2 $3 $4 $5 $6
    ;;

    pdf | epub)
        draw_preview  pdfpreview "$1" $2 $3 $4 $5 $6
    ;;

    *)
    echo -n "unknown file $1"
    ;;
    esac
}

parse_options "${@}"
read
