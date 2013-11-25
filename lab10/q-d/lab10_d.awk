BEGIN{
	recBytes = 0;
	totalBytes = 1000000000;
	simulationTime = 1000;
}

{
	if($1 == "r")
		recBytes += $6;	
}

END{
	printf("Link Utilizatio(%) : %f\n",(100*recBytes)/totalBytes);
	printf("Throughput : %f\n",(8 * recBytes)/simulationTime)
}
