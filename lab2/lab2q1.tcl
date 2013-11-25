set ns [new Simulator]

set file1 [open out.tr w]
set file2 [open out.nam w]
$ns namtrace-all $file2
#$ns trace-all $file1

proc finish {} {
	global file1 file2 ns
	$ns flush-trace
	close $file1
	close $file2
	exec xgraph out.tr &
	exit 0
}

set arrival_rate 50.0
set service_rate 60.0
set link_speed 1000

set n1 [$ns node]
set n2 [$ns node]

$ns simplex-link $n1 $n2 0.001Mb 0 DropTail
$ns queue-limit $n1 $n2 100000

set que_mon [$ns monitor-queue $n1 $n2 [open queue.tr w]]

set udp [new Agent/UDP]
set null [new Agent/Null]
$ns attach-agent $n1 $udp
$ns attach-agent $n2 $null
$ns connect $udp $null

set iTime [new RandomVariable/Exponential]
$iTime set avg_ [expr 1/$arrival_rate]
set iSize [new RandomVariable/Exponential]
$iSize set avg_ [expr $link_speed/8.0 * $service_rate]
#P.S -> Link Speed is in bits/sec and service rate is in packets/sec

proc sendPacket {} {
	global ns iTime iSize udp
	set curTime [$ns now]
	$ns at [expr $curTime + [$iTime value]] "sendPacket"
	set bytes [expr round([$iSize value])]
	$udp send $bytes
}

proc queueLen {prevLen count} {
	global ns iTime iSize que_mon file1
	set curTime [$ns now]
	set pktSize [$que_mon set pkts_]
	set totalPktSize [expr $pktSize + $prevLen]
	set avgQLen [expr $totalPktSize/$count]
	set count [expr $count + 1]
	puts $file1 "$avgQLen $count"
	$ns at [expr $curTime + 0.1] "queueLen $totalPktSize $count"
} 

$ns at 0.001 "sendPacket"
$ns at 500 "finish"
$ns at 0.1 "queueLen 0 1"
$ns run