yolo-mpd
========

Various MPD tweaks and tips and tools and scripts I've put together or found and tweaked.

# mashup_fixer

Dependencies: 
* [eye3D](http://eyed3.nicfit.net/)

Finds MP3 files that have song titles like "Scratches All Down My Back (Buckcherry vs.Toto)" and moves the artists that are in the parentheses or brackets to the "Album Artist" field. Searches recursively from the directory you run it in, and stores a CSV of changes made in your $HOME directory. Use --dryrun as an option first if you like.

# terminal_multiplexer

Uses tmux, xterm, ncmpcpp, cava, and [terminal covers](https://github.com/uriel1998/yolo-mpd#terminalcoverssh) to provide a nice layout. Title set to screen by wmctrl.  No tmux.conf file needed.  Inspired by [this reddit post](https://www.reddit.com/r/unixporn/comments/3q4y1m/openbox_music_now_with_tmux_and_album_art/).

Dependencies: 
* [mpc](http://git.musicpd.org/cgit/master/mpc.git/)  
* [tmux](https://tmux.github.io/)  
* [ncmpcpp](https://github.com/arybczak/ncmpcpp)  
* [wmctrl](https://linux.die.net/man/1/wmctrl)  

One or more of the following:  

* [AA-lib](http://aa-project.sourceforge.net/aview/)
* [libcaca](http://caca.zoy.org/wiki/libcaca)
* [img2text](https://github.com/hit9/img2txt)

![AA-lib](aaview_layout.jpg)
![asciiart](asciiart_layout.jpg?raw=true "asciiart output")
![img2txt](img2txt_layout.jpg?raw=true "img2txt output")


# bpmhelper.sh

Uses the bpm-tools package, which analyzes BPM quite nicely on linux, but then writes tags that overwrite album and genre tags. So this wrapper uses eyeD3 to determine if a BPM is already written, then analyzes the file, then uses eyeD3 to do the writing to the file. I already have eyeD3 for the album art script (below); a solution that does not rely on that dependency can be found at [bpmwrap](https://github.com/meridius/bpmwrap).

Accepts two command line arguments (optional)

Use --save-existing to save existing data.  
Use --skip-existing to skip further analysis of those that have existing BPM
Use --quiet to suppress output (eyeD3 may still output to the screen)

Analyzes the current directory *and all subdirectories*.

Dependencies
* [bpm-tools](http://www.pogo.org.uk/~mark/bpm-tools/)
* [eye3D](http://eyed3.nicfit.net/)

# mp3gainhelper.sh

Performs mp3gain analysis and writes to id3 tags. The MP3Gain utility apparently writes by default to APE tags, which aren't used by MPD. But apparently mp3gain has issues corrupting ID3 data if you write directly to ID3 tags, and will just crash and abort if it runs into an error instead of continuing onward.

Accepts only one command line argument (optional) giving the directory to analyze. Otherwise analyzes the current directory *and all subdirectories*.

Dependencies: 
* [mp3gain](http://mp3gain.sourceforge.net/)
* ape2id3 from [MPD Wiki](http://mpd.wikia.com/wiki/Hack:ape2id3.py) or [this gist](https://gist.github.com/uriel1998/6333da780d44e59abbc1761700104329)

# webserver.covers.sh

Very simple script to make your album covers accessible by MPoD or other remote clients without exposing your entire music directory by copying the cover files to the webserver root. (You need to edit this, obvs.)

Dependencies:
* [rsync](https://en.wikipedia.org/wiki/Rsync)

# mpdcontrol.sh

Select whether you want to choose a playlist, or by album, artist, or genre. Clears playlist, adds what you chose, starts playing. The SSH version is for exactly that, especially if you don't have *pick* on that machine.

Dependencies: 
* [pick](https://github.com/thoughtbot/pick)
* [mpc](http://git.musicpd.org/cgit/master/mpc.git/)

![output](out.gif?raw=true "What it looks like")

# terminalcovers.sh

A kind of hack-y way to show terminal covers in the terminal.  Uses either AA-lib or libcaca.  AA-lib looks MUCH better, but doesn't automatically exit, so requires killall (yeah, that sucks).  You will need to *edit* the script to choose a different renderer.

Dependencies: 
* [mpc](http://git.musicpd.org/cgit/master/mpc.git/)

One or more of the following:  

* [AA-lib](http://aa-project.sourceforge.net/aview/)
* [libcaca](http://caca.zoy.org/wiki/libcaca)
* [img2text](https://github.com/hit9/img2txt)

### AA-lib output
![AA-lib](aaview_output.png?raw=true "AA-lib output")
### libcaca output
![LibCaca](libcaca_output.png?raw=true "libcaca output")

# mediakey.sh

This script uses the MPRIS interface to control your media players.  Currently supported players include MPD, Pithos, Audacious, and Clementine

# ffixer_covers

This supercedes the simple_covers scripts. This just walks recursively the directory it starts from and writes cover.jpg and folder.jpg from the embedded art in the MP3s, or tries to find it from the interwebs. The older simple_covers scripts remain as a learning exercise.

Dependencies:

* [glyr](https://github.com/sahib/glyr)
* [eye3D](http://eyed3.nicfit.net/)
* [mpc](http://git.musicpd.org/cgit/master/mpc.git/)
