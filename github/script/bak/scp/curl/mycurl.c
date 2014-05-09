#include <stdio.h>
#include  <string.h>
#include <curl/curl.h>
 
size_t read_data(char *ptr, size_t size, size_t nmemb, void *stream)
{
//	size_t written = fwrite(ptr, size, nmemb, (FILE *)stream);
//	printf(ptr);
	
	if(strstr(ptr, "Operation completed successfully without a return value"))
		printf("find string: Operation completed sucessfully without a return value\n");
	else
		printf("can't find string\n");
	return size * nmemb;
}
	

int main(int argc, char **argv)
{
	FILE *fout;
	fout = fopen("receive.html", "rw");
	CURL *curl;
	CURLcode res;
 
	curl = curl_easy_init();
	if(curl) {
		curl_easy_setopt(curl, CURLOPT_URL, "http://sjrp01myx001/jmx-console/HtmlAdaptor?action=invokeOpByName&name=jboss.system\%3Aservice\%3DMainDeployer&methodName=checkIncompleteDeployments");
		curl_easy_setopt(curl, CURLOPT_USERPWD, "SvcAcctStubjavaLDAP:2Koffee<>Tea*");
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, read_data);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, fout);

		/* Perform the request, res will get the return code */ 
		res = curl_easy_perform(curl);
		/* Check for errors */ 
		if(res != CURLE_OK)
			fprintf(stderr, "curl_easy_perform() failed: %s\n",
					curl_easy_strerror(res));

		/* always cleanup */ 
		curl_easy_cleanup(curl);
	}
	return 0;
}

