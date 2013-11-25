BEGIN{
	recBytes1 = 0;
	recBytes2 = 0;
	totalBytes1 = 1000000000;
	totalBytes2 = 800000 * 50;
	simulationTime = 1000;
}

{
	if($1 == "r" && $8 == 987)
		recBytes1 += $6;
	if($1 == "r" && $8 == 876)
		recBytes2 += $6;
}

END{
#Instead of 100 multipled with 10 because asked to divide by 10
	printf("Link Utilization 1(%) : %f\n",(10 * recBytes1)/totalBytes1);
	printf("Throughput 1 : %f\n",(8 * recBytes1)/simulationTime);
	
	printf("Link Utilization 2(%) : %f\n",(10 * recBytes2)/totalBytes2);
	printf("Throughput 2 : %f\n",(8 * recBytes2)/simulationTime);
	
	printf("No of receieved Bytes TCP 1 : %f\n", recBytes1);
	printf("No of receieved Bytes TCP 2 : %f\n", recBytes2);
}
