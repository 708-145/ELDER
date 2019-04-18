#!/usr/bin/perl
# ELDER parallEL encoDER for XviD, X264, Theora, Snow and N0153
# Copyright(C) 2004-2007 Tobias Bergmann <tobe@bergdichter.de>
#
# This program is free software ; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation ; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY ; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program ; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
use Tk;
use Getopt::Std;
$preferredchunksize=1500; $minchunksize=800;
$magicfactor=1.00; # scales bits per chunk; dependent on chunksize!

{ # main: handles scheduling 
	($function,@ARGV)=@ARGV;
	if ($function eq "version") {print "ELDER functions version 1.0.1.5\n"; exit 0;}
	if ($function eq "d2u") {d2u();}
	if ($function eq "u2d") {u2d();}
	if ($function eq "resume") {resume();}
	if ($function eq "shutdown") {shutdown_();}
	if ($function eq "spawn") {spawn();}
	if ($function eq "spawnmax") {spawnmax();}
	if ($function eq "pickjob") {pick_job();}

	if ($function eq "264a") {pass_a();}
	if ($function eq "264c") {pass_c();}
	if ($function eq "264d") {pass_d();}
	if ($function eq "264dcrf") {pass_dcrf();}
	if ($function eq "264abr") {pass_abr();}
	if ($function eq "pass_x264_c") {pass_x264_c();}

	if ($function eq "xva") {pass_xva();}
	if ($function eq "xvb") {pass_xvb();}
	if ($function eq "xvcrf1") {pass_xvcrf1();}
	if ($function eq "xvcrf2") {pass_xvcrf2();}
	if ($function eq "xvcrf3") {pass_xvcrf3();}
	if ($function eq "xvc") {pass_xvc();}
	if ($function eq "xvd") {pass_xvd();}

	if ($function eq "ELDER264") {ELDER264();}
	if ($function eq "x264crf") {x264crf();}
	if ($function eq "x264abr") {x264abr();}
	if ($function eq "x264_3") {x264_3();}
	if ($function eq "x264_2") {x264_2();}
	if ($function eq "xvid") {xvid();}
	if ($function eq "xvidgui") {gui_xvid();}
	if ($function eq "gui_xvid") {gui_xvid();}

	if ($function eq "xvid_crf3") {xvid_crf3();}
	if ($function eq "xvid_crf2") {xvid_crf2();}

	if ($function eq "encode_percent") {encode_percent();}
	if ($function eq "find_resolution") {find_resolution();}
	if ($function eq "autores") {autores();}
	if ($function eq "percent_study") {percent_study();}

#	filecopy("default.avs","d.avs");
} # main
####### math functions
sub round {return int($_[0]+.5);}
sub max {local($a,$b)=($_[0],$_[1]); $a=$b if ($a<$b); return $a;}
sub min {local($a,$b)=($_[0],$_[1]); $b=$a if ($a<$b); return $b;}
sub abs {local($a)=($_[0]); $a=-$a if ($a<0); return $a;}
####### tools
sub spawn { # spawn n jobs in minimized windows
	for ($i=1;$i<=$ARGV[0];++$i) {
		print "starting process $i\n";
		system("start /min perl functions.pl pickjob $ARGV[1] &" or die "couldn't exec $!");
	}
} # spawn
sub spawnmax { # spawn n jobs in maximized windows
	for ($i=1;$i<=$ARGV[0];++$i) {
		print "starting process $i\n";
		system("start perl functions.pl pickjob $ARGV[1] &" or die "couldn't exec $!");
	}
} # spawnmax
sub shutdown_ { # shutdown running compute and control jobs
	### save control.jobs and global.jobs
	rename("global.jobs","global.jobs.save");
	rename("control.jobs","control.jobs.save");

	### quit clients and control jobs
	open(INFO,">global.jobs"); print INFO "quit\n"; close(INFO);
	open(INFO,">control.jobs"); print INFO "quit\n"; close(INFO);

	### delete lockfiles
	removelock("global.jobs"); removelock("control.jobs");

	### wait for nodes to exit
	sleep(2);

	### delete lockfiles again (in case a client still wrote one)
	removelock("global.jobs"); removelock("control.jobs");
} # shutdown
sub resume { ### TODO: resume paused jobs
	$tmpdir=$ARGV[0];
	# TODO: exit if tmpdir does not exist; and remove entry from resume.bat

	exit(0);

	# spawn
	# restore global
	# restore control
	# control

	#### read jobdata
	$jobfile="$tmpdir/job.bat";
	open(PROJECTFILE, "$tmpdir/projectfile.txt");
	@params = <PROJECTFILE>; close(PROJECTFILE);
	$maxpar=substr($params[0], 0, -1);

	#### move started (inflight) but unfinished jobs back to jobqueue (on top)
	# TODO: fix jobqueue on resume
	
	#### start parallel encoders on jobqueue
	system("perl encode.pl $maxpar $tmpdir/jobqueue"); print "### $maxpar encoders spawned\n";
	
	#### execute job.bat
	system("$jobfile");
} # resume
####### job control
sub ELDER264 {
	$tmpdir=int(rand(1000000)); qx("mkdir $tmpdir");
	open(RESUME,">>resume.bat"); print RESUME "perl functions.pl resume $tmpdir\n"; close(RESUME);
	open(PARAMETERS,">$tmpdir/parameters.txt"); for ($i=0;$i<=$#ARGV;++$i) {print PARAMETERS "$ARGV[$i]\n";} close(PARAMETERS);
	getlock("control.jobs");
	open(JOBFILE, ">>control.jobs");
	print JOBFILE "perl functions.pl 264a $tmpdir\n";
	print JOBFILE "perl internals.dll 264c $tmpdir\n";
	print JOBFILE "perl functions.pl 264d $tmpdir\n";
	close(JOBFILE);
	removelock("control.jobs");
	print "encode job $tmpdir set up\n";
} # ELDER264
sub x264crf {
	$tmpdir=int(rand(1000000)); qx("mkdir $tmpdir");
	open(RESUME,">>resume.bat"); print RESUME "perl functions.pl resume $tmpdir\n"; close(RESUME);
	open(PARAMETERS,">$tmpdir/parameters.txt"); for ($i=0;$i<=$#ARGV;++$i) {print PARAMETERS "$ARGV[$i]\n";} close(PARAMETERS);
	getlock("control.jobs");
	open(JOBFILE, ">>control.jobs");
	print JOBFILE "perl functions.pl 264a $tmpdir\n";
	print JOBFILE "perl functions.pl 264dcrf $tmpdir\n";
	close(JOBFILE);
	removelock("control.jobs");
	print "encode job $tmpdir set up\n";
} # x264crf
sub x264abr {
	$tmpdir=int(rand(1000000)); qx("mkdir $tmpdir");
	open(RESUME,">>resume.bat"); print RESUME "perl functions.pl resume $tmpdir\n"; close(RESUME);
	open(PARAMETERS,">$tmpdir/parameters.txt"); for ($i=0;$i<=$#ARGV;++$i) {print PARAMETERS "$ARGV[$i]\n";} close(PARAMETERS);
	getlock("control.jobs");
	open(JOBFILE, ">>control.jobs");
	print JOBFILE "perl functions.pl 264abr $tmpdir\n";
	print JOBFILE "perl functions.pl 264dcrf $tmpdir\n";
	close(JOBFILE);
	removelock("control.jobs");
	print "encode job $tmpdir set up\n";
} # x264abr
sub x264_2 {
	$tmpdir=int(rand(1000000)); qx("mkdir $tmpdir");
	open(RESUME,">>resume.bat"); print RESUME "perl functions.pl resume $tmpdir\n"; close(RESUME);
	open(PARAMETERS,">$tmpdir/parameters.txt"); for ($i=0;$i<=$#ARGV;++$i) {print PARAMETERS "$ARGV[$i]\n";} close(PARAMETERS);
	getlock("control.jobs");
	open(JOBFILE, ">>control.jobs");
	print JOBFILE "perl functions.pl 264a $tmpdir\n";
	print JOBFILE "perl functions.pl pass_x264_c $tmpdir\n";
	print JOBFILE "perl functions.pl 264d $tmpdir\n";
	close(JOBFILE);
	removelock("control.jobs");
	print "encode job $tmpdir set up\n";
} # x264_2
sub x264_3 {
	$tmpdir=int(rand(1000000)); qx("mkdir $tmpdir");
	open(RESUME,">>resume.bat"); print RESUME "perl functions.pl resume $tmpdir\n"; close(RESUME);
	open(PARAMETERS,">$tmpdir/parameters.txt"); for ($i=0;$i<=$#ARGV;++$i) {print PARAMETERS "$ARGV[$i]\n";} close(PARAMETERS);
	getlock("control.jobs");
	open(JOBFILE, ">>control.jobs");
	print JOBFILE "perl functions.pl 264a $tmpdir\n";
	print JOBFILE "perl functions.pl pass_x264_c $tmpdir\n";
	print JOBFILE "perl functions.pl pass_x264_c $tmpdir\n"; # works on improved stats files
	print JOBFILE "perl functions.pl 264d $tmpdir\n";
	close(JOBFILE);
	removelock("control.jobs");
	print "encode job $tmpdir set up\n";
} # x264_3
sub xvid {
	$tmpdir=int(rand(1000000)); qx("mkdir $tmpdir");
	open(RESUME,">>resume.bat"); print RESUME "perl functions.pl resume $tmpdir\n"; close(RESUME);
	open(PARAMETERS,">$tmpdir/parameters.txt"); for ($i=0;$i<=$#ARGV;++$i) {print PARAMETERS "$ARGV[$i]\n";} close(PARAMETERS);
	getlock("control.jobs");
	open(JOBFILE, ">>control.jobs");
	print JOBFILE "perl functions.pl xva $tmpdir\n";
	print JOBFILE "perl functions.pl xvb $tmpdir\n";
	print JOBFILE "perl functions.pl xvc $tmpdir\n";
	print JOBFILE "perl functions.pl xvd $tmpdir\n";
	close(JOBFILE);
	removelock("control.jobs");
	print "encode job $tmpdir set up\n";
} # xvid
sub xvid_crf2 {
	$tmpdir=int(rand(1000000)); qx("mkdir $tmpdir");
	open(RESUME,">>resume.bat"); print RESUME "perl functions.pl resume $tmpdir\n"; close(RESUME);
	open(PARAMETERS,">$tmpdir/parameters.txt"); for ($i=0;$i<=$#ARGV;++$i) {print PARAMETERS "$ARGV[$i]\n";} close(PARAMETERS);
	getlock("control.jobs");
	open(JOBFILE, ">>control.jobs");
	print JOBFILE "perl functions.pl xva $tmpdir\n";
	print JOBFILE "perl functions.pl xvb $tmpdir\n";
	print JOBFILE "perl functions.pl xvcrf1 $tmpdir\n";
	print JOBFILE "perl functions.pl xvcrf2 $tmpdir\n";
	print JOBFILE "perl functions.pl xvd $tmpdir\n";
	close(JOBFILE);
	removelock("control.jobs");
	print "encode job $tmpdir set up\n";
} # xvid_crf2
sub xvid_crf3 {
	$tmpdir=int(rand(1000000)); qx("mkdir $tmpdir");
	open(RESUME,">>resume.bat"); print RESUME "perl functions.pl resume $tmpdir\n"; close(RESUME);
	open(PARAMETERS,">$tmpdir/parameters.txt"); for ($i=0;$i<=$#ARGV;++$i) {print PARAMETERS "$ARGV[$i]\n";} close(PARAMETERS);
	getlock("control.jobs");
	open(JOBFILE, ">>control.jobs");
	print JOBFILE "perl functions.pl xva $tmpdir\n";
	print JOBFILE "perl functions.pl xvb $tmpdir\n";
	print JOBFILE "perl functions.pl xvcrf1 $tmpdir\n";
	print JOBFILE "perl functions.pl xvcrf3 $tmpdir\n";
	print JOBFILE "perl functions.pl xvd $tmpdir\n";
	close(JOBFILE);
	removelock("control.jobs");
	print "encode job $tmpdir set up\n";
} # xvid_crf3
######## GUI
sub gui_xvid {
	## defaults:
	$input="default.avs"; $output="default.mp4"; $outsize=700; $cpus=2;
	$options{'default'}='-max_bframes 2';
	$options{'extreme'}='-max_bframes 2 -quality 6 -vhqmode 4 -bvhq';
	$options{'high'}='-max_bframes 2 -quality 6 -vhqmode 1';

	$options264{'default'}='-b 2';
	$options264{'extreme'}='-b 2 -r 15 -m 7';
	$options264{'high'}='-b 2 -m 6';

	$modes{'xvid_2pass_size'}='perl functions.pl xvid -j global.jobs -m CPUTOTAL -s SIZE -p "EFFORT" -q "EFFORT"';
	$modes{'xvid_2pass_bitrate'}='perl functions.pl xvid -j global.jobs -m CPUTOTAL -b RATE -p "EFFORT" -q "EFFORT"';
	$modes{'xvid_2pass_crf'}='perl functions.pl xvid_crf2 -j global.jobs -m CPUTOTAL -r CRF -p "EFFORT" -q "EFFORT"';
	$modes{'xvid_crf_size'}='perl functions.pl xvid_crf3 -j global.jobs -m CPUTOTAL -s SIZE -p "EFFORT" -q "EFFORT"';
	$modes{'xvid_crf_bitrate'}='perl functions.pl xvid_crf3 -j global.jobs -m CPUTOTAL -b RATE -p "EFFORT" -q "EFFORT"';
	$modes{'x264_crf'}='perl functions.pl x264crf -j global.jobs -m CPUTOTAL -r CRF -p "EFF264" -q "EFF264"';
	$modes{'x264_abr_bitrate'}='perl functions.pl x264abr -j global.jobs -m CPUTOTAL -b RATE -p "EFF264" -q "EFF264"';
	$modes{'x264_2pass_bitrate'}='perl functions.pl x264_2 -j global.jobs -m CPUTOTAL -b RATE -p "EFF264" -q "EFF264"';
	$modes{'x264_2pass_size'}='perl functions.pl x264_3 -j global.jobs -m CPUTOTAL -s SIZE -p "EFF264" -q "EFF264"';
	$modes{'x264_3pass_bitrate'}='perl functions.pl x264_2 -j global.jobs -m CPUTOTAL -b RATE -p "EFF264" -q "EFF264"';
	$modes{'x264_3pass_size'}='perl functions.pl x264_3 -j global.jobs -m CPUTOTAL -s SIZE -p "EFF264" -q "EFF264"';

	$modes{'xvid_autores_size'}='perl functions.pl autores -j global.jobs -s SIZE';
	$modes{'xvid_autores_bitrate'}='perl functions.pl autores -j global.jobs -b RATE';
## n0153: size, bitrate and qp
## theora: size and bitrate
## snow: size and bitrate
## 

	##TODO: read settings if available

	## frames
	$top=MainWindow->new();
	$frame1_=$top->Frame();
	$frame1a=$top->Frame();
	$frame1b=$top->Frame();
	$frame2=$top->Frame();
	$frame3=$top->Frame();
	$frame1_->pack(-side => "top", -expand => "no", -fill => "both");
	$frame1a->pack(-side => "top", -expand => "no", -fill => "both");
	$frame1b->pack(-side => "top", -expand => "no", -fill => "both");
	$frame2->pack(-side => "top", -expand => "no", -fill => "both");
	$frame3->pack(-side => "bottom", -expand => "no", -fill => "both");

	## elements
	$frame1_->Label(-text => "This GUI is highly experimental. Use at your own risk.")->pack(-side => "left");
	$frame1a->Entry(-textvariable => \$input)->pack(-side => "right");
	$frame1a->Label(-text => "Input path to .avs source:")->pack(-side => "left");
	$frame1b->Entry(-textvariable => \$output)->pack(-side => "right");
	$frame1b->Label(-text => "Output path to .mp4 destination:")->pack(-side => "left");
	$Sizescale1=$frame2->Scale(-label => "Output size in MBytes", -from => 1, -to => 2000, -orient => "horizontal", -command => sub {$outsize=$Sizescale1->get(); gui_xvid_showline()})->pack(-side => "top", -expand => "no", -fill => "both");
	$Sizescale2=$frame2->Scale(-label => "Bitrate in kbit/s", -from => 100, -to => 8000, -orient => "horizontal", -command => sub {$bitrate=$Sizescale2->get(); gui_xvid_showline()})->pack(-side => "top", -expand => "no", -fill => "both");
	$Sizescale3=$frame2->Scale(-label => "Quality (crf in x264 scale)", -from => 1, -to => 50, -orient => "horizontal", -command => sub {$crf=$Sizescale3->get(); gui_xvid_showline()})->pack(-side => "top", -expand => "no", -fill => "both");
	$CPUnum=$frame2->Scale(-label => "Number of CPUs (SMP)", -from => 1, -to => 8, -orient => "vertical", -command => sub {$cpus=$CPUnum->get(); gui_xvid_showline()})->pack(-side => "left");
	$CPUtot=$frame2->Scale(-label => "Number of CPUs (total)", -from => 2, -to => 32, -orient => "vertical", -command => sub {$cputot=$CPUtot->get(); gui_xvid_showline()})->pack(-side => "left");
	$Listbox=$frame2->ScrlListbox(-label => "encoding effort", -selectmode => "single", -exportselection => 0)->pack(-side => "right");
	foreach $key (keys %options) {$Listbox->insert("end", $key);}
	$Listbox->selection("set",0);
	$Listbox2=$frame2->ScrlListbox(-label => "encoding mode", -selectmode => "single", -exportselection => 0)->pack(-side => "right");
	foreach $key (keys %modes) {$Listbox2->insert("end", $key);}
	$Listbox2->selection("set",0);

	$frame3->Label(-textvariable => \$cli)->pack(-side => "bottom");
	$frame3->Button(-text=>"quit GUI", -command=>sub{gui_save_settings(); exit})->pack(-side => "left");
	$frame3->Button(-text=>"reset SMP and cluster", -command=> \&gui_xvid_reset)->pack(-side => "left");
	$frame3->Button(-text=>"start SMP", -command=> \&gui_xvid_start)->pack(-side => "left");
	$frame3->Button(-text=>"add job to queue", -command => \&gui_xvid_apply)->pack(-side => "right");
	$frame3->Button(-text=>"view command line", -command => \&gui_xvid_showline)->pack(-side => "right");

	gui_xvid_showline(); MainLoop;
} # gui_xvid
sub gui_save_settings {
	#TODO: put  $input, $output, $cpus, $cputot, $outsize, $bitrate, $crf, ... into %config
	open(PROJECTFILE, ">gui.config"); while (($key,$val)=each %config) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
	open(PROJECTFILE, ">gui_modes.config"); while (($key,$val)=each %modes) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
	open(PROJECTFILE, ">gui_options.config"); while (($key,$val)=each %options) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
	open(PROJECTFILE, ">gui_options264.config"); while (($key,$val)=each %options264) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
} # gui_save_settings()
sub gui_xvid_start {
	open(INFO,">global.jobs"); print INFO "pause\n"; close(INFO);
	open(INFO,">control.jobs"); print INFO "\n"; close(INFO);
	@ARGV=($cpus,"global.jobs"); spawn();
	@ARGV=(1,"control.jobs"); spawnmax();
} # gui_xvid_start
sub gui_xvid_reset {shutdown_();} # gui_xvid_reset
sub gui_xvid_apply {
	gui_xvid_showline();
#	$avsname="999".int(rand(1000000)).".avs";
#	open(AVSFILE,">$avsname"); print AVSFILE "avisource(\"$input\")\n"; close(AVSFILE);
	system($cli) if (($input ne "") && ($output ne "") && (-e $input)); ## add error message if file does not exist
	$input=""; $output="";
} # gui_xvid_apply
sub gui_xvid_showline {
	$bytesize=1024*1024*$outsize;
	$effort=$options{$Listbox->Getselected()};
	$effort264=$options264{$Listbox->Getselected()};
#	@lineinfo=split(/\./,$output); $suffix=$lineinfo[$#lineinfo]; if (($suffix ne "mp4") && ($output ne "")) {$output.=".mp4";}
	# put the cli with placeholders in the hash => sed SIZE, RATE, CRF, EFFORT, EFFORT264, CPUTOTAL
	$cli=$modes{$Listbox2->Getselected()};
	$cli =~ s/SIZE/$bytesize/g; $cli =~ s/RATE/$bitrate/g; $cli =~ s/CRF/$crf/g;
	$cli =~ s/EFFORT/$effort/g; $cli =~ s/EFF264/$effort264/g;
	$cli =~ s/CPUTOTAL/$cputot/g;
	$cli.=" -a \"$input\" -o \"$output\"";  ## hack because sed fails on $cli =~ s/INPUT/$input/; $cli =~ s/OUTPUT/$output/; 
} # gui_xvid_showline
######## encoding modes
sub elder_usage {print "parameters: [-compaq] [-f frames] \n"; exit 1;}
sub pass_xva {
	# read command line & initialize defaults
	$tmpdir=$ARGV[0]; open(PARAMETERS,"$tmpdir/parameters.txt"); @params=<PARAMETERS>; close(PARAMETERS);
	for ($i=0;$i<$#params+1;++$i) {chop $params[$i];}; @ARGV=@params;
	$default_options="-max_bframes 2"; get_parameters(); handle_jobqueue();
	$config{'chunks'}=16 if ($config{'chunks'}==0);
	$config{'starttime'}=time();
	get_frames_fps_resolution();
	computechunks(); $chunks=$config{'chunks'};
	$chunksize=$config{'frames'}/$config{'chunks'}; $avgchunk=round($chunksize);
	print "using $config{'maxpar'} threads to encode $chunks chunks of about $avgchunk frames\n";
	print "warning: less chunks than available threads!\n" if ($config{'maxpar'}>$config{'chunks'});
	compute_Aranges();

	### check for bitrate or size; if both are specified size gets preferred
	exit(1) if ($config{'fps'}==0); ## TODO: error message + shut down task nicely
	if ($config{'totalbytes'} eq "0") {$config{'totalbytes'}=round($config{'totalbitrate'}*128*$config{'frames'}/$config{'fps'});}
	$mbytes=int(100*$config{'totalbytes'}/1024/1024)/100; print "target size is $config{'totalbytes'} bytes ($mbytes MB)\n";

	### generate avsstub
	push(@avsstub,"import(\"$config{'source'}\")\n"); $trimindex=1;

	## add Ajobs to queue & write jobfile for stage A
	open(JOBLIST,">>$config{'jobqueue'}");
	for ($i=0;$i<$config{"chunks"};++$i) {
		$avsstub[$trimindex]="trim($stageAjobs[$i*2],$stageAjobs[$i*2+1])\n";
		$filename=$tmpdir."/stageA-".$i.".avs"; open(INFO,">$filename"); print INFO @avsstub; close(INFO);
		$filename=$tmpdir."/stageA-".$i.".bat"; open(INFO,">$filename");
		print INFO "cd $tmpdir\nstart /belownormal /B /wait $config{'pathtoencraw'} -i stageA-$i.avs -type 2 -pass1 stageA-$i.stats -o $config{'nul'} $config{'pass1opts'}\n$config{'touch'} stageA-result$i.ready\n";
		close(INFO); print JOBLIST "$tmpdir\\stageA-$i.bat\n"; # OS?
	}
	print JOBLIST "pause\n"; close(JOBLIST);

	print "stage A jobs issued\n";

	## write project data
	open(PROJECTFILE, ">$tmpdir/projecthash.txt"); while (($key,$val)=each %config) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
	open(STAGEAJOBS,">$tmpdir/stageA.jobs"); for ($i=0;$i<=$#stageAjobs;$i++) {print STAGEAJOBS "$stageAjobs[$i]\n";}; close(STAGEAJOBS);

	if ($config{'local'}) {
		@ARGV=($config{'maxpar'},$config{'jobqueue'}); spawn();
#		for ($i=0;$i<$config{'maxpar'};++$i){print "starting process $i\n"; system("start /min perl pick_job.pl $config{'jobqueue'} &" or die "couldn't exec $!");}
	}
} # pass_xva
sub pass_xvb {
	$tmpdir=$ARGV[0];
	open(STAGEAJOBS,"$tmpdir/stageA.jobs"); @stageAjobs=<STAGEAJOBS>; close(STAGEAJOBS);
	for ($i=0;$i<=$#stageAjobs;++$i) {chop $stageAjobs[$i];};
	open(PROJECTFILE,"$tmpdir/projecthash.txt"); @datatmp=<PROJECTFILE>; close(PROJECTFILE);
	while ($#datatmp>0) {($key,$val,@datatmp)=@datatmp; chop($key); chop($val); $config{$key}=$val;}
	print "collecting stage A results ($config{'chunks'} chunks in total)\n";
	#wait for all chunks
	for ($i=0;$i<$config{'chunks'};++$i) {
		$filename="$tmpdir/stageA-result$i.ready"; do {sleep(1);} while !(-e $filename);
		$chunknum=$i+1; $progress=int(100*$chunknum/$config{'chunks'});
		$passed=time()-$config{'starttime'};
		$framessofar=$stageAjobs[2*$i+1]+1;
		print "stage A progress: $chunknum/$config{'chunks'} chunks done ($progress%) in $passed seconds. $framessofar frames so far.\n";
	}
	print "stage A import done\n";
	
	# generate avsstub
	push(@avsstub,"import(\"$config{'source'}\")\n"); $trimindex=1;

	#issue stage B jobs
	$trimindex=1; $chunks=$config{'chunks'};
	
	open(INFO,"$tmpdir/stageA-0.stats"); @lines=<INFO>; close(INFO);
	for ($i=0;$i<3;++$i) {push(@statsheader,$lines[$i]);}
	for ($i=3;$i<1+$#lines;++$i) {push(@globalstats,$lines[$i]);}
	for ($i=1;$i<$chunks;++$i) {
		open(INFO,"$tmpdir/stageA-$i.stats"); @lines=<INFO>; close(INFO);
		for ($j=3;$j<1+$#lines;++$j) {push(@globalstats,$lines[$j]);}
		$prevlinenum=$stageAjobs[2*$i -1];
		do {--$prevlinenum; $line=$globalstats[$prevlinenum]; @lineinfo=split(/ /,$line);} until ($lineinfo[0] eq "i");
		push(@stageBjobs,$prevlinenum);
		$currentlinenum=$stageAjobs[2*$i]-1;
		do {++$currentlinenum; $line=$globalstats[$currentlinenum]; @lineinfo=split(/ /,$line);} until ($lineinfo[0] eq "i");
		push(@stageBjobs,$currentlinenum-1);
		$avsstub[$trimindex]="trim($stageBjobs[$i*2-2],$stageBjobs[$i*2-1])\n";
		$filename=$tmpdir."/stageB-".$i.".avs"; open(INFO,">$filename"); print INFO @avsstub; close(INFO);
		$filename=$tmpdir."/stageB-".$i.".bat"; open(INFO,">$filename");
		print INFO "cd $tmpdir\nstart /belownormal /B /wait $config{'pathtoencraw'} -i stageB-$i.avs -type 2 -pass1 stageB-$i.stats -o $config{'nul'} $config{'pass1opts'}\n$config{'touch'} stageB-result$i.ready\n";
		close(INFO);
		open(JOBLIST,">>$config{'jobqueue'}"); print JOBLIST "$tmpdir\\stageB-$i.bat\n"; close(JOBLIST);
	}

	### write globalstats
	open(GLOBALSTATS,">$tmpdir/global.stats"); for ($i=0;$i<=$#globalstats;$i++) {print GLOBALSTATS "$globalstats[$i]";}; close(GLOBALSTATS);
	open(STAGEBJOBS,">$tmpdir/stageB.jobs"); for ($i=0;$i<=$#stageBjobs;$i++) {print STAGEBJOBS "$stageBjobs[$i]\n";}; close(STAGEBJOBS);
	open(PROJECTFILE, ">$tmpdir/projecthash.txt"); while (($key,$val)=each %config) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);

	print "stage B jobs issued\n";
} # pass_xvb
sub pass_xvc {
	$tmpdir=$ARGV[0];
	open(STAGEAJOBS,"$tmpdir/stageA.jobs"); @stageAjobs=<STAGEAJOBS>; close(STAGEAJOBS);
	for ($i=0;$i<=$#stageAjobs;++$i) {chop $stageAjobs[$i];};
	open(STAGEBJOBS,"$tmpdir/stageB.jobs"); @stageBjobs=<STAGEBJOBS>; close(STAGEBJOBS);
	for ($i=0;$i<=$#stageBjobs;++$i) {chop $stageBjobs[$i];};
	open(PROJECTFILE,"$tmpdir/projecthash.txt"); @datatmp=<PROJECTFILE>; close(PROJECTFILE);
	while ($#datatmp>0) {($key,$val,@datatmp)=@datatmp; chop($key); chop($val); $config{$key}=$val;}
	open(GLOBALSTATS,"$tmpdir/global.stats"); @globalstats=<GLOBALSTATS>; close(GLOBALSTATS);
	### wait for encoding of stage B to complete
	$chunks_1=$config{'chunks'}-1;
	print "collecting stage B results ($chunks_1 chunks in total)\n";
	for ($i=1;$i<$config{'chunks'};++$i) {
		do {sleep(1)} until(-e "$tmpdir/stageB-result$i.ready");
		$chunknum=$i; $progress=int(100*$chunknum/$chunks_1);
		$passed=time()-$config{'starttime'};
		$framessofar=$stageBjobs[2*$i-1]+1;
		print "stage B progress: $chunknum/$chunks_1 chunks done ($progress%) in $passed seconds. $framessofar frames so far.\n";
	}
	print "stage B completed\n";

	### read in stats files from each chunk of stage B
	for ($j=1;$j<$chunks_1;++$j) {
		open(INFO,"$tmpdir/stageB-$j.stats"); @lines=<INFO>; close(INFO);
		for ($i=3;$i<1+$#lines;++$i) {$globalstats[$stageBjobs[2*$j]+$i-4]=$lines[$i];}
	}

	### read in statsheader
	open(INFO,"$tmpdir/stageA-0.stats"); for ($i=0;$i<3;++$i) {push(@statsheader,<INFO>);} close(INFO);

	### compute total size
	$totalsize=0; for ($i=0;$i<1+$#globalstats;++$i) {@lineinfo=split(/ /,$globalstats[$i]); $totalsize+=$lineinfo[5];}
	$config{'totalsize'}=$totalsize;

	### write globalstats
	open(GLOBALSTATS,">$tmpdir/global.stats"); for ($i=0;$i<=$#globalstats;$i++) {print GLOBALSTATS "$globalstats[$i]";}; close(GLOBALSTATS);
	open(PROJECTFILE, ">$tmpdir/projecthash.txt"); while (($key,$val)=each %config) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
	print "stage B imported\n"; print_1passtime();

	### compute ranges of stage C
	push(@stageCjobs,0);
	for ($i=1;$i<$config{'chunks'};++$i) {
		$currentlinenum=$stageAjobs[2*$i]-1;
		do {++$currentlinenum; $line=$globalstats[$currentlinenum]; @lineinfo = split(/ /,$line);} until ($lineinfo[0] eq "i");
		push(@stageCjobs,$currentlinenum-1); push(@stageCjobs,$currentlinenum);
	}
	chomp($stageAjobs[2*$config{'chunks'}-1]); push(@stageCjobs,$stageAjobs[2*$config{'chunks'}-1]);
	open(STAGECJOBS,">$tmpdir/stageC.jobs"); for ($i=0;$i<=$#stageCjobs;$i++) {print STAGECJOBS "$stageCjobs[$i]\n";}; close(STAGECJOBS);

	### compute bitrate of each chunk of stage C
	for ($i=0;$i<$config{'chunks'};++$i) {
		$filename="$tmpdir/stageC-$i.stats"; open(INFO,">$filename"); print INFO @statsheader; $chunksize=0;
		for ($j=$stageCjobs[2*$i];$j<1+$stageCjobs[1+2*$i];++$j) {
			print INFO "$globalstats[$j]"; @lineinfo=split(/ /,$globalstats[$j]); $chunksize+=$lineinfo[5];
		}
		close(INFO);
		$chunktarget=($config{'totalbytes'}*$chunksize)/$config{'totalsize'};
		$chunkframes=$stageCjobs[1+2*$i]-$stageCjobs[2*$i]+1;
		$chunkrate=round($magicfactor*(8*$config{'fps'}*$chunktarget)/(1024*$chunkframes));
		push(@targetrate, $chunkrate);
	}

	# generate avsstub
	push(@avsstub,"import(\"$config{'source'}\")\n"); $trimindex=1;

	### write jobs of stage C
	open(JOBLIST,">>$config{'jobqueue'}");
	for ($i=0;$i<$config{'chunks'};++$i)
	{
		$avsstub[$trimindex]="trim($stageCjobs[$i*2],$stageCjobs[$i*2+1])\n";
		$filename=$tmpdir."/stageC-".$i.".avs"; open(INFO,">$filename"); print INFO @avsstub;
		close(INFO); $filename=$tmpdir."/stageC-".$i.".bat"; open(INFO,">$filename");
		$rate=int(1024*$targetrate[$i]*$magicfactor);
		print INFO "cd $tmpdir\nstart /belownormal /B /wait $config{'pathtoencraw'} -i stageC-$i.avs -type 2 -pass2 stageC-$i.stats -bitrate $rate -o test$i.m4v $config{'pass2opts'}\n$config{'touch'} stageC-result$i.ready\n";
		close(INFO); print JOBLIST "$tmpdir\\stageC-$i.bat\n"; # OS?
	}
	close(JOBLIST);

	$config{'starttime_pass2'}=time();
	open(PROJECTFILE, ">$tmpdir/projecthash.txt"); while (($key,$val)=each %config) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
	print "stage C jobs issued\n";
} # pass_xvc
sub pass_xvd {
	$tmpdir=$ARGV[0]; open(PROJECTFILE,"$tmpdir/projecthash.txt"); @datatmp=<PROJECTFILE>; close(PROJECTFILE);
	while ($#datatmp>0) {($key,$val,@datatmp)=@datatmp; chop($key); chop($val); $config{$key}=$val;}
	open(STAGECJOBS,"$tmpdir/stageC.jobs"); @stageCjobs=<STAGECJOBS>; close(STAGECJOBS);
	for ($i=0;$i<=$#stageCjobs;++$i) {chop $stageCjobs[$i];};

	print "collecting stage C results ($config{'chunks'} chunks in total)\n";
	for ($i=0;$i<$config{'chunks'};++$i) {
		do {sleep(1)} until(-e "$tmpdir/stageC-result$i.ready");
		$copycommand="type $tmpdir/test$i.m4v >>$tmpdir/final.m4v"; $copycommand=~ s/\//\\/g; # OS?
		system($copycommand); unlink("$tmpdir/test$i.m4v");
		$chunknum=$i+1; $progress=int(100*$chunknum/$config{'chunks'});
		$passed=time()-$config{'starttime'};
		$framessofar=$stageCjobs[2*$i+1]+1;
		print "stage C progress: $chunknum/$config{'chunks'} chunks done ($progress%) in $passed seconds. $framessofar frames so far.\n";
	}
	print "stage C completed\n";
	print_2passtime();
	print_totaltime();
	print "now merging the chunks...\n";
	if ($config{'local'}) {open(JOBLIST,">>$config{'jobqueue'}"); print JOBLIST "quit\n"; close(JOBLIST);};
	muxasp(); compare_outputsize();
	unlink("$tmpdir/final.m4v");
	print "another job well done\n";
} # pass_xvd
sub pass_xvcrf1 {
	$tmpdir=$ARGV[0];
	open(STAGEAJOBS,"$tmpdir/stageA.jobs"); @stageAjobs=<STAGEAJOBS>; close(STAGEAJOBS);
	for ($i=0;$i<=$#stageAjobs;++$i) {chop $stageAjobs[$i];};
	open(STAGEBJOBS,"$tmpdir/stageB.jobs"); @stageBjobs=<STAGEBJOBS>; close(STAGEBJOBS);
	for ($i=0;$i<=$#stageBjobs;++$i) {chop $stageBjobs[$i];};
	open(PROJECTFILE,"$tmpdir/projecthash.txt"); @datatmp=<PROJECTFILE>; close(PROJECTFILE);
	while ($#datatmp>0) {($key,$val,@datatmp)=@datatmp; chop($key); chop($val); $config{$key}=$val;}
	open(GLOBALSTATS,"$tmpdir/global.stats"); @globalstats=<GLOBALSTATS>; close(GLOBALSTATS);

	### wait for encoding of stage B to complete
	$chunks_1=$config{'chunks'}-1; print "collecting stage B results ($chunks_1 chunks in total)\n";
	for ($i=1;$i<$config{'chunks'};++$i) {
		do {sleep(1)} until(-e "$tmpdir/stageB-result$i.ready");
		$chunknum=$i; $progress=int(100*$chunknum/$chunks_1);
		$passed=time()-$config{'starttime'};
		$framessofar=$stageBjobs[2*$i-1]+1;
		print "stage B progress: $chunknum/$chunks_1 chunks done ($progress%) in $passed seconds. $framessofar frames so far.\n";
	}
	print "stage B completed\n";

	### read in stats files from each chunk of stage B
	for ($j=1;$j<$chunks_1;++$j) {
		open(INFO,"$tmpdir/stageB-$j.stats"); @lines=<INFO>; close(INFO);
		for ($i=3;$i<1+$#lines;++$i) {$globalstats[$stageBjobs[2*$j]+$i-4]=$lines[$i];}
	}

	### read in statsheader
	open(INFO,"$tmpdir/stageA-0.stats"); for ($i=0;$i<3;++$i) {push(@statsheader,<INFO>);} close(INFO);

	### compute total size
	$totalsize=0; for ($i=0;$i<1+$#globalstats;++$i) {@lineinfo=split(/ /,$globalstats[$i]); $totalsize+=$lineinfo[5];}
	$config{'totalsize'}=$totalsize;

	### write globalstats
	open(GLOBALSTATS,">$tmpdir/global.stats"); for ($i=0;$i<=$#globalstats;$i++) {print GLOBALSTATS "$globalstats[$i]";}; close(GLOBALSTATS);
	open(PROJECTFILE, ">$tmpdir/projecthash.txt"); while (($key,$val)=each %config) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
	print "stage B imported\n"; print_1passtime();

	### compute ranges of stage C
	push(@stageCjobs,0);
	for ($i=1;$i<$config{'chunks'};++$i) {
		$currentlinenum=$stageAjobs[2*$i]-1;
		do {++$currentlinenum; $line=$globalstats[$currentlinenum]; @lineinfo = split(/ /,$line);} until ($lineinfo[0] eq "i");
		push(@stageCjobs,$currentlinenum-1); push(@stageCjobs,$currentlinenum);
	}
	chomp($stageAjobs[2*$config{'chunks'}-1]); push(@stageCjobs,$stageAjobs[2*$config{'chunks'}-1]);

	# generate avsstub
	push(@avsstub,"import(\"$config{'source'}\")\n"); $trimindex=1;

	### write stage C stats files
	for ($i=0;$i<$config{'chunks'};++$i) {
		$filename="$tmpdir/stageC-$i.stats"; open(INFO,">$filename"); print INFO @statsheader;
		for ($j=$stageCjobs[2*$i];$j<=$stageCjobs[1+2*$i];++$j) {print INFO "$globalstats[$j]";}
		close(INFO);
	}

	### write jobs of stage C
	open(JOBLIST,">>$config{'jobqueue'}");
	for ($i=0;$i<$config{'chunks'};++$i)
	{
		$avsstub[$trimindex]="trim($stageCjobs[$i*2],$stageCjobs[$i*2+1])\n";
		$filename=$tmpdir."/stageC1-".$i.".avs"; open(INFO,">$filename"); print INFO @avsstub;
		close(INFO); $filename=$tmpdir."/stageC1-".$i.".bat"; open(INFO,">$filename");
		print INFO "cd $tmpdir\nstart /belownormal /B /wait $config{'pathtox264'} --progress --crf $config{'crfvalue'} -p 1 -o stageC1-$i.264 -b 2 -m 3 -A none stageC1-$i.avs\n$config{'touch'} stageC1-result$i.ready\n";
		close(INFO); print JOBLIST "$tmpdir\\stageC1-$i.bat\n"; # OS?
	}
	close(JOBLIST);

	$config{'starttime_pass2'}=time();
	open(PROJECTFILE, ">$tmpdir/projecthash.txt"); while (($key,$val)=each %config) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
	open(STAGECJOBS,">$tmpdir/stageC.jobs"); for ($i=0;$i<=$#stageCjobs;$i++) {print STAGECJOBS "$stageCjobs[$i]\n";}; close(STAGECJOBS);

	print "stage C1 jobs issued\n";
} # pass_xvcrf1
sub pass_xvcrf2 {
	$tmpdir=$ARGV[0];
	open(STAGECJOBS,"$tmpdir/stageC.jobs"); @stageCjobs=<STAGECJOBS>; close(STAGECJOBS);
	for ($i=0;$i<=$#stageCjobs;++$i) {chop $stageCjobs[$i];};
	open(PROJECTFILE,"$tmpdir/projecthash.txt"); @datatmp=<PROJECTFILE>; close(PROJECTFILE);
	while ($#datatmp>0) {($key,$val,@datatmp)=@datatmp; chop($key); chop($val); $config{$key}=$val;}
	open(GLOBALSTATS,"$tmpdir/global.stats"); @globalstats=<GLOBALSTATS>; close(GLOBALSTATS);

	print "collecting Stage C1 results ($config{'chunks'} chunks in total)\n";
	### read first pass chunk sizes
	$totalfirstpasssize=0;
	for ($i=0;$i<$config{'chunks'};++$i) {
		$filename="$tmpdir/stageC1-result$i.ready"; do {sleep(1);} while !(-e $filename);
		$chunknum=$i+1; $progress=int(100*$chunknum/$config{'chunks'});
		$passed=time()-$config{'starttime'};
		$framessofar=$stageCjobs[2*$i+1]+1;
		print "stage C1 progress: $chunknum/$config{'chunks'} chunks done ($progress%) in $passed seconds. $framessofar frames so far.\n";
		$filename="$tmpdir/stageC1-$i.264"; $chunksize=(-s $filename);
		push(@firstpasssize,$chunksize); $totalfirstpasssize+=$chunksize;
	}

	$config{'totalbytes'}=$totalfirstpasssize; # this is the reference for size comparison

	print "Stage C generating jobs\n";
	for ($i=0;$i<$config{'chunks'};++$i) {
		$chunktarget=$firstpasssize[$i];
		$chunkframes=$stageCjobs[1+2*$i]-$stageCjobs[2*$i]+1;
		$chunkrate=round((8/1024*$config{'fps'}*$chunktarget)/($chunkframes));
		push(@targetrate,$chunkrate);
	}

	### write jobs of stage C
	open(JOBLIST,">>$config{'jobqueue'}");
	for ($i=0;$i<$config{'chunks'};++$i) {
		$filename=$tmpdir."/stageC-".$i.".bat"; open(INFO,">$filename");
		$rate=int(1024*$targetrate[$i]*$magicfactor);
		print INFO "cd $tmpdir\nstart /belownormal /B /wait $config{'pathtoencraw'} -i stageC1-$i.avs -type 2 -pass2 stageC-$i.stats -bitrate $rate -o test$i.m4v $config{'pass2opts'}\n$config{'touch'} stageC-result$i.ready\n";
		close(INFO); print JOBLIST "$tmpdir\\stageC-$i.bat\n"; # OS?
	}
	close(JOBLIST);

	open(PROJECTFILE, ">$tmpdir/projecthash.txt"); while (($key,$val)=each %config) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
	for ($i=0;$i<$config{'chunks'};++$i) {$filename="$tmpdir/stageC1-$i.264"; unlink($filename);}
	print "stage C jobs issued\n";
} # pass_xvcrf2
sub pass_xvcrf3 {
	$tmpdir=$ARGV[0];
	open(STAGECJOBS,"$tmpdir/stageC.jobs"); @stageCjobs=<STAGECJOBS>; close(STAGECJOBS);
	for ($i=0;$i<=$#stageCjobs;++$i) {chop $stageCjobs[$i];};
	open(PROJECTFILE,"$tmpdir/projecthash.txt"); @datatmp=<PROJECTFILE>; close(PROJECTFILE);
	while ($#datatmp>0) {($key,$val,@datatmp)=@datatmp; chop($key); chop($val); $config{$key}=$val;}
	open(GLOBALSTATS,"$tmpdir/global.stats"); @globalstats=<GLOBALSTATS>; close(GLOBALSTATS);

	print "collecting Stage C1 results ($config{'chunks'} chunks in total)\n";
	### read first pass chunk sizes
	$totalfirstpasssize=0;
	for ($i=0;$i<$config{'chunks'};++$i)
	{
		$filename="$tmpdir/stageC1-result$i.ready"; do {sleep(1);} while !(-e $filename);
		$chunknum=$i+1; $progress=int(100*$chunknum/$config{'chunks'});
		$passed=time()-$config{'starttime'};
		$framessofar=$stageCjobs[2*$i+1]+1;
		print "stage C1 progress: $chunknum/$config{'chunks'} chunks done ($progress%) in $passed seconds. $framessofar frames so far.\n";
		$filename="$tmpdir/stageC1-$i.264"; $chunksize=(-s $filename);
		push(@firstpasssize,$chunksize); $totalfirstpasssize+=$chunksize;
	}

	print "Stage C generating jobs\n";
	### compute bitrate of each chunk of stage C
	for ($i=0;$i<$config{'chunks'};++$i)
	{
		$chunktarget=($firstpasssize[$i]*$config{'totalbytes'})/($totalfirstpasssize);
		$chunkframes=$stageCjobs[1+2*$i]-$stageCjobs[2*$i]+1;
		$chunkrate=round((8/1024*$config{'fps'}*$chunktarget)/($chunkframes));
		push(@targetrate,$chunkrate);
	}

	### write jobs of stage C
	open(JOBLIST,">>$config{'jobqueue'}");
	for ($i=0;$i<$config{'chunks'};++$i)
	{
		$filename=$tmpdir."/stageC-".$i.".bat"; open(INFO,">$filename");
		$rate=int(1024*$targetrate[$i]*$magicfactor);
		print INFO "cd $tmpdir\nstart /belownormal /B /wait $config{'pathtoencraw'} -i stageC1-$i.avs -type 2 -pass2 stageC-$i.stats -bitrate $rate -o test$i.m4v $config{'pass2opts'}\n$config{'touch'} stageC-result$i.ready\n";
		close(INFO); print JOBLIST "$tmpdir\\stageC-$i.bat\n"; # OS?
	}
	close(JOBLIST);

	open(PROJECTFILE, ">$tmpdir/projecthash.txt"); while (($key,$val)=each %config) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);

	## delete first pass .264 files
	for ($i=0;$i<$config{'chunks'};++$i) {$filename="$tmpdir/stageC1-$i.264"; unlink($filename);}
	print "stage C jobs issued\n";
} # pass_xvcrf3
sub pass_a {
	$tmpdir=$ARGV[0]; open(PARAMETERS,"$tmpdir/parameters.txt"); @params=<PARAMETERS>; close(PARAMETERS);
	for ($i=0;$i<$#params+1;++$i) {chop $params[$i];}; @ARGV=@params;
	$default_options="-b 2 -m 3"; get_parameters(); handle_jobqueue();
	$config{'chunks'}=16 if ($config{'chunks'}==0);
	$config{'starttime'}=time();
	get_frames_fps_resolution();
	filecopy("$config{'source'}","$tmpdir/source.avs");

	computechunks(); $chunks=$config{'chunks'};
	$chunksize=$config{'frames'}/$config{'chunks'}; $avgchunk=round($chunksize);
	print "using $config{'maxpar'} threads to encode $chunks chunks of about $avgchunk frames\n";
	print "warning: less chunks than available threads!\n" if ($config{'maxpar'}>$config{'chunks'});
	compute_Aranges();

	### check for bitrate or size; if both are specified size gets preferred
	if ($config{'totalbytes'} eq "0") {$config{'totalbytes'}=round($config{'totalbitrate'}*128*$config{'frames'}/$config{'fps'});}
	$mbytes=int(100*$config{'totalbytes'}/1024/1024)/100; print "target size is $config{'totalbytes'} bytes ($mbytes MB)\n";

	## add Ajobs to queue & write jobfile for stage A
	open(JOBLIST,">>$config{'jobqueue'}");
	for ($i=0;$i<$config{"chunks"};++$i) {
		$seek=$stageAjobs[$i*2]; $frames_=$stageAjobs[$i*2+1]-$stageAjobs[$i*2]+1;
		$filename=$tmpdir."/stageA-".$i.".bat"; open(INFO,">$filename"); # TODO: change this line
		$command="cd $tmpdir\nstart /belownormal /B /wait $config{'pathtox264'} --progress --seek $seek --frames $frames_ --crf $config{'crfvalue'} $config{'pass1opts'} -p 1 --stats stageA-$i.stats -o stageA-$i.264 source.avs \n$config{'touch'} stageA-result$i.ready\n";
		$command =~ s/--seek 0//g; print INFO $command;
		close(INFO); print JOBLIST "$tmpdir\\stageA-$i.bat\n"; # OS?
	}
	print JOBLIST "pause\n"; close(JOBLIST);

	## write project data
	open(PROJECTFILE, ">$tmpdir/projecthash.txt"); while (($key,$val)=each %config) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
	open(STAGEAJOBS,">$tmpdir/stageA.jobs"); for ($i=0;$i<=$#stageAjobs;$i++) {print STAGEAJOBS "$stageAjobs[$i]\n";}; close(STAGEAJOBS);
	print "stage A jobs issued\n";
} # pass_a
sub pass_abr {
	$tmpdir=$ARGV[0]; open(PARAMETERS,"$tmpdir/parameters.txt"); @params=<PARAMETERS>; close(PARAMETERS);
	for ($i=0;$i<$#params+1;++$i) {chop $params[$i];}; @ARGV=@params;
	$default_options="-b 2 -m 3"; get_parameters(); handle_jobqueue();
	$config{'chunks'}=16 if ($config{'chunks'}==0);
	$config{'starttime'}=time();
	get_frames_fps_resolution();
	computechunks(); $chunks=$config{"chunks"};
	$chunksize=$config{'frames'}/$chunks; $avgchunk=round($chunksize);
	compute_Aranges();
	filecopy("$config{'source'}","$tmpdir/source.avs");

	### check for bitrate or size; if both are specified size gets preferred
	if ($config{'totalbytes'} eq "0") {$config{'totalbytes'}=round($config{'totalbitrate'}*128*$config{'frames'}/$config{'fps'});}
	$mbytes=int(100*$config{'totalbytes'}/1024/1024)/100; print "target size is $config{'totalbytes'} bytes ($mbytes MB)\n";

	### compute average abr
	$config{'abrvalue'}=int((8/1024*$config{'fps'}*$config{'totalbytes'})/$config{'frames'});
	print "abr = $config{'abrvalue'}\n";

	## add Ajobs to queue & write jobfile for stage A
	open(JOBLIST,">>$config{'jobqueue'}");
	for ($i=0;$i<$config{"chunks"};++$i) {
		$seek=$stageAjobs[$i*2]; $frames_=$stageAjobs[$i*2+1]-$stageAjobs[$i*2]+1;
		$filename=$tmpdir."/stageA-".$i.".bat"; open(INFO,">$filename"); # TODO: change this line
		$command="cd $tmpdir\nstart /belownormal /B /wait $config{'pathtox264'} --progress --seek $seek --frames $frames_ -B $config{'abrvalue'} $config{'pass1opts'} -p 1 --stats stageA-$i.stats -o stageA-$i.264 source.avs \n$config{'touch'} stageA-result$i.ready\n";
		$command =~ s/--seek 0//g; print INFO $command;
		close(INFO); print JOBLIST "$tmpdir\\stageA-$i.bat\n"; # OS?
	}
	print JOBLIST "pause\n"; close(JOBLIST);

	## write project data
	open(PROJECTFILE, ">$tmpdir/projecthash.txt"); while (($key,$val)=each %config) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
	open(STAGEAJOBS,">$tmpdir/stageA.jobs"); for ($i=0;$i<=$#stageAjobs;$i++) {print STAGEAJOBS "$stageAjobs[$i]\n";}; close(STAGEAJOBS);
} # pass_abr
sub pass_x264_c {
	$tmpdir=$ARGV[0]; open(PROJECTFILE,"$tmpdir/projecthash.txt"); @datatmp=<PROJECTFILE>; close(PROJECTFILE);
	while ($#datatmp>0) {($key,$val,@datatmp)=@datatmp; chop($key); chop($val); $config{$key}=$val;}
	open(STAGEAJOBS,"$tmpdir/stageA.jobs"); @stageAjobs=<STAGEAJOBS>; close(STAGEAJOBS);
	for ($i=0;$i<=$#stageAjobs;++$i) {chop $stageAjobs[$i];};
	print "collecting Stage A results ($config{'chunks'} chunks in total)\n";
	for ($i=0;$i<$config{'chunks'};++$i) {
		do {sleep(1)} until(-e "$tmpdir/stageA-result$i.ready");
		$chunknum=$i+1; $progress=int(100*$chunknum/$config{'chunks'}); $passed=time()-$config{'starttime'};
		$framessofar=$stageAjobs[2*$i+1]+1;
		print "stage A progress: $chunknum/$config{'chunks'} chunks done ($progress%) in $passed seconds. $framessofar frames so far.\n";
		$chunksize=(-s "$tmpdir/stageA-$i.264"); push(@firstpasssize,$chunksize); $totalfirstpasssize+=$chunksize;
	}
	print "Stage A completed\n"; print_1passtime();
	$config{'starttime_pass2'}=time();
	@stageCjobs=@stageAjobs;

	## compute bitrates per job
	for ($i=0;$i<$config{'chunks'};++$i) {
		$chunktarget=($firstpasssize[$i]*$config{'totalbytes'})/($totalfirstpasssize);
		$chunkframes=$stageCjobs[1+2*$i]-$stageCjobs[2*$i]+1;
		$chunkrate=round((8/1024*$config{'fps'}*$chunktarget)/($chunkframes));
		push(@targetrate,$chunkrate);
	}

	### write jobs of stage C
	open(JOBLIST,">>$config{'jobqueue'}");
	for ($i=0;$i<$config{'chunks'};++$i) {
		unlink("$tmpdir/stageA-result$i.ready"); unlink("$tmpdir/stageC-result$i.ready");
		$filename=$tmpdir."/stageC-".$i.".bat"; open(INFO,">$filename");
		$seek=$stageAjobs[$i*2]; $frames_=$stageAjobs[$i*2+1]-$stageAjobs[$i*2]+1;
		$rate=$targetrate[$i]; ## correction using magicfactor if needed
		print INFO "cd $tmpdir\nstart /belownormal /B /wait $config{'pathtox264'} --progress --seek $seek --frames $frames_ -B $rate -p 3 --stats stageA-$i.stats -o stageC-$i.264 $config{'pass1opts'} source.avs \n$config{'touch'} stageA-result$i.ready\n$config{'touch'} stageC-result$i.ready\n";
		close(INFO); print JOBLIST "$tmpdir\\stageC-$i.bat\n"; # OS?
	}
	close(JOBLIST);

	open(PROJECTFILE, ">$tmpdir/projecthash.txt"); while (($key,$val)=each %config) {print PROJECTFILE "$key\n$val\n";} close(PROJECTFILE);
	open(STAGECJOBS,">$tmpdir/stageC.jobs"); for ($i=0;$i<=$#stageCjobs;$i++) {print STAGECJOBS "$stageCjobs[$i]\n";}; close(STAGECJOBS);
	print "stage C jobs issued\n";
} # pass_x264_c
sub pass_d {
	$tmpdir=$ARGV[0]; open(PROJECTFILE,"$tmpdir/projecthash.txt"); @datatmp=<PROJECTFILE>; close(PROJECTFILE);
	while ($#datatmp>0) {($key,$val,@datatmp)=@datatmp; chop($key); chop($val); $config{$key}=$val;}
	open(STAGECJOBS,"$tmpdir/stageC.jobs"); @stageCjobs=<STAGECJOBS>; close(STAGECJOBS);
	for ($i=0;$i<=$#stageCjobs;++$i) {chop $stageCjobs[$i];};
	print "collecting Stage C results ($config{'chunks'} chunks in total)\n";
	for ($i=0;$i<$config{'chunks'};++$i) {
		do {sleep(1)} until(-e "$tmpdir/stageC-result$i.ready");
		$copycommand="type $tmpdir/stageC-$i.264 >>$tmpdir/final.264"; $copycommand=~ s/\//\\/g; # OS?
		system($copycommand); unlink("$tmpdir/stageC-$i.264");
		$chunknum=$i+1; $progress=int(100*$chunknum/$config{'chunks'}); $passed=time()-$config{'starttime'};
		$framessofar=$stageCjobs[2*$i+1]+1;
		print "stage C progress: $chunknum/$config{'chunks'} chunks done ($progress%) in $passed seconds. $framessofar frames so far.\n";
		#print "Stage C progress: $chunknum/$config{'chunks'} chunks done ($progress%) in $passed seconds.\n";
	}
	print "Stage C completed\n"; print_totaltime();
	if ($config{'local'}) {open(JOBLIST,">>$config{'jobqueue'}"); print JOBLIST "quit\n"; close(JOBLIST);}
	muxavc(); unlink("$tmpdir/final.264"); compare_outputsize();
	print "another job well done\n";
} # pass_d
sub pass_dcrf {
	$tmpdir=$ARGV[0]; open(PROJECTFILE,"$tmpdir/projecthash.txt"); @datatmp=<PROJECTFILE>; close(PROJECTFILE);
	while ($#datatmp>0) {($key,$val,@datatmp)=@datatmp; chop($key); chop($val); $config{$key}=$val;}
	open(STAGEAJOBS,"$tmpdir/stageA.jobs"); @stageAjobs=<STAGEAJOBS>; close(STAGEAJOBS);
	for ($i=0;$i<=$#stageAjobs;++$i) {chop $stageAjobs[$i];};
	print "collecting Stage A results ($config{'chunks'} chunks in total)\n";
	for ($i=0;$i<$config{'chunks'};++$i) {
		do {sleep(1)} until(-e "$tmpdir/stageA-result$i.ready");
		$copycommand="type $tmpdir/stageA-$i.264 >>$tmpdir/final.264"; $copycommand=~ s/\//\\/g; # OS?
		system($copycommand);
		$chunknum=$i+1; $progress=int(100*$chunknum/$config{'chunks'});
		$passed=time()-$config{'starttime'};
		$framessofar=$stageAjobs[2*$i+1]+1;
		print "stage A progress: $chunknum/$config{'chunks'} chunks done ($progress%) in $passed seconds. $framessofar frames so far.\n";
	}
	print "Stage A completed\n"; print_totaltime();
	if ($config{'local'}) {open(JOBLIST,">>$config{'jobqueue'}"); print JOBLIST "quit\n"; close(JOBLIST);};
	muxavc(); for ($i=0;$i<$config{'chunks'};++$i) {unlink("$tmpdir/stageC-$i.264");}; unlink("$tmpdir/final.264");
	compare_outputsize();
	print "another job well done\n";
} # pass_dcrf
sub ELDER4x264_c2 {
	### read from project.file
	open(PROJECTFILE,"$tmpdir/projectfile.txt"); @params=<PROJECTFILE>; close(PROJECTFILE);
	#open(AVSSTUB,"$tmpdir/avs.stub"); @avsstub=<AVSSTUB>; close(AVSSTUB);
	open(STAGEAJOBS,"$tmpdir/stageA.jobs"); @stageAjobs=<STAGEAJOBS>; close(STAGEAJOBS);
	$chunks=substr($params[1], 0, -1);
	$touch=substr($params[6], 0, -1);
	$jobqueue=substr($params[8], 0, -1);
	$totalbytes=substr($params[9], 0, -1);
	$fps=substr($params[10], 0, -1);
	$pathtox264=substr($params[12], 0, -1);
	$pass2opts=substr($params[13], 0, -1);
	#$nul = "NUL";
	
	$total_chunksize=0;
	### wait for encoding of stage A to complete and read in sizes
	for ($i = 0; $i < $chunks; ++$i) {
		do {sleep(1)} until(-e "$tmpdir/stageA-result$i.ready");
		$chunknum=1+$i; $progress=int(100*$chunknum/$chunks);
		#TODO: read in size of chunk and increase total_chunksize
		$thischunk= (-s "$tmpdir/acrfout$i.264");
		$total_chunksize += $thischunk;
		push(@chunksizes,$thischunk);
		print "##### Stage A Progress: $chunknum/$chunks chunks done ($progress%)\n";}
	print "### Stage A completed\n";
	
	print "### Stage C generating jobs\n";
	### compute bitrate of each chunk of stage C
	for ($i = 0; $i < $chunks; ++$i)
	{
		$chunktarget = ($totalbytes * $chunksizes[$i]) / $total_chunksize;
		$chunkframes = $stageAjobs[1+2*$i] - $stageAjobs[2*$i] +1;
		$chunkrate = round ((8 * $fps * $chunktarget) / (1000 * $chunkframes)); #TODO: check if 1024 is correct
		push(@targetrate, $chunkrate);
	}
	
	### write jobfile for stage C
	open(JOBLIST, ">>$jobqueue");
	for ($i = 0; $i < $chunks; ++$i)
	{
	# reuse stageA avs files
		$filename=$tmpdir."/stageC-".$i.".bat"; open(INFO, ">$filename");
		$batinfo = "cd $tmpdir\n$pathtox264 -o test$i.264 $pass2opts --pass 2 --stats stageC-$i.stats --progress -B $targetrate[$i] stageA-$i.avs\n$touch stageC-result$i.ready\n";
		print INFO $batinfo; close(INFO);
		print JOBLIST "$tmpdir\\stageC-$i.bat\n";
	}
	close(JOBLIST);
	
	for ($i=0;$i<$chunks;++$i) {unlink("$tmpdir/acrfout$i.264");}
	
	### exit
	print "### Stage C jobs issued\n";
} # old ELDER4x264_c2
######## helpers
sub get_frames_fps_resolution { # use pipe to read one line from avisynth and extract fps, framecount and resolution
	open(PIPE,"avs2yuv.exe -frames 1 $config{'input'} NUL 2>&1 |"); $line=<PIPE>; close(PIPE);
	@lineinfo1=split(/:/,$line);
	@lineinfo2=split(/,/,$lineinfo1[1]);
	@lineinfo3=split(/x/,$lineinfo2[0]);
	@lineinfo4=split(/ /,$lineinfo2[1]);
	@lineinfo5=split(/ /,$lineinfo2[2]);
	$config{'width'}=$lineinfo3[0]*1;
	$config{'height'}=$lineinfo3[1]*1;
	$config{'fps'}=int(1000*eval($lineinfo4[1]))/1000;
	$config{'frames'}=$lineinfo5[1]*1 if ($config{'frames'}==0);
	print "detected video: $config{'frames'} frames at $config{'width'}x$config{'height'}x$config{'fps'}p\n" if $config{'verbose'};
} # get_frames_fps_resolution
sub value_km { # returns decimal value without Kilo or Mega
	$in=$_[0]; if ($in=~"k") {@line=split(/k/,$in); $val=1024*$line[0];
	} elsif ($in=~"K") {@line=split(/K/,$in); $val=1024*$line[0];
	} elsif ($in=~"m") {@line=split(/m/,$in); $val=1024*1024*$line[0];
	} elsif ($in=~"M") {@line=split(/M/,$in); $val=1024*1024*$line[0];
	} else {$val=$in;}; return $val;
} # value_km
sub compute_Aranges { # compute ranges of stage A: wild guess
	## get parameters
	$currentframe=0;
	push(@stageAjobs, $currentframe);
	for ($i=0;$i<$chunks-1;++$i) {
		$currentframe+=$chunksize;
		push(@stageAjobs,round($currentframe));
		push(@stageAjobs,round($currentframe+1));
	}
	push(@stageAjobs,$config{"frames"}-1);
	##TODO: write ranges to file
} # compute_Aranges

sub detect_Aranges { # scene detect ranges of stage A: accurate for xvid, acceptable for other codecs
	## scene detection: go (150) frames back... search for closest I frame, if none found => set one at pos=0 (doesn't lose much anyway) => Aranges
	## get parameters
	## generate jobs
	$currentframe=0;
	push(@stageAjobs, $currentframe);
	for ($i=0;$i<$chunks-1;++$i) {
		$currentframe+=$chunksize;
		push(@stageAjobs,round($currentframe));
		push(@stageAjobs,round($currentframe+1));
	}
	push(@stageAjobs,$config{"frames"}-1);
} # detect_Aranges
sub collect_Aranges {
	## get parameters
	## collects the stats files
	##TODO: write ranges to file
} # collect_Aranges

sub filecopy { # filecopy("src","dst"): copies src file to dst; use for small files only
	open(FILE,$_[0]); my @content=<FILE>; close(FILE);
	open(FILE,">$_[1]"); for ($i=0;$i<=$#content;$i++) {print FILE "$content[$i]";}; close(FILE);
} # filecopy
sub handle_jobqueue { # detect global/local processing and set up jobqueue
	$config{"local"}=($config{"jobqueue"} eq "");
	if ($config{"local"}) {
		$config{"jobqueue"}="$tmpdir/jobqueue";
		open(INFO,">>$config{'jobqueue'}"); print INFO "pause 1\n"; close(INFO);
	}
	$config{"jobqueue"} =~ s/\//\\/g; # OS?
} # handle_jobqueue
sub compare_outputsize { # size comparison
	$encodedbytes=(-s "$config{'outputfilename'}");
	if ($config{'totalbytes'}==-1) {$config{'totalbytes'}=$encodedbytes;};
	$error=round(10000*abs($config{'totalbytes'}-$encodedbytes)/$config{'totalbytes'})/100;
	$sign="+"; $sign="-" if ($config{'totalbytes'} > $encodedbytes);
	print "target:\t$config{'totalbytes'} bytes\nencode:\t$encodedbytes bytes\nerror:\t$sign$error%\n";
} # compare_outputsize
sub print_1passtime { # print 1st pass time
	$passed=time()-$config{'starttime'};
	$config{'pass1fps'}=int(100*$config{'frames'}/$passed)/100;
	print "1st pass fps = $config{'pass1fps'}\n";
} # print_1passtime
sub print_2passtime { # print 2nd pass time
	$passed=time()-$config{'starttime_pass2'};
	$config{'pass2fps'}=int(100*$config{'frames'}/$passed)/100;
	print "2nd pass fps = $config{'pass2fps'}\n";
} # print_2passtime
sub print_totaltime { # print overall time
	$passed=time()-$config{'starttime'};
	print "total time for encoding: $passed seconds\n";
	$config{'overallfps'}=int(100*$config{'frames'}/$passed)/100;
	print "overall fps = $config{'overallfps'}\n";
} # print_totaltime
sub computechunks { # compute number of chunks
	## compute $magicfactor depending on chunksize
	if ($config{'chunks'}==0) {
		$config{'chunks'}=int($config{'frames'}/$config{'preferredchunksize'});
		if ($config{'chunks'}<$config{'maxpar'}) {$config{'chunks'}=$config{'maxpar'};}
		if ($chunks==0) {$chunks=1;};
	}
	$chunksize=$config{'frames'}/$config{'chunks'};
	if ($chunksize<$config{'minchunksize'}) {
		$config{'chunks'}=int($config{'frames'}/$config{'minchunksize'}); if ($chunks==0) {$chunks=1;};
	}
	$config{'chunks'}=$config{'maxpar'}*int($config{'chunks'}/$config{'maxpar'});
	$config{'chunks'}=1 if ($config{'chunks'}==0);
} # computechunks
sub get_frames_fps { # use pipe to read one line from avisynth and extract fps and framecount
	open(PIPE,"x264.exe --frames 1 --stats $config{'nul'} -o $config{'nul'} $config{'source'} 2>&1 |");
	$firstline=<PIPE>; close(PIPE); @lineinfo=split(/ /,$firstline);
	$config{'fps'}=substr($lineinfo[4],0);
	if ($config{'frames'}==0) {$config{'frames'}=substr($lineinfo[6],1);}
	if ($config{'fps'} eq "format") {print "source can't be read!\n"; exit 1;}
	print "detected fps = $config{'fps'}\n";
	print "detected frames = $config{'frames'}\n";
	if ($config{'frames'}==0) {exit();}; if ($config{'fps'}==0) {exit();}; # TODO: add error message
} # get_frames_fps
sub muxavc { # mux AVC in .mp4/.mkv
	print $config{'outputfilename'};
	@lineinfo=split(/\./,$config{'outputfilename'}); $suffix=$lineinfo[$#lineinfo];
	print "; suffix=$suffix\n";
	if ($suffix eq "mp4") {
		print "muxing to .mp4\n";
		system("mp4box -cat $tmpdir/final.264 -fps $config{'fps'} -new $config{'outputfilename'} 1>$config{'nul'} 2>$config{'nul'}"); print "chunks merged\n";
	} elsif ($suffix eq "mkv") {
		print "muxing to .mkv\n";
		system("mp4box -cat $tmpdir/final.264 -fps $config{'fps'} -new $config{'outputfilename'}.mp4 1>$config{'nul'} 2>$config{'nul'}");
		system("mkvmerge -o $config{'outputfilename'} $config{'outputfilename'}.mp4"); 

		print "mkvmerge defunct!\n";
#		unlink("$config{'outputfilename'}.mp4");
		print "chunks merged\n";
	} else {
		print "invalid suffix. using .mp4 instead.\n";
		$config{'outputfilename'}=$config{'outputfilename'}.".mp4";
		system("mp4box -cat $tmpdir/final.264 -fps $config{'fps'} -new $config{'outputfilename'} 1>$config{'nul'} 2>$config{'nul'}"); print "chunks merged\n";
	};
} # muxavc
sub muxasp { # mux ASP to .mp4/.avi/.mkv
	@lineinfo=split(/\./,$config{'outputfilename'}); $suffix=$lineinfo[$#lineinfo];
	if ($suffix eq "mp4") {
		print "muxing to .mp4\n";
		system("mp4box -cat $tmpdir/final.m4v -fps $config{'fps'} -new $config{'outputfilename'} 1>$config{'nul'} 2>$config{'nul'}"); print "chunks merged\n";
	} elsif ($suffix eq "mkv") {
		print "muxing to .mkv\n";
		system("mp4box -cat $tmpdir/final.m4v -fps $config{'fps'} -new $config{'outputfilename'}.mp4 1>$config{'nul'} 2>$config{'nul'}");
		system("mkvmerge -o $config{'outputfilename'} $config{'outputfilename'}.mp4");
		print "mkvmerge defunct!\n";
#		unlink("$config{'outputfilename'}.mp4");
		print "chunks merged\n";
	} elsif ($suffix eq "avi") {
		print "muxing to .avi! ouch.\n";
		system("mp4box -cat $tmpdir/final.m4v -fps $config{'fps'} -new $config{'outputfilename'}.mp4 1>$config{'nul'} 2>$config{'nul'}");
		system("ffmpeg -i $config{'outputfilename'}.mp4 -vcodec copy -y $config{'outputfilename'}"); unlink("$config{'outputfilename'}.mp4"); print "chunks merged\n";
	} else {
		print "invalid suffix. using .mp4 instead.\n";
		$config{'outputfilename'}=$config{'outputfilename'}.".mp4";
		system("mp4box -cat $tmpdir/final.m4v -fps $config{'fps'} -new $config{'outputfilename'} 1>$config{'nul'} 2>$config{'nul'}"); print "chunks merged\n";
	};
} # muxasp
sub get_parameters { # read command line parameters and store in hash
	getopts('b:s:j:f:c:o:m:p:a:q:t:r:', \%opt) || elder_usage();
	if ($opt{'b'}) {$config{'totalbitrate'}=$opt{'b'}} else {$config{'totalbitrate'}=0;};
	if ($opt{'s'}) {$config{'totalbytes'}=$opt{'s'}} else {$config{'totalbytes'}=0;};
	if ($opt{'j'}) {$config{'jobqueue'}=$opt{'j'}} else {$config{'jobqueue'}="";};
	if ($opt{'f'}) {$config{'frames'}=$opt{'f'}} else {$config{'frames'}=0;};
	if ($opt{'r'}) {$config{'crfvalue'}=$opt{'r'}; $config{'totalbytes'}=-1;} else {$config{'crfvalue'}=24;};
	if ($opt{'c'}) {$config{'chunks'}=$opt{'c'}} else {$config{'chunks'}=0;};
	if ($opt{'o'}) {$config{'outputfilename'}=$opt{'o'}} else {$config{'outputfilename'}="output.mp4";};
	if ($opt{'m'}) {$config{'maxpar'}=$opt{'m'}} else {$config{'maxpar'}=2;};
	if ($opt{'p'}) {$config{'pass1opts'}=$opt{'p'}} else {$config{'pass1opts'}=$default_options;}; 
	if ($opt{'a'}) {$config{'source'}=$opt{'a'}} else {$config{'source'}="default.avs";};
	if ($opt{'q'}) {$config{'pass2opts'}=$opt{'q'}} else {$config{'pass2opts'}=$default_options;};
	if ($opt{'t'}) {$config{'tmpdir'}=$opt{'t'}} else {$config{'tmpdir'}=$tmpdir;};
	if (($config{"totalbitrate"}==0) && ($config{"totalbytes"}==0)) {print "Specify either bitrate or size!\n"; exit 1;}
	$config{'totalbitrate'}=value_km($config{'totalbitrate'})/1000;
	$config{'totalbytes'}=value_km($config{'totalbytes'});
	$config{'input'}=$config{'source'};
	$config{"preferredchunksize"}=$preferredchunksize;
	$config{"minchunksize"}=$minchunksize;
	$config{"pathtoencraw"}="..\\xvid_encraw.exe";
	$config{"pathtox264"}="..\\x264.exe";
	$config{"touch"}="echo.>";
	$config{"nul"}="NUL"; # OS
	$config{"b_issued"}=0;
	$config{"totalsize"}=-1; # obsolete?
} # get_parameters
sub getlock { # acquire lock for $file
	my $filename=$_[0];
	$id=int(rand(1000000));
	$ok=0;
	do {
		while (-e "$filename.lock") {
			#sleep a little while
		}
		open(INFO,">>$filename.lock"); print INFO "$id\n"; close(INFO);
		open(INFO,"$filename.lock"); $line=<INFO>; close(INFO); $ok=1 if ($line =~ /$id/);
	} until ($ok)
} # getlock
sub removelock { # removes a lock on a file
	my $filename=$_[0]; unlink("$filename.lock");
} # removelock
sub safewrite { # write safely to jobfile
	my $filename=$_[0]; my $text=$_[1];
	getlock($filename); open(INFO,">>$filename"); print INFO $text; close(INFO); removelock($filename);
} # safewrite
sub saferead { # read safely from jobfile
	my $filename=$_[0]; getlock("$filename"); 
	open(INFO,$filename); @whole=<INFO>; close(INFO); ($line,@whole)=@whole;
	open(INFO,">$filename"); print INFO @whole; close(INFO);
	removelock($filename); return $line;
} # saferead
sub pickjob { # picks a job from jobfile and executes it
###TODO: alternative pick_job with sync and locking
#	safewrite("blafu.txt","abc\n");
#	$result=saferead("blafu.txt");
#	print ">>$result<<\n";
} # pickjob
## move pickjob to tools
sub pick_job { #parameter: <jobfile>
	#TODO: add the file if not exist; quit on "quit" command only
	do {
		$file = $ARGV[0];
		getlock($file);
		open(INFO, $file); @lines = <INFO>; close(INFO);
		($execute, @rest) = @lines; $sleeptime=1; $execute=substr($execute, 0, -1); @command=split(/ /,$execute);
		if ($command[0] eq "pause") {
			if ($command[1]) {$sleeptime=$command[1];}; 
			push(@rest,"pause $sleeptime\n"); open(INFO,">$file"); print INFO @rest; close(INFO); removelock($file);
			sleep $sleeptime; print "nothing to do => sleeping for $sleeptime"."000 milliseconds\n";
		} elsif ($command[0] eq "") {
			open(INFO,">$file"); print INFO @rest; close(INFO); removelock($file); sleep $sleeptime;
		} elsif ($command[0] eq "quit") {
			unlink($file);
		} elsif ($command[0] eq "sync") {
			print "!!! Now syncing !!!\n";
			#TODO: sync: wait until .started == .finished
			open(INFO,">$file"); print INFO @rest; close(INFO); removelock($file);
		} else {
			open(INFO,">$file"); print INFO @rest; close(INFO); removelock($file);
			## add locks here!
			open(INFO,">>$file.started"); print INFO "$execute\n"; close(INFO);
			system($execute);
			open(INFO,">>$file.finished"); print INFO "$execute\n"; close(INFO);
		}
	} while(-e $file);
} # pick_job
sub d2u { # parameter: -i <input.stats> -o <output.stats>
	@defaults = ("i", "input.stats", "o", "output.stats"); %settings=@defaults; %parameters=@ARGV;
	while (($parameter, $setting) = each(%parameters)) {$settings{chop($parameter)}=$setting;}
	$filename=$settings{"i"}; open(STATIN, $filename); @statin = <STATIN>; close(STATIN);
	$filename=$settings{"o"}; open(STATOUT, ">$filename");
	$statin =~ s/\r//g; print STATOUT "$statin"; close(STATOUT);
} # d2u
sub u2d { # parameter: -i <input.stats> -o <output.stats>
	@defaults = ("i", "input.stats", "o", "output.stats"); %settings=@defaults; %parameters=@ARGV;
	while (($parameter, $setting) = each(%parameters)) {$settings{chop($parameter)}=$setting;}
	$filename=$settings{"i"}; open(STATIN, $filename); @statin = <STATIN>; close(STATIN);
	$filename=$settings{"o"}; open(STATOUT, ">$filename");
	$statin =~ s/\n/\r\n/g; print STATOUT "$statin"; close(STATOUT);
} # u2d
sub xvid50p { # parameter: -i <input.stats> -o <output.stats>
	@defaults = ("i", "input.stats", "o", "output.stats"); %settings=@defaults; %parameters=@ARGV;
	while (($parameter, $setting) = each(%parameters)) {$settings{chop($parameter)}=$setting;}
	$filename=$settings{"i"}; open(STAT25, $filename); @stat25p = <STAT25>; close(STAT25);
	$filename=$settings{"o"}; open(STAT50, ">$filename");
	for ($i = 0; $i < 4; ++$i) {print STAT50 "$stat25p[$i]";}
	@oldlineinfo = split(/ /, $stat25p[3]);
	for ($i = 4; $i < 1+$#stat25p; ++$i) {
	 @lineinfo = split(/ /, $stat25p[$i]);
	 if ($lineinfo[0] eq "b")	{print STAT50 "$stat25p[$i]";}
	 elsif ($oldlineinfo[0] eq "b")	{print STAT50 "$stat25p[$i -1]";}
	 elsif ($lineinfo[0] eq "p")	{print STAT50 "$stat25p[$i]";}
	 else {print STAT50 "$stat25p[$i -1]";}
	 print STAT50 "$stat25p[$i]";	@oldlineinfo = @lineinfo;}
	close(STAT50);
} # xvid50p
####### autores and n0153
sub encode_percent {
	encode_percent_getparameters();
	if ($config{'verbose'}) {$ff_verbose="-v -1 "} else {$ffverbose="-v 1 "};
	print "encode%: del=$config{'unlink'}\tverbose=$config{'verbose'}\tffverbose=\"$ff_verbose\"\n";
	print "goal:\tencoding $config{'width'} x $config{'height'} at $config{'percent'}%\n" if $config{'verbose'};
	$newx=$config{'xmod'}*int(((sqrt($config{'percent'}/100)*$config{'width'})+$config{'xmod'}/2)/$config{'xmod'});
	$newy=$config{'ymod'}*int(((($config{'percent'}*$config{'width'}*$config{'height'})/(100*$newx))+$config{'ymod'}/2)/$config{'ymod'});
	$truepercent=int(10000*($newx*$newy)/($config{'width'}*$config{'height'}))/100;
	print "real:\tencoding $newx x $newy ($truepercent%)\n" if $config{'verbose'};
	open(FILE,">_tmp.avs"); print FILE "import(\"$config{'input'}\")\nlanczosresize($newx,$newy)\n"; close(FILE);
	$cli="start /belownormal /B /wait avs2yuv.exe _tmp.avs - | ffmpeg.exe $ff_verbose -f yuv4mpegpipe -i - -f avi -vcodec mpeg4 -qscale $config{'quant'} $config{'output'} 1>NUL";
	system("$cli\n");
	system($cli);
	unlink("_tmp.stats") if $config{'unlink'};
	unlink("_tmp.avs") if $config{'unlink'};
} # encode_percent
sub encode_percent_usage {
  print "encode_percent_usage:\n\noption\tdescription\n-w\twidth\n-h\theight\n-i\tinput\n-o\toutput\n-p\tpercentage (100)\n-q\tquant (2)\n-d\tdelete intermediate files\n-v\tverbosity\n-x\txmod (16)\n-y\tymod (16)\n";
  exit 1;
} # encode_percent_usage
sub encode_percent_getparameters {
	getopts('w:h:i:o:p:q:x:y:d:v:', \%opt) || encode_percent_usage();
	if ($opt{'w'}) {$config{'width'}=$opt{'w'}} else {$config{'width'}=720;};
	if ($opt{'h'}) {$config{'height'}=$opt{'h'}} else {$config{'height'}=576;};
	if ($opt{'i'}) {$config{'input'}=$opt{'i'}} else {$config{'input'}="default.avs";};
	if ($opt{'o'}) {$config{'output'}=$opt{'o'}} else {$config{'output'}="default.mp4";};
	if ($opt{'p'}) {$config{'percent'}=$opt{'p'}} else {$config{'percent'}=25;};
	if ($opt{'q'}) {$config{'quant'}=$opt{'q'}} else {$config{'quant'}=2;};
	if ($opt{'x'}) {$config{'xmod'}=$opt{'x'}} else {$config{'xmod'}=16;};
	if ($opt{'y'}) {$config{'ymod'}=$opt{'y'}} else {$config{'ymod'}=16;};
	if ($opt{'d'}) {$config{'unlink'}=0;} else {$config{'unlink'}=1;};
	if ($opt{'v'}) {$config{'verbose'}=1;} else {$config{'verbose'}=0;};
} # encode_percent_getparameters
sub find_resolution {
	find_resolution_getparameters(); $config{'size'}=value_km($config{'size'}); $_unlink=1-$config{'unlink'};
	print "findres: del=$config{'unlink'}\tverbose=$config{'verbose'}\n";
	$mbytes=int(100*$config{'size'}/2**20)/100; # total target size in MBytes
	print "target size is $config{'size'} Bytes ($mbytes MB).\n" if $config{'verbose'};
	get_frames_fps_resolution();
	$config{'firstpercent'}=0.01;
	$config{'firstframes'}=100;
	$config{'secondpercent'}=0.05;
	$config{'secondframes'}=500;
	$firstratio=max(15,int($config{'frames'}/(max($config{'firstpercent'}*$config{'frames'},$config{'firstframes'})/15)));
	print "($firstratio,15): ~".int(15*$config{'frames'}/$firstratio)." frames\n" if $config{'verbose'};
	$secondratio=max(15,int($config{'frames'}/(max($config{'secondpercent'}*$config{'frames'},$config{'secondframes'})/15)));
	print "($secondratio,15): ~".int(15*$config{'frames'}/$secondratio)." frames\n" if $config{'verbose'};
	$sampletarget1=int($config{'size'}*15/$firstratio);
	$sampletarget2=int($config{'size'}*15/$secondratio);
	unlink("020.$config{'output'}"); unlink("080.$config{'output'}");

	open(FILE,$config{'input'}); @input=<FILE>; close(FILE);
	open(FILE,">my.$config{'input'}"); print FILE @input; print FILE "\nselectrangeevery($firstratio,15)\n"; close(FILE);
	## use jobfile for encode jobs!
	$cli="perl functions.pl encode_percent -p 20 -o 020.$config{'output'} -i my.$config{'input'} -d $_unlink -v $config{'verbose'} -x $config{'xmod'} -y $config{'ymod'} -w $config{'width'} -h $config{'height'} -q $config{'quant'}";
	system($cli);
	$cli="perl functions.pl encode_percent -p 80 -o 080.$config{'output'} -i my.$config{'input'} -d $_unlink -v $config{'verbose'} -x $config{'xmod'} -y $config{'ymod'} -w $config{'width'} -h $config{'height'} -q $config{'quant'}";
	system($cli);
	$size20=(-s "020.$config{'output'}");
	$size80=(-s "080.$config{'output'}");
	print "20% size is $size20 bytes.\n" if $config{'verbose'};
	print "80% size is $size80 bytes.\n" if $config{'verbose'};
	print "sample target 1 is $sampletarget1 bytes.\n" if $config{'verbose'};
	print "sample target 2 is $sampletarget2 bytes.\n" if $config{'verbose'};
	unlink("020.$config{'output'}") if $config{'unlink'};
	unlink("080.$config{'output'}") if $config{'unlink'};
	unlink("my.$config{'input'}") if $config{'unlink'};

	## first estimate
	$newpercent=int(1.5*(20+60*($sampletarget1-$size20)/($size80-$size20)));
	$newpercent=100 if ($newpercent>100); $newpercent=1 if ($newpercent<1);
	print "linear guess: $newpercent\n" if $config{'verbose'};
	unlink("$newpercent.$config{'output'}");

	open(FILE,">my2.$config{'input'}"); print FILE @input; print FILE "\nselectrangeevery($secondratio,15)\n"; close(FILE);
	$cli="perl functions.pl encode_percent -p $newpercent -o $newpercent.$config{'output'} -i my2.$config{'input'} -d $_unlink -v $config{'verbose'} -x $config{'xmod'} -y $config{'ymod'} -w $config{'width'} -h $config{'height'} -q $config{'quant'}";
	system($cli);
	$size_n=(-s "$newpercent.$config{'output'}");
	print "$newpercent% size is $size_n bytes.\n" if $config{'verbose'};
	print "sample target 2 is $sampletarget2 bytes.\n" if $config{'verbose'};
	unlink("$newpercent.$config{'output'}") if $config{'unlink'};
	unlink("my2.$config{'input'}") if $config{'unlink'};

	## new estimate: linear correction --- size(percent) is almost linear
	$finalpercent=int(($newpercent*$sampletarget2)/$size_n);
	$finalpercent=100 if ($finalpercent>100); $finalpercent=1 if ($finalpercent<1);
	unlink("$config{'output'}");

	$cli="perl functions.pl encode_percent -p $finalpercent -o $config{'output'} -i $config{'input'} -d $_unlink -v $config{'verbose'} -x $config{'xmod'} -y $config{'ymod'} -w $config{'width'} -h $config{'height'} -q $config{'quant'}";
	print($cli);
	system("$cli\n");
	$fullsize=(-s "$config{'output'}");

	$error=round(10000*abs($config{'size'}-$fullsize)/$config{'size'})/100;
	$sign="+"; $sign="-" if ($config{'size'} > $fullsize);
	print "real size is $fullsize bytes.\ttarget is $config{'size'} bytes.\terror= $sign$error%\n" if $config{'verbose'};
} # find_resolution
sub find_resolution_usage {
  print "find_resolution_usage:\n\noption\tdescription\n-h\thelp\n-s\tsize\n-i\tinput\n-o\toutput\n-q\tquant (2)\n-d\tdelete intermediate files\n-v\tverbosity\n-x\txmod (16)\n-y\tymod (16)\n-c\tnumber of chunks (default=0=autodetect)\n-j\tjobqueue\n";
  exit 1;
} # find_resolution_usage
sub find_resolution_getparameters {
	getopts('hi:o:p:x:y:s:q:d:v:c:j:', \%opt) || find_resolution_usage();
	if ($opt{'h'}) {find_resolution_usage()};
	if ($opt{'i'}) {$config{'input'}=$opt{'i'}} else {find_resolution_usage();};
	if ($opt{'s'}) {$config{'size'}=$opt{'s'}} else {find_resolution_usage();};
	if ($opt{'o'}) {$config{'output'}=$opt{'o'}} else {find_resolution_usage();};
	if ($opt{'x'}) {$config{'xmod'}=$opt{'x'}} else {$config{'xmod'}=16;};
	if ($opt{'y'}) {$config{'ymod'}=$opt{'y'}} else {$config{'ymod'}=16;};
	if ($opt{'q'}) {$config{'quant'}=$opt{'q'}} else {$config{'quant'}=2;};
	if ($opt{'d'}) {$config{'unlink'}=0;} else {$config{'unlink'}=1;};
	if ($opt{'v'}) {$config{'verbose'}=1;} else {$config{'verbose'}=0;};
	if ($opt{'c'}) {$config{'chunks'}=$opt{'c'}} else {$config{'chunks'}=0;};
	if ($opt{'j'}) {$config{'jobqueue'}=$opt{'j'}} else {$config{'jobqueue'}="global.jobs";};
} # find_resolution_getparameters
sub autores {
	autores_getparameters(); $config{'size'}=value_km($config{'size'}); get_frames_fps_resolution(); $_unlink=1-$config{'unlink'};
	print "autores: del=$config{'unlink'}\tverbose=$config{'verbose'}\n";
	if ($config{'bitrate'}>0) {
		get_frames_fps_resolution();
		$config{'size'}=round($config{'bitrate'}*$config{'frames'}/$config{'fps'}/8);
		print "computed size = $config{'size'} byte\n";
	};
	system("perl functions.pl find_resolution -s $config{'size'} -o $config{'output'} -i $config{'input'} -q $config{'quant'} -d $_unlink -v $config{'verbose'} -x $config{'xmod'} -y $config{'ymod'} -c $config{'chunks'} -j $config{'jobqueue'}");
} # autores
sub autores_usage {
	print "autores_usage:\n\noption\tdescription\n-h\thelp\n-s\tsize\n-b\tbitrate\n-i, -a\tinput\n-o\toutput\n-d\tdelete intermediate files\n-v\tverbosity\n-x\txmod (16)\n-y\tymod (16)\n-q\tquant\n-c\tnumber of chunks (default=0=autodetect)\n-j\tjobqueue\n";
	exit 1;
} # autores_usage
sub autores_getparameters {
  getopts('hi:o:x:y:s:q:d:v:c:j:a:b:', \%opt) || autores_usage();
	if ($opt{'h'}) {autores_usage()};
	if ($opt{'i'}) {$config{'input'}=$opt{'i'}} else {$config{'input'}="input.avs";};
	if ($opt{'a'}) {$config{'input'}=$opt{'a'}};
	if ($opt{'b'}) {$config{'bitrate'}=$opt{'b'}};
	if ($opt{'o'}) {$config{'output'}=$opt{'o'}} else {$config{'output'}="out_70.m4v";};
	if ($opt{'x'}) {$config{'xmod'}=$opt{'x'}} else {$config{'xmod'}=16;};
	if ($opt{'y'}) {$config{'ymod'}=$opt{'y'}} else {$config{'ymod'}=16;};
	if ($opt{'q'}) {$config{'quant'}=$opt{'q'}} else {$config{'quant'}=2;};
	if ($opt{'s'}) {$config{'size'}=$opt{'s'}} else {$config{'size'}="300M";};
	if ($opt{'d'}) {$config{'unlink'}=0;} else {$config{'unlink'}=1;};
	if ($opt{'v'}) {$config{'verbose'}=1;} else {$config{'verbose'}=0;};
	if ($opt{'c'}) {$config{'chunks'}=$opt{'c'}} else {$config{'chunks'}=0;};
	if ($opt{'j'}) {$config{'jobqueue'}=$opt{'j'}} else {$config{'jobqueue'}="global.jobs";};
} # autores_getparameters
sub percent_study { # percent parameter study: input.avs steps
	$config{'input'}=$ARGV[0]; $steps=$ARGV[1]; $steps=10 if ($ARGV[1] eq ""); $percent_hi=100; $percent_lo=10;
	get_frames_fps_resolution(); $config{'verbose'}=1;
	$percent_max=max($percent_lo,$percent_hi); $percent_min=min($percent_lo,$percent_hi);
	$percent_step=($percent_max-$percent_min)/($steps-1);
	for ($percent=$percent_min;$percent<$percent_max+abs($percent_step)/10;$percent+=abs($percent_step)) {
		$percentage=int($percent); print "$input at $percentage percent\n";
		## rounding
		$cli="perl functions.pl encode_percent -p $percentage -o $percentage.out.$config{'input'}.m4v -i $config{'input'} -w $config{'width'} -h $config{'height'}";
		print "$cli\n" if $config{'verbose'};
		system($cli);
	}
} # percent_study
