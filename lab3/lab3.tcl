set ns [new Simulator]

set file1 [open out.tr w]
set file2 [open out.nam w]
$ns trace-all $file1
$ns namtrace-all $file2

proc finish {} {
	global ns file1 file2 ns
	$ns flush-trace
	close $file1
	close $file2
	exit 0
} 

set noOfNodes 4
set nodeList ""
set BW 0.01Mb
set delay 10ms
set ll LL
set ifq Queue/DropTail
set MAC Mac/802_3
set channel Channel

for {set i 1} {$i <= $noOfNodes} {incr i} {
	global ns
	set n($i) [$ns node]
	lappend nodeList $n($i)
	
	set udp($i) [new Agent/UDP]
	$ns attach-agent $n($i) $udp($i)
	set cbr($i) [new Application/Traffic/CBR]
	$cbr($i) set packetSize_ 1000
	$cbr($i) set rate_ 100kb
	$cbr($i) attach-agent $udp($i)
	
	$ns at 0.1 "$cbr($i) start"
	$ns at 124 "$cbr($i) stop"
}

set sink [new Agent/Null]
$ns attach-agent $n($noOfNodes) $sink

for {set i 1} {$i <= $noOfNodes} {incr i} {
	$ns connect $udp($i) $sink
}

set lan [$ns newLan $nodeList $BW $delay -llType $ll -ifqType $ifq -macType $MAC -chanType $channel]

$ns at 120 "finish"
$ns at 200.00 "$ns terminate-nam"
$ns run