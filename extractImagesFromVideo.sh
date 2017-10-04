#!/bin/bash
# Script to extract images from a video frame by frame
#
# To run script: bash extractImagesFromVideo.sh my_video_file number_of_frames_to_extract
#
# This script will create a folder with the name same as the name of the video file (without the extension, for eg. .avi, .mp4, etc)

# Colors to print custom error messages
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Stores folder name, extracted from the name of the video file
if ! [ -z "$1" ]
then
    FOLDERNAME=${1%.*}
else
    printf "${RED}ERROR!! Please pass the video file name as a parameter.\n${NC}"
    exit 1
fi

# Function executed when user presses ctrl+c
abort()
{
    rm -rf $FOLDERNAME # Remove the created folder

    printf "${RED}This script was exited using ctrl+c.\n${NC}"

    exit 1
}

# Function executed when some error is occured while running the script
error()
{
    rm -rf $FOLDERNAME # Remove the created folder

    printf "${RED}An error occurred. Read above this line to find what the error is related to. Exiting...
If it is a ffmpeg related error, make sure you have ffmpeg installed. To do so, follow the instructions below:
1. (Optional) If you have ffmpeg installed but it isn't working correctly:
	sudo apt-get remove ffmpeg --purge
2. FFmpeg has been removed from Ubuntu 14.04 and was replaced by Libav. However, we can install FFmpeg from mc3man ppa. Add the mc3man ppa:
	sudo add-apt-repository ppa:mc3man/trusty-media
3. Update the package list:
	sudo apt-get update
4. Now FFmpeg is available to be installed with apt:
	sudo apt-get install ffmpeg\n${NC}"

    exit 1
}

# Set traps for interrupts (ctrl+c) and errors
trap 'abort' INT
trap 'error' ERR

# Exit immediately if a command exits with a non-zero status.
set -e

# If the folder already exists, delete it and all its contents
if [ -d "$FOLDERNAME" ]; then
    rm -rf $FOLDERNAME
fi

mkdir $FOLDERNAME # Create a folder

if ! [ -z "$2" ] # Check if number of frames was passed as a parameter
then
    ffmpeg -i $1 -frames $2 $FOLDERNAME/frame%05d.jpg -hide_banner
    cd $FOLDERNAME
    NEXTRACTEDFILES=$(ls -1 | wc -l)
    if [ $2 -eq $NEXTRACTEDFILES ]; then
        printf "${GREEN}Success!! Video split into $2 frames.\n${NC}"
    else
        printf "${RED}There was some error as the number of files extracted do not match the number of frames mentioned. Please check for errors!\n${NC}"
    fi
    cd ..
else
    ffmpeg -i $1 $FOLDERNAME/frame%05d.jpg -hide_banner
    printf "${GREEN}Success!!\n${NC}"
fi

# Reset trap before exiting code
trap : 0
