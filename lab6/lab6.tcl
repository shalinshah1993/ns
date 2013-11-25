set ns [new Simulator]

set file1 [open out.tr w]
set file2 [open out.nam w]
set outfile [open  "congestion.xg"  w]

$ns namtrace-all $file2
$ns trace-all $file1

proc finish {} {
	global ns file1 file2
	$ns flush-trace
	close $file2
	close $file1
	exec nam out.nam &
	exec xgraph congestion.xg &
	exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

$ns duplex-link $n0 $n1 1.5Mb 10ms DropTail
$ns duplex-link $n1 $n2 1.5Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.5Mb 10ms DropTail
$ns duplex-link $n3 $n4 1.5Mb 10ms DropTail
$ns duplex-link $n4 $n5 1.5Mb 10ms DropTail
$ns duplex-link $n5 $n6 1.5Mb 10ms DropTail
$ns duplex-link $n6 $n0 1.5Mb 10ms DropTail

set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set ftp [new Application/FTP]
$ftp attach-agent $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink

$ns rtproto DV

$ns rtmodel-at 1.0 down $n4 $n5
$ns rtmodel-at 4.5 up $n4 $n5

proc plotWindow {tcp outfile} {
	global ns
	set count [$ns now]
	#Current value of congestion window is obtained from this variable
	set value [$tcp set cwnd_] 
	puts $outfile "$count $value"
	$ns at [expr $count + 0.1] "plotWindow $tcp $outfile"
} 

$ns at 0.1 "$ftp start"
$ns  at  0.0  "plotWindow $tcp  $outfile"
$ns at 12.0 "finish"
$ns run
