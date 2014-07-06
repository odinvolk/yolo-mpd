#!/bin/bash

# requires mpc to get song info
# requires glyr https://github.com/sahib/glyr to retrieve metadata
# requires eyeD3 http://eyed3.nicfit.net/ to extract image from mp3
# Snagged mpc-based looping from http://www.hackerposse.com/~rozzin/mpdjay

# uses xseticon, wmctrl, and transset to make its little terminal window all pretty.  Feel free to delete these lines.

	snark=$(echo $WINDOWID)
	xseticon -id $snark ~/.icons/Faenza-Like/iKamasutra.png
	wmctrl -i -r "$snark" -T "Album Art Downloader" 
	transset 0.7 -i "$snark"

########### Configuration
# TODO:  Sane defaults and autodetect
GLYRDIR=~/.cache/glyrc
MUSICDIR=~/music
TMPDIR=~/tmp

function cleanup {
	# I use trash-cli here instead of rm
	# https://github.com/andreafrancia/trash-cli
	# Obviously, substitute rm -f for trash if you want to use it.
	find "$TMPDIR/" -iname "OTHER*"  -exec trash {} \;
	find "$TMPDIR/" -iname "FRONT_COVER*"  -exec trash {} \;
	find "$TMPDIR/" -iname "cover*"  -exec trash {} \;	
}

function get_album_art {
	cleanup
	echo "### Finding cover for $ALBUM..."

	# existing file, from ID3 tag, from internet.  Always to cover.jpg
	# always prefer cover art stored in music directory, then mp3
	# presumption is that it's easier to just read jpg in directory... and to delete if wrong
	coverart1="$SONGDIR"
	#coverart1=$MUSICDIR/"$ALBUM"/"$ARTIST"
	# trimming characters that jack it up...
	coverart1=$(echo "$coverart1"| sed s/[:.]//g)
	# getting lowercase duh!
	coverart="${coverart1,,}"
	coverart=$(echo "$coverart/cover.jpg")

	if [ ! -f "$coverart" ]; then
		echo "### Cover art not found at $coverart"
		eyeD3 --write-images=$TMPDIR "$SONGFILE"
		if [ -f "$TMPDIR/FRONT_COVER.png" ]; then
			echo "converting PNG into JPG"
			convert "$TMPDIR/FRONT_COVER.png" "$TMPDIR/FRONT_COVER.jpeg"
		fi
		if [ -f "$TMPDIR/FRONT_COVER.jpeg" ]; then
			echo "### Cover art retrieved from MP3 ID3 tags!"
			echo "### Cover art being copied to music directory!"
			cp "$TMPDIR/FRONT_COVER.jpeg" "$coverart"
			if [ ! -f "$coverart" ]; then
				cp "$TMPDIR/FRONT_COVER.jpg" "$SONGDIR/cover.jpg"
			fi
		else
			echo "### Cover art not found in ID3 tags!"
			echo "### Cover art being found on the interwebs!"
			#THIS IS BREAKING ON STRANGE ALBUM NAMES
			glyrc cover --artist "$ARTIST" --album "$ALBUM" --formats jpeg --write "$coverart" --from "musicbrainz;lastfm;local;rhapsody;jamendo;discogs;coverartarchive"
			# we are not writing from glyr to ID3 because sometimes it's just plain wrong.
		fi
	else
		echo "### Cover art found in music directory."
	fi
	# just in case there is STILL nothing, a last test.
}

if [ "$1" = "--standalone" ]; then
	# we need to walk the music directory and find art.
	# http://stackoverflow.com/questions/12873834/list-directories-not-containing-certain-files
	# http://stackoverflow.com/questions/5374239/tab-separated-values-in-awk
	
	find . -iname "*.mp3" | sed -e 's!/[^/]*$!!' -e 's!^\./!!' | sort -u | while read dir
	do
		SONGDIR="$PWD/$dir"
		if [ ! -f "$SONGDIR/cover.jpg" ]; then	
			SONGFILE=$(find "$SONGDIR" -iname "*.mp3" | head -1)
			ARTIST=$(eyeD3 "$SONGFILE" | grep "artist" | awk -F ': ' '{print $3}')
			ALBUM=$(eyeD3 "$SONGFILE" | grep "album" | awk -F ': ' '{print $2}' | awk 'BEGIN {FS="\t"}; {print $1}')
			echo "Finding cover art for $ALBUM by $ARTIST"
			get_album_art
		fi
	done
else

	(echo qman-startup; mpc idleloop) \
	| while read event
	do
		if [ "$event" = "mixer" ]
		then
			continue
		fi
		ARTIST=$(mpc --format %artist% | head -1)
		ALBUM=$(mpc --format %album% | head -1)
		SONGFILE=$(mpc --format %file% | head -1)
		SONGFILE=$MUSICDIR/"$SONGFILE"
		SONGDIR=$(dirname "$SONGFILE")
		if [ -f "$SONGFILE" ]; then
			echo "Getting info for $ARTIST and $ALBUM"
			get_album_art
		else
			echo "We're getting wrong information for some reason."
		fi
		cleanup
	done
fi