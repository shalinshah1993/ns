set ns [new Simulator]

set file1 [open out.tr w]
set file2 [open out.nam w]
set plotFile1 [open  "congWine1.xg"  w]
set plotFile2 [open  "congWine2.xg"  w]

$ns trace-all $file1 
$ns namtrace-all $file2

proc finish {} {
	global ns file1 file2
	#$ns flush-trace
	close $file1
	close $file2
	exec nam out.nam &
	exec xgraph congWine1.xg &
	exec xgraph congWine2.xg &
	exit 0
}

#Set the probablity of packert drops
set probablity 0.01

#Setting up the nodes
set n1 [$ns node]
set n2 [$ns node]

#If simplex link is not created on both sides then core dump error occurs since TCP has 2 channels one for data PKT n one for ACK PKT 
$ns simplex-link $n1 $n2 1Mb 100m DropTail
$ns simplex-link $n2 $n1 1Mb 100m DropTail
$ns queue-limit $n1 $n2 1000000

set tcp [new Agent/TCP/Newreno]
$tcp set packetSize_ 500
$tcp set fid_ 987
#Both these are set to a large value 
$tcp set ssthresh_ 1000000
$tcp set window_ 1000000
$ns attach-agent $n1 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n2 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp

set sink1 [new Agent/TCPSink/DelAck]
set tcp1 [new Agent/TCP/Newreno]
$tcp1 set fid_ 876
set ftp1 [new Application/FTP]

proc setNewTCP {} {
	global tcp1 ftp1 sink1 ns n1 n2 
	$ns attach-agent $n1 $tcp1
	$ns attach-agent $n2 $sink1
	$ns connect $tcp1 $sink1
	$ftp1 attach-agent $tcp1
}

proc detachNewTCP {} {
	global ns tcp1 sink1 n1 n2 
	$ns detach-agent $n1 $tcp1
	$ns detach-agent $n2 $sink1
}

#Both the congestion Windows are plotted here
proc plotWindow {count} {
	global tcp tcp1 plotFile1 plotFile2 ns
	set count [expr $count + 1]
	set value1 [$tcp set cwnd_]
	set value2 [$tcp1 set cwnd_]
	puts $plotFile1 "$count $value1"
	puts $plotFile2 "$count $value2"
	$ns at [expr $count + 0.1] "plotWindow $count"
	
}

$ns at 0.1 "$ftp start"
$ns at 0.1 "plotWindow 0"
$ns at 500 "setNewTCP"
$ns at 501 "$ftp1 start"
$ns at 1000 "detachNewTCP"
$ns at 1500 "finish"
$ns run