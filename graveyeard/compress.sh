#!/usr/bin/env bash

CAMERA_NAME=""
TARGET_DIR=""
DESTINATION_DIR=""
BATCH_SIZE="4"

Help()
{
   # Display Help
   echo "Compress camera footage from a target to a destination"
   echo
   echo "Usage: compress [c][t][d]"
   echo "options:"
   echo "c     specify the camera name"
   echo "t     specify the target directory"
   echo "d     specify the destination directory"
   echo "b     set the batch size, eg concat 4 files at a time"
   echo "h     Show this help"
   echo
}

while getopts 'c:t:d:b:' flag; do
  case "${flag}" in
    c) CAMERA_NAME="${OPTARG}" ;;
    t) TARGET_DIR="${OPTARG}" ;;
    d) DESTINATION_DIR="${OPTARG}" ;;
    b) BATCH_SIZE="${OPTARG}" ;;
    *) Help
       exit 1 ;;
  esac
done

# takes an array
function findMin() {
    arr=("$@")
    # echo "${arr[0]}"
    min="${arr[0]}"
    # echo ${$arr[0]}
    for i in "${arr[@]}";
    do
        # Update min if applicable
        if [[ "$i" -lt "$min" ]]; then
            min="$i"
        fi
    done

    echo $min
    return $min
}

function printArr() {
    arr=("$@")
    for i in "${arr[@]}";
    do
        echo $i
    done
}

# get the absolute path
TARGET_DIR=$(realpath $TARGET_DIR)
DESTINATION_DIR=$(realpath $DESTINATION_DIR)

mkdir -p $TARGET_DIR
mkdir -p $DESTINATION_DIR

printf "Archiving %s to %s\n" $TARGET_DIR $DESTINATION_DIR

# TARGET_DIR=${1:-$(pwd)}

# this file will store the files we need to operate on
VALUES=$(mktemp /tmp/XXXXXXXX)

# reset the temp file
echo "" > $VALUES

# get all of the rendered files and store them in the temp $VALUES file
find $TARGET_DIR -maxdepth 1 -type f -mmin +1 -name "*.mp4" -exec echo "file" {} >> $VALUES \;

# remove blank lines with no text
sed -i '/^$/d' $VALUES

# remove the ./ from the relative
# this makes the file path "safe" for ffmpeg (otherwise it complains)
sed -i 's+\.\/++g' $VALUES

# # log out what we are doing
# cat $VALUES

# if theres at least 4 values (4x15min = 1hour)
# if [ $(wc -l $VALUES | cut -d ' ' -f 1) -ge 4 ]
# then
#     batch=$(tail -n 4 $VALUES)      # Get last 4 lines
#     newFile=$(head -n 4 $VALUES)    # Get everything BUT last 4 lines

#     # Iterate over the batch of 4 files
#     while IFS= read -r line; do
#         echo "... $line ..."
#     done <<< "$batch"
# fi

# cat $VALUES

# echo $VALUES

# echo $(wc -l $VALUES | cut -d " " -f 1)
# echo $VALUES

numberOfValues=$(wc -l $VALUES | cut -d " " -f 1)

# print out how many values we got
printf "found %s potential values to process\n" $numberOfValues

# check there is enough values to process
if [ "$numberOfValues" -lt "$BATCH_SIZE" ]
then
    echo "There wasnt enough values to process, wait for $BATCH_SIZE values first"
    exit 1
fi

# loop over the values file and remove the last 4 lines
while [ $(wc -l $VALUES | cut -d " " -f 1) -ge "$BATCH_SIZE" ]
do
    echo "======== new batch: ========"

    IFS=""
    batch=$(tail -n $BATCH_SIZE $VALUES | sed  "s/file //g")      # Get last 4 lines
    IFS=""
    newFile=$(head -n -$BATCH_SIZE $VALUES | sed  "s/file //g")    # Get everything BUT last 4 lines

    # print the batch as a list of file paths
    # echo $batch

    # create an empty array to store UNIX timestamps
    fileCreationTime=()

    # populate the array with UNIX timestamps for each file
    while IFS="" read -r p || [ -n "$p" ]
    do
        fileCreationTime+=($(stat --format "%X" $p))
    done <<< "$batch"

    # now get the minimum value from the array of file creation times
    min="$(findMin "${fileCreationTime[@]}")"

    # print the array of timestamps for debugging
    # printArr "${fileCreationTime[@]}"

    # Print the min as a pretty date for debugging
    # printf "min: %s\n" "$(date -d @$min -R)"

    # this will become the file output name
    minDate="$(date -d @$min "+%F_%b_%H_%M_%S")"

    # we will save the file to this location
    # echo $DESTINATION_DIR/$minDate.mp4

    # add the word "file " back to the batch for ffmpeg
    ffmpegBatch="$(echo $batch | sed  "s/^/file /g")"
    echo $ffmpegBatch > temp

    # squash the files together into the destination dir
    ffmpeg -y -hide_banner -loglevel error -safe 0 -f concat -i temp -c copy $DESTINATION_DIR/$minDate.mp4 && \
    rm temp

    # then remove the fragmented footage we compressed down
    # while IFS="" read -r file; do
    #     rm $file
    # done <<< "$batch"

    # for i in "${!batch[@]}"
    # do
    #     #   printf "%s\t%s\n" "$i" "${fileCreationTime[$i]}"
    # done

    # echo $min
    # for i in "${!fileCreationTime[@]}"
    # do
    #       printf "%s\t%s\n" "$i" "${fileCreationTime[$i]}"
    # done

        # echo $fileCreationTime[$i]
    # echo $fileCreationTime

    echo $newFile > $VALUES
done

# IFS=""
# batch=$(tail -n 4 $VALUES | sed  "s/file //g")      # Get last 4 lines
# newFile=$(head -n 4 $VALUES)    # Get everything BUT last 4 lines

# echo $batch


# # squash the files together
# ffmpeg -y -f concat -i $VALUES -c copy output.mp4

# # # Delete the fragment videos
# # while IFS="" read -r p || [ -n "$p" ]
# # do
# #     rm ./$(echo $p | sed "s/file //g")
# # done < $VALUES

# rm $VALUES