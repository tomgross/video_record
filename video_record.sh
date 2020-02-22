# !/bin/bash
#
# rec_vhs.sh - Skript zum Aufnehmen von VHS Videos über eine BT848 Fernsehkarte
# Version: 0.1
# Autor: Hans Matzen
#
raw="0"
format="16/9"
tvtime="0"
outfile="capture"
while getopts hr4to: opt
 do
    case $opt in
        h) echo "rec_vhs.sh - Skript zum digitalisieren von VHS Videos per TV-Karte"
           echo "Aufruf:"
           echo "rec_vhs.sh  "
           echo "Optionen:"
           echo "-h      - gibt diesen Hilfetext aus"
           echo "-4      - verwendet 4:3 Format anstatt 16:9 Format"
           echo "-r      - zeichnet RAW Daten auf anstatt MPEG"
           echo "-t      - startet tvtime und beginnt mit der Aufnahme, wenn tvtime beendet wird (ESC)"
           echo "-o   - gibt wie die Ausgabedatei heißen soll (ohne Suffix)"
           echo ""
           exit 0;;
        r) raw="1";;
        4) format="4/3";;
        t) tvtime="1";; 
        o) outfile=$OPTARG;;
        ?) echo "Ungültige Option"; exit 1;;
    esac
 done
 # multiplex /dev/video0 to /dev/video1
 # ffmpeg -f v4l2 -i /dev/video0 -f v4l2 /dev/video1 &
 # input 0 fpr antenne, 1 for composite, 2 for s-video
 tvdriver_opt="driver=v4l2:device=/dev/video0:normid=5:input=1:alsa=1:adevice=hw.0,0:audiorate=48000:amode=1:width=768:height=576 "
 if [ $tvtime == "1" ]; then
     tvtime 
 fi
 if [ $raw == "1" ]; then
     echo "Starte Aufzeichnung mit RAW Daten"
     # RAW Daten speichern
     mencoder tv:// -tv $tvdriver_opt -oac copy -ovc copy -o $outfile.avi
 else
     echo "Starte Aufzeichnung mit MPEG Daten"
     # mpg aufnehmen von bt848
     mencoder tv:// -tv $tvdriver_opt \
         -oac lavc -ovc lavc -of mpeg -mpegopts format=dvd:tsaf -vf scale=720:576,harddup -srate 48000 -af lavcresample=48000 \
         -lavcopts vcodec=mpeg2video:vrc_buf_size=1835:vrc_maxrate=9800:vbitrate=5000:keyint=15:vstrict=0:acodec=ac3:abitrate=192:aspect=$format \
         -ofps 25 -o $outfile.mpg 
 fi