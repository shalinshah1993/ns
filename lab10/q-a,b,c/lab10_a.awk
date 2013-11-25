BEGIN{
	totalBytes = 1000000000;
	recBytes = 0;
}

{
	if($1 == "r")
		recBytes += $6;	
}

END{
	printf("Link Utilizatio(%) : %f\n",(100 * recBytes)/totalBytes);
}
