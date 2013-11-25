#Create a simulator
set ns [new Simulator]

#Open the Trace file
set file1 [open out.tr w]
set file2 [open out.nam w]
$ns namtrace-all $file2
$ns color 1 Blue

#Define a ’finish’ procedure
proc finish {} {
global ns file1 file2
$ns flush-trace
close $file2
close $file1
exit 0
}

#Create three nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

#Create links between the nodes - create a duplex link between n0 and n1
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
#Create 2 simplex links in either direction between n1 and n2
$ns simplex-link $n1 $n2 0.1Mb 10ms DropTail
$ns simplex-link $n2 $n1 0.1Mb 10ms DropTail

#Set Queue Size of link (n1-n2) to 10
$ns queue-limit $n1 $n2 10

#Define queue monitor object
set queue_mon [$ns monitor-queue $n1 $n2 [open queue.tr w]]
set queue_pint [$queue_mon get-pkts-integrator]

#Setup a UDP connection
set udp [new Agent/TCP]
$ns attach-agent $n0 $udp
set null [new Agent/TCPSink]
$ns attach-agent $n2 $null
$ns connect $udp $null
$udp set fid 1

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size 1000
$cbr set rate_ 1mb
$cbr set random_ false

#Define a proccedure which periodically records different parameters to the file with file handler ‘‘file1’’
proc record { oldqsize olddrops oldarrivals } {
global ns file1 queue_mon queue_pint
#Get the current time
set now [$ns now]
#Set the time after which the procedure should be called again
set time 1
# Queue monitor parameters: totals
set qsize_ave [$queue_pint set sum_]
set drops_tot [$queue_mon set pdrops_]
set arrivals_tot [$queue_mon set parrivals_]
# Same thing but referring to a record interval this time, for the "instantaneous" values
set qsize [expr $qsize_ave - $oldqsize]
set drops [expr $drops_tot - $olddrops]
set arrivals [expr $arrivals_tot - $oldarrivals]
#The following line writes the no. of packets in the queue at a given observation instant
puts $file1 "$now $qsize"
#Re-schedule the procedure
$ns at [expr $now+$time] "record $qsize_ave $drops_tot $arrivals_tot"
}

# start/stop the CBR
$ns at 0 "$cbr start"
$ns at 100 "$cbr stop"

# start calling the record function at 0.2 sec
$ns at 0.2 "record 0 0 0"

# stop the simulation at 125 sec
$ns at 125.0 "finish"
$ns run
