ELDER readme - MPEG4 ASP and AVC encoding on a windows multi-CPU system and windows cluster

________________________
Important install notes:
- Install avisynth 2.5.6 or newer on your computer
- Install PXPerl 5.8.7-6 or newer on your computer
- On non Windows XP systems: Please replace the cmd.exe with the version in your /WINDOWS/system32 directory
- Spaces in filenames and paths are not supported yet

_____________
Known issues:
- total size is sometimes off by a few percent
- .avs files need to use absolute paths

__________
ELDER GUI:
- start gui.bat
- select number of CPUs to use on the master
- hit the "start SMP" button
- if you have more PCs then start one spawn1.bat per available CPU on the slave computers from within the common ELDER directory
- fill in path to an avisynth input
- fill in path to an output .mp4 file
- select your encoding mode: xvid/x264, 2pass/crf/abr/...
- select target size, bitrate or crf according to the selected mode
- select encoding effort; this denotes the amount of CPU time that goes into encoding
- click "add job to queue"
- add additional jobs the same way (pathes, mode, size, effort); they will be executed in sequence
- after encoding hit "reset SMP and cluster" to stop all compute processes
- quit the GUI

________________________
command line parameters:
!Important! start control.bat once on the master and as many spawn1.bat as you like as slaves
perl functions.pl gui_xvid <options>
-m specifies number of cores used (default=2); specify in cluster mode as well as this helps load balancing
-a /path/to/input.avs; default is "default.avs"
-o name of output; default is "output.mp4"
-s total target size in Bytes (omit -b if you use this option)
-b average bitrate in kbit/s (omit -s if you use this option); default is 700 kbit/s
-r specifies the crf to use in the x264crf mode and in xvid_crf2 mode
-f number of frames; auto detects if not specified
-c number of chunks; should be set a bit larger than maxpar; use of default is encouraged
-p 1st pass options for xvid; don't specify bitrate!
-q 2nd pass options for xvid; don't specify bitrate!
-j specifies the global jobfile used by the cluster nodes; default is "", i.e. SMP mode

_________________________________
ELDER command line examples:
- encode blafu.avs to a 10MB xvid file using 2 threads:
perl functions.pl xvid -a blafu.avs -m 2 -s 10485760 -o blafu.mp4
- encode blafu.avs at 800kbit/s to xvid using 4 threads and 64 chunks:
perl functions.pl xvid -a blafu.avs -m 4 -b 800 -c 64 -o blafu.mp4
- encode blafu.avs at 800kbit/s to xvid using 2 threads and the xvidCRF mode:
perl functions.pl xvid_crf3 -a blafu.avs -m 2 -b 800 -o blafu.mp4
- encode blafu.avs to x264 using 1pass crf mode:
perl functions.pl x264crf -a blafu.avs -o out_crf21.mp4 -j global.jobs -r 21
- encode blafu.avs to x264 using 1pass abr mode:
perl functions.pl x264abr -a blafu.avs -o out_crf21.mp4 -j global.jobs -b 800

________________
Shutdown/Resume:
- use shutdown.bat while an encode is still in progress
- wait for all running processes to complete
- do whatever you like, even a reboot is possible :)
- resume the encode with resume.bat


Happy video encoding,
Tobias Bergmann
