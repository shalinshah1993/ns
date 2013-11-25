set ns [new Simulator]

set file1 [open out.tr w]
set file2 [open out.nam w]
#set plotFile [open  "congWin.xg"  w]

$ns trace-all $file1 
$ns namtrace-all $file2

proc finish {} {
	global ns file1 file2
	#$ns flush-trace
	close $file1
	close $file2
	#exec nam out.nam &
	#exec xgraph congestion.xg &
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

set null [new Agent/Null]
set udp [new Agent/UDP]
$udp set fid_ 876
set cbr [new  Application/Traffic/CBR]
$cbr set packetSize_ 500
$cbr set rate_ 800kb

proc setNewTCP {} {
	global udp cbr null ns n1 n2 
	$ns attach-agent $n1 $udp
	$ns attach-agent $n2 $null
	$ns connect $udp $null
	$cbr attach-agent $udp
}

proc detachNewTCP {} {
	global ns udp null n1 n2 
	$ns detach-agent $n1 $udp
	$ns detach-agent $n2 $null
}

#Congestion Window is plotted in this graph
proc plotWindow {count} {
	global tcp plotFile ns
	set count [expr $count + 1]
	set value [$tcp set cwnd_]
	puts $plotFile "$count $value"
	$ns at [expr $count + 0.1] "plotWindow $count"
	
}

$ns at 0.1 "$ftp start"
#$ns at 0.1 "plotWindow 0"
$ns at 500 "setNewTCP"
$ns at 501 "$cbr start"
$ns at 1000 "detachNewTCP"
$ns at 1500 "finish"
$ns run