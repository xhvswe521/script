/*
 * Sample showing how to use libssh2 to execute a command remotely.
 *
 * The sample code has fixed values for host name, user name, password
 * and command to run.
 *
 * Run it like this:
 *
 * $ ./ssh2_exec 127.0.0.1 user password "uptime"
 *
 */ 
 
#include "libssh2_config.h"
#include <libssh2.h>
 
#ifdef HAVE_WINSOCK2_H
#include <winsock2.h>
#endif
#ifdef HAVE_SYS_SOCKET_H
#include <sys/socket.h>
#endif
#ifdef HAVE_NETINET_IN_H
#include <netinet/in.h>
#endif
#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_ARPA_INET_H
#include <arpa/inet.h>
#endif
 
#include <sys/time.h>
#include <sys/types.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <ctype.h>
#include <netdb.h>
#include <string.h>

void close_channel(LIBSSH2_CHANNEL *channel);
void shutdown_socket(int *sock, LIBSSH2_SESSION *session);
//int connect_sock(int *sock, LIBSSH2_SESSION **session,LIBSSH2_CHANNEL **channel);
int create_channel(int sock, LIBSSH2_SESSION **session,LIBSSH2_CHANNEL **channel);
int cmd_request(int sock, LIBSSH2_SESSION *session,LIBSSH2_CHANNEL *channel,char *cmdline);
static int waitsocket(int socket_fd, LIBSSH2_SESSION *session);

//const char *hostname = "10.80.89.125";
//const char *commandline = "uptime";
//	const  test    = root;


static int waitsocket(int socket_fd, LIBSSH2_SESSION *session)
{
    struct timeval timeout;
    int rc;
    fd_set fd;
    fd_set *writefd = NULL;
    fd_set *readfd = NULL;
    int dir;
 
    timeout.tv_sec = 10;
    timeout.tv_usec = 0;
 
    FD_ZERO(&fd);
 
    FD_SET(socket_fd, &fd);
 
    /* now make sure we wait in the correct direction */ 
    dir = libssh2_session_block_directions(session);

 
    if(dir & LIBSSH2_SESSION_BLOCK_INBOUND)
        readfd = &fd;
 
    if(dir & LIBSSH2_SESSION_BLOCK_OUTBOUND)
        writefd = &fd;
 
    rc = select(socket_fd + 1, readfd, writefd, NULL, &timeout);
 
    return rc;
}
static void kbd_callback(const char *name, int name_len,
		const char *instruction, int instruction_len,
		int num_prompts,
		const LIBSSH2_USERAUTH_KBDINT_PROMPT *prompts,
		LIBSSH2_USERAUTH_KBDINT_RESPONSE *responses,
		void **abstract)
{
	const char *password    = "r3dSt8plr";
	(void)name;
	(void)name_len;
	(void)instruction;
	(void)instruction_len;
	if (num_prompts == 1) {
		responses[0].text = strdup(password);
		responses[0].length = strlen(password);
	}
	(void)prompts;
	(void)abstract;
} /* kbd_callback */

void close_channel(LIBSSH2_CHANNEL *channel)
{
	libssh2_channel_free(channel);
	channel = NULL;
}

void shutdown_socket(int *sock, LIBSSH2_SESSION *session)
{
	libssh2_session_disconnect(session,"Normal Shutdown, Thank you for playing");
	libssh2_session_free(session);


	close(*sock);
}


int create_channel(int sock, LIBSSH2_SESSION **session,LIBSSH2_CHANNEL **channel)
{

	while( (*channel = libssh2_channel_open_session(*session)) == NULL &&
			libssh2_session_last_error(*session,NULL,NULL,0) ==
			LIBSSH2_ERROR_EAGAIN )
	{
		waitsocket(sock, *session);
	}
	if( *channel == NULL )
	{
		fprintf(stderr,"Error\n");
		exit( 1 );
	}
	return 0;
}

int cmd_request(int sock, LIBSSH2_SESSION *session,LIBSSH2_CHANNEL *channel,char *cmdline)
{
	int rc=0;
	while( (rc = libssh2_channel_exec(channel, cmdline)) == LIBSSH2_ERROR_EAGAIN )//???????
	{
		waitsocket(sock, session);
	}
	if( rc != 0 )
	{
		fprintf(stderr,"Error\n");
		exit( 1 );
	}
	char buffer_out[2048];
	char buffer_err[2048];

	for(;;)
	{
		int rc=0;
		do
		{

			memset(&buffer_out,0,sizeof(buffer_out));
			rc = libssh2_channel_read_ex( channel,0, buffer_out, sizeof(buffer_out)-1 );
			buffer_out[rc] = '\0';
			fprintf(stdout,"%s",buffer_out);
			
			memset(&buffer_err,0,sizeof(buffer_err));
			rc = libssh2_channel_read_stderr( channel, buffer_err, sizeof(buffer_err)-1 );
			buffer_err[rc] = '\0';
			fprintf(stderr,"%s",buffer_err);

		}
		while( rc > 0 );

		if( rc == LIBSSH2_ERROR_EAGAIN )
		{
			waitsocket(sock, session);
		}
		else
			break;
	}
	    return 0;
}


int main(int argc, char *argv[])
{
	
	const char *hostname = "srwp05mgt001";
	 char *commandline = "uptime";
	const char *username    = "root";
	const char *password    = "r3dSt8plr";
//	const char *tail    = " 2>&1";
	   
	const char *fingerprint;
	unsigned long hostaddr;
	char *userauthlist;
	int sock,rc,type;
	int auth_pw = 0;
	struct sockaddr_in sin;
	//	char *exitsignal=(char *)"none";
	size_t len;
	LIBSSH2_SESSION *session;
	LIBSSH2_CHANNEL *channel;
	LIBSSH2_KNOWNHOSTS *nh;
	
	
	if (argc > 1)
	{
		commandline = argv[1];
	}
	//else{}
	if (argc > 2) {
		hostname = argv[2];
	}
	if (argc > 3) {
		username = argv[3];
	}
	if (argc > 4) {
		password = argv[4];
	}
	rc = libssh2_init (0);

	if (rc != 0) {
		fprintf (stderr, "libssh2 initialization failed (%d)\n", rc);
		return 1;
	}

	//strcat(commandline,tail);

	struct hostent *h = gethostbyname(hostname);
	hostaddr = ((struct in_addr *)h->h_addr_list[0])->s_addr;
	

	/* Ultra basic "connect to port 22 on localhost"
	 * Your code is responsible for creating the socket establishing the
	 * connection
	 */ 
	sock = socket(AF_INET, SOCK_STREAM, 0);

	sin.sin_family = AF_INET;
	sin.sin_port = htons(22);
	sin.sin_addr.s_addr = hostaddr;
	if (connect(sock, (struct sockaddr*)(&sin), sizeof(struct sockaddr_in)) != 0)
	{
		fprintf(stderr, "failed to connect!\n");
		return -1;
	}

	/* Create a session instance */ 
	session = libssh2_session_init();

	if (!session){return -1;}

	while ((rc = libssh2_session_handshake(session, sock)) == LIBSSH2_ERROR_EAGAIN);
	if (rc) {
		fprintf(stderr, "Failure establishing SSH session: %d\n", rc);
		return -1;
	}



	/*For server authentication way - a total of three types: password ,file, the keyboard*/
	userauthlist = libssh2_userauth_list(session, username, strlen(username));
	fprintf(stderr, "Authentication methods: %s\n", userauthlist);	

	if (strstr(userauthlist, "password") != NULL) { auth_pw = 1; } 
	if (strstr(userauthlist, "keyboard-interactive") != NULL){ auth_pw = 2; }
	if (auth_pw & 1)
	{   
		if (libssh2_userauth_password(session, username, password))
		{   
			fprintf(stderr, "\tAuthentication by password failed!\n");
			shutdown_socket(&sock, session);
		}   
		else
		{fprintf(stderr, "\tAuthentication by password succeeded.\n");}
	}
	else if (auth_pw & 2)
	{
		if (libssh2_userauth_keyboard_interactive(session, username,&kbd_callback) )
		{
			fprintf(stderr,"\tAuthentication by keyboard-interactive failed!\n");
			shutdown_socket(&sock, session);
		}
		else{fprintf(stderr,"\tAuthentication by keyboard-interactive succeeded.\n");}
	}	
	else
	{
		fprintf(stderr, "No supported authentication methods found!\n");
		shutdown_socket(&sock, session);
	}

	/* tell libssh2 we want it all done non-blocking */ 
	libssh2_session_set_blocking(session, 0);


	/* ... start it up. This will trade welcome banners, exchange keys,
	 * and setup crypto, compression, and MAC layers
	 */
	nh = libssh2_knownhost_init(session);

	if(!nh) {
		/* eeek, do cleanup here */ 
		return 2;
	}

	/* read all hosts from here */ 
	libssh2_knownhost_readfile(nh, "known_hosts",

			LIBSSH2_KNOWNHOST_FILE_OPENSSH);

	/* store all known hosts to here */ 
	libssh2_knownhost_writefile(nh, "dumpfile",LIBSSH2_KNOWNHOST_FILE_OPENSSH);
	fingerprint = libssh2_session_hostkey(session, &len, &type);
	if(fingerprint) {
		struct libssh2_knownhost *host;
#if LIBSSH2_VERSION_NUM >= 0x010206
		/* introduced in 1.2.6 */ 
		int check = libssh2_knownhost_checkp(nh, hostname, 22,

				fingerprint, len,
				LIBSSH2_KNOWNHOST_TYPE_PLAIN|
				LIBSSH2_KNOWNHOST_KEYENC_RAW,
				&host);
#else
		/* 1.2.5 or older */ 
		int check = libssh2_knownhost_check(nh, hostname,

				fingerprint, len,
				LIBSSH2_KNOWNHOST_TYPE_PLAIN|
				LIBSSH2_KNOWNHOST_KEYENC_RAW,
				&host);
#endif
		fprintf(stderr, "Host check: %d, key: %s\n", check,
				(check <= LIBSSH2_KNOWNHOST_CHECK_MISMATCH)?
				host->key:"<none>");

		/*****
		 * At this point, we could verify that 'check' tells us the key is
		 * fine or bail out.
		 *****/ 
	}
	else {
		/* eeek, do cleanup here */ 
		return 3;
	}
	libssh2_knownhost_free(nh);

#if 0
	libssh2_trace(session, ~0 );

#endif
	char buff[1024];
	create_channel(sock, &session,&channel);
	strcpy(buff,commandline);
        cmd_request(sock, session,channel,buff);	


	close_channel(channel);
	shutdown_socket(&sock, session);
	
	
	return 0;


}
