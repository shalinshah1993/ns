BEGIN{
	noOfNodes = 4;
	noOfPackets = 0;
	drop[noOfNodes] = 0;
}

{
	if($1 == "r")
		noOfPackets++;
	if($1 == "d")
		drop[$3-1]++;
	
}

END{
	printf("No of Packets Received : %d\n",noOfPackets);
	for(i = 0 ; i < noOfNodes ; i++)
		printf("No of packets dropped at %d : %d\n",i+1,drop[i]);
}
