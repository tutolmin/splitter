%{
/*
#include <signal.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/time.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <math.h>
*/

#include <stdio.h>
#include <unistd.h>
#include <syslog.h>
#include <string.h>
#include <openssl/md5.h>

// Try to get more verbose output from byacc
#define YYERROR_VERBOSE 1

int yyerror( const char *s);
int yywrap( void);
//extern yy_buffer_state;
typedef struct yy_buffer_state * YY_BUFFER_STATE;

//typedef yy_buffer_state *YY_BUFFER_STATE;
int yyparse( void);
YY_BUFFER_STATE yy_scan_string(char *, size_t);
void yy_delete_buffer(YY_BUFFER_STATE buffer);

char tmp_str[BUFSIZ]="";
char json_str[BUFSIZ-2]="";
char moves_str[BUFSIZ]="";
char tags_str[BUFSIZ]="";
char roster_str[BUFSIZ]="";
char roster_hash[BUFSIZ]="";

%}

%start games

%token SAN LAN NUMBER RESULT NEWLINE COMMA QUOTE BRACKET TAG HASHTAG ROSTER

%union { char* s; char* k; }

%token <k> NEWLINE
%token <s> SAN LAN NUMBER RESULT BRACKET COMMA QUOTE TAG HASHTAG ROSTER

%%                   /* beginning of rules section */

games:	
	|
	tags NEWLINE moves NEWLINE
	{
	strcat( tags_str, $2);
        syslog( LOG_NOTICE, "Flush pgn tags: %ld %s", strlen( tags_str), tags_str);
        syslog( LOG_NOTICE, "Flush pgn moves: %ld %s", strlen( moves_str), moves_str);
	strcpy( tags_str, "");
	strcpy( moves_str, "");
	strcpy( roster_str, "");
        strcpy( roster_hash, "");
	}
	|
	games tags NEWLINE moves NEWLINE
	{
	strcat( tags_str, $3);
        syslog( LOG_NOTICE, "Flush pgn tags: %ld %s", strlen( tags_str), tags_str);
        syslog( LOG_NOTICE, "Flush pgn moves: %ld %s", strlen( moves_str), moves_str);
	strcpy( tags_str, "");
	strcpy( moves_str, "");
	strcpy( roster_str, "");
        strcpy( roster_hash, "");
	}
	|
	tags NEWLINE json NEWLINE moves NEWLINE
	{
	strcat( tags_str, $2);
        syslog( LOG_NOTICE, "Flush pgn tags: %ld %s", strlen( tags_str), tags_str);
        syslog( LOG_NOTICE, "Flush pgn moves: %ld %s", strlen( moves_str), moves_str);
	strcpy( tags_str, "");
	strcpy( moves_str, "");
	strcpy( roster_str, "");
        strcpy( roster_hash, "");
	}
	|
	games tags NEWLINE json NEWLINE moves NEWLINE
	{
	strcat( tags_str, $3);
        syslog( LOG_NOTICE, "Flush pgn tags: %ld %s", strlen( tags_str), tags_str);
        syslog( LOG_NOTICE, "Flush pgn moves: %ld %s", strlen( moves_str), moves_str);
	strcpy( tags_str, "");
	strcpy( moves_str, "");
	strcpy( roster_str, "");
        strcpy( roster_hash, "");
	}
	;
json:   BRACKET BRACKET NEWLINE
	{
	strcat( json_str, "[");
	strcat( json_str, $2);
	strcat( json_str, $3);
        syslog( LOG_DEBUG, "Flush json: %ld %s", strlen( json_str), json_str);
	strcpy( json_str, "");
	}
	|
	BRACKET lan_str NEWLINE
	{
	sprintf( tmp_str, "%s%s\n", $1, json_str);
	strcpy( json_str, tmp_str);
        syslog( LOG_DEBUG, "bracket lan_str_newline");
	}
	|
	json lan_str NEWLINE
	{
	strcat( json_str, $3);
        syslog( LOG_DEBUG, "lan_str_newline '%s'", $3);
	}
	|
	json lan_str BRACKET NEWLINE
	{
	sprintf( tmp_str, "%s%s\n", json_str, $3);
	strcpy( json_str, tmp_str);
        syslog( LOG_DEBUG, "Flush json: %ld %s", strlen( json_str), json_str);
	strcpy( json_str, "");
	}
	;
lan_str: QUOTE
	{
	strcat( json_str, $1);
	}
	|
	lan_str LAN
	{
	strcat( json_str, $2);
	}
	|
	lan_str QUOTE
	{
	strcat( json_str, $2);
	}
	|
	lan_str COMMA
	{
	strcat( json_str, $2);
	}
	;
tags:   ROSTER NEWLINE
	{
	strcat( tags_str, $1);
	strcat( tags_str, $2);

	char *token=NULL;
	strtok( $1, "\"");
	token = strtok( NULL, "\"");
        syslog( LOG_DEBUG, "Value: %s", token);
	strcat( roster_str, token);
	}
	|
	TAG NEWLINE
	{
	strcat( tags_str, $1);
	strcat( tags_str, $2);
	}
	|
	tags ROSTER NEWLINE
	{
	strcat( tags_str, $2);
	strcat( tags_str, $3);

	char *token=NULL;
	strtok( $2, "\"");
	token = strtok( NULL, "\"");
        syslog( LOG_DEBUG, "Value: %s", token);
	strcat( roster_str, "|");
	strcat( roster_str, token);
	}
	|
	tags HASHTAG NEWLINE
	{
	strcat( tags_str, $2);
	strcat( tags_str, $3);

	char *token=NULL;
	strtok( $2, "\"");
	token = strtok( NULL, "\"");
        syslog( LOG_DEBUG, "Value: %s", token);
	strcat( roster_str, "|");
	strcat( roster_str, token);

    // Compute tag roster hash
    unsigned char result_hash[MD5_DIGEST_LENGTH];
    MD5( (const unsigned char*)roster_str, strlen( roster_str), result_hash);
    for( int i=0; i <MD5_DIGEST_LENGTH; i++) {
        char var_str[3]="";
        sprintf( var_str, "%02x",result_hash[i]);
        strcat( roster_hash, var_str);
    }

        syslog( LOG_NOTICE, "Flush tags: %ld %s", strlen( roster_str), roster_str);
        syslog( LOG_NOTICE, "Flush roster hash: %ld %s", strlen( roster_hash), roster_hash);
	}
	|
	tags TAG NEWLINE
	{
	strcat( tags_str, $2);
	strcat( tags_str, $3);
	}
	;
moves:  RESULT NEWLINE
	{
	strcat( moves_str, $1);
	strcat( moves_str, $2);
	}
	|
	san_str RESULT NEWLINE
	{
	strcat( moves_str, $2);
	strcat( moves_str, $3);
	}
	|
	san_str NEWLINE
	{
	strcat( moves_str, $2);
	}
	|
	moves san_str NEWLINE
	{
	strcat( moves_str, $3);
	}
	|
	moves RESULT NEWLINE
	{
	strcat( moves_str, $2);
	strcat( moves_str, $3);
	}
	|
	moves san_str RESULT NEWLINE
	{
	strcat( moves_str, $3);
	strcat( moves_str, $4);
	}
	;
san_str: SAN
	{
	strcat( moves_str, $1);
	strcat( moves_str, " ");
	}
	|
	NUMBER
	{
	strcat( moves_str, $1);
	strcat( moves_str, " ");
	}
	|
	san_str NUMBER
	{
	strcat( moves_str, $2);
	strcat( moves_str, " ");
	}
	|
	san_str SAN
	{
	strcat( moves_str, $2);
	strcat( moves_str, " ");
	}
	;
%%

int main( int argc, char **argv) {

	// Set log mask to avoid unnecessary output
	setlogmask( LOG_UPTO( LOG_NOTICE)); // LOG_NOTICE LOG_INFO LOG_DEBUG

	// Open syslog stream LOG_LOCAL1 
	openlog( "splitter", LOG_NDELAY, LOG_DAEMON);

        // Evaluator starting
        syslog( LOG_NOTICE, "Program start.");
	
        // Parse the line
        yyparse();
/*
	// Forever cycle
	while( 1) {

        char    readbuffer[2]="";
	char	sf_line[BUFSIZ/2]="";

	// Read single char from a pipe
	while( read( 0, readbuffer, 1)) {
	    strcat( sf_line, readbuffer);
	    if(readbuffer[0] == '\n') {

//		sprintf( logstr, "Got EOL, read: %s", sf_line);
//		syslog( LOG_DEBUG, logstr);

    // Our input file may contain NULs ('\0') so we MUST use
    // yy_scan_buffer() or yy_scan_bytes(). For a normal C (NUL-
    // terminated) string, we are better off using yy_scan_string() and
    // letting flex manage making a copy of it so the original may be a
    // const char (i.e., literal) string.
    YY_BUFFER_STATE buffer = yy_scan_string( sf_line,strlen(sf_line));
	
    // Parse the line
    yyparse();

    // After flex is done, tell it to release the memory it allocated.    
    yy_delete_buffer( buffer);

		// Get ready to read new line
		strcpy( sf_line, "");
	    }
	}
        }
*/
	return(0);
}

int yylex( void);

int yyerror( const char *s)
{
  syslog( LOG_ERR, "yyerror: %s", s);

  return(1);
}

int yywrap( void)
{
  syslog( LOG_NOTICE, "Program end.");

  return(1);
}

