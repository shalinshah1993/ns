# Copyright (c) 1997 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#


# Script to compare Physical vs Virtual Carrier Sense
# V.B., 2005  

# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             4                         ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol
set val(x)		1000.0			   ;
set val(y)		1000.0			   ;
set val(simtime)	10.0			   ; #sim time
set val(drate)		2.0e6			   ; #default datarate
set val(dist)           100.0			   ;
# ======================================================================
# Main Program
# ======================================================================

if { $argc != 6} {
        puts "Wrong no. of cmdline args."
        puts "Usage: ns csense.tcl -RTSthresh <RTS_Threshold> -CSthresh <carrier-sense threshold> -dist <x>"
        exit 0
}


proc getopt {argc argv} {
        global val
        lappend optlist RTSthresh CSthresh dist
 
        for {set i 0} {$i < $argc} {incr i} {
                set arg [lindex $argv $i]
                if {[string range $arg 0 0] != "-"} continue
 
                set name [string range $arg 1 end]
                set val($name) [lindex $argv [expr $i+1]]
        }

}



getopt $argc $argv

#
# Initialize Global Variables
#
set ns_		[new Simulator]
set tracefd     [open csense.tr w]
$ns_ trace-all $tracefd

#set namtrace [open single-hop.nam w]           ;# for nam tracing
#$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
$ns_ use-newtrace

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#

set god_ [ create-god $val(nn) ]


$val(mac) set dataRate_ $val(drate)
if { $val(RTSthresh) >= 0 } { $val(mac) set RTSThreshold_ $val(RTSthresh) }
if { $val(CSthresh) >= 0 }  { $val(netif) set CSThresh_ $val(CSthresh) }
puts "Setting RTS_Threshold to $val(RTSthresh)"
puts "Setting CS_Threshold to $val(CSthresh)"

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 

# configure node


        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace ON \
			 -movementTrace OFF



	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
	}



#
# Provide initial (X,Y, Z=0) co-ordinates for mobilenodes
#

#Conversation 1: Node 0 is the source, Node 1 is the dst

	$node_(0) set X_ 50.0
	$node_(0) set Y_ 0.0
	$node_(0) set Z_ 0.0
	

	$node_(1) set X_ 250.0
	$node_(1) set Y_ 0.0
	$node_(1) set Z_ 0.0




#Conversation 2: Node 2 is the source, Node 3 is the dst

	$node_(2) set X_ 450.0
	$node_(2) set Y_ $val(dist) 
	$node_(2) set Z_ 0.0
	

	$node_(3) set X_ 250.0
	$node_(3) set Y_ $val(dist)
	$node_(3) set Z_ 0.0





# Define node initial position in nam

for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 20
}



#Attach a data-sink to destination

	set null_(0) [new Agent/Null]
	$ns_ attach-agent $node_(1) $null_(0)


	set null_(1) [new Agent/Null]
	$ns_ attach-agent $node_(3) $null_(1)
		
	
	
#traffic...make src talk to dst
		set udp_(0) [new Agent/UDP]
		$ns_ attach-agent $node_(0) $udp_(0)
				
		set cbr_(0) [new Application/Traffic/CBR]
		$cbr_(0) set packetSize_ 1024
		$udp_(0) set packetSize_ 1024
		$cbr_(0) set interval_ 0.001 
		$cbr_(0) set random_ 0.18372 
		$cbr_(0) set maxpkts_ 1000000
		$cbr_(0) attach-agent $udp_(0)
		$ns_ connect $udp_(0) $null_(0)
		$ns_ at 0.0 "$cbr_(0) start"

	        set udp_(1) [new Agent/UDP]
		$ns_ attach-agent $node_(2) $udp_(1)
				
		set cbr_(1) [new Application/Traffic/CBR]
		$cbr_(1) set packetSize_ 1024
		$udp_(1) set packetSize_ 1024
		$cbr_(1) set interval_ 0.001 
		$cbr_(1) set random_ 0.56272 
		$cbr_(1) set maxpkts_ 1000000
		$cbr_(1) attach-agent $udp_(1)
		$ns_ connect $udp_(1) $null_(1)
		$ns_ at 1.0 "$cbr_(1) start"


	
#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(simtime) "$node_($i) reset";
}
$ns_ at $val(simtime) "stop"
$ns_ at $val(simtime).01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run

