set ns [new Simulator]

set file1 [open out.tr w]
set file2 [open out.nam w]
set plotFile [open  "congWin.xg"  w]

$ns trace-all $file1 
$ns namtrace-all $file2

proc finish {} {
	global ns file1 file2
	#$ns flush-trace
	close $file1
	close $file2
	exec nam out.nam &
	exec xgraph congWin.xg &
	exit 0
}

#Dealy-Bandwidth product in bytes
set transitData [expr 1000000 * 0.1]
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
$tcp set ssthresh_ $transitData
$tcp set window_ $transitData
$ns attach-agent $n1 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n2 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# #Set up the errror model which drops packet with probablity p and then attack link to it
# set lm [new ErrorModel]
# $lm set rate_ $probablity
# $lm unit packet
# $lm drop-target [new Agent/Null]
# set ll [$ns link $n1 $n2]
# $ll install-error $lm

#Congestion Window is plotted in this graph
proc plotWindow {count} {
	global tcp plotFile ns
	set count [expr $count + 1]
	set value [$tcp set cwnd_]
	puts $plotFile "$count $value"
	$ns at [expr $count + 0.1] "plotWindow $count"
	
}

$ns at 0.1 "$ftp start"
$ns at 0.1 "plotWindow 0"
$ns at 1000 "finish"
$ns run