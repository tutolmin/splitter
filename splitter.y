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

char json_str[BUFSIZ]="";
char pgn_str[BUFSIZ]="";

%}

%start games

%token TAG MOVE NUMBER RESULT NEWLINE COMMA QUOTE BRACKET HASHTAG SAN

%union { char* s; }

%token <s> TAG MOVE NUMBER RESULT NEWLINE COMMA QUOTE BRACKET HASHTAG SAN

%%                   /* beginning of rules section */

games:  tags
	|
	json
	|
	moves
	|
	NEWLINE
	;
json:   BRACKET
	{
	strcpy( json_str, "");
	strcat( json_str, $1);
	}
	|
	json QUOTE
	{
	strcat( json_str, $2);
	}
	|
	json SAN
	{
	strcat( json_str, $2);
	}
	|
	json COMMA
	{
	strcat( json_str, $2);
	}
	|
	json BRACKET
	{
	strcat( json_str, $2);
	}
	|
	json NEWLINE
	{
        syslog( LOG_NOTICE, "Flush json: %s", json_str);
	}
	;
tags:   TAG
	{
	strcat( pgn_str, $1);
	strcat( pgn_str, "\n");
	}
	|
	HASHTAG
	|
	tags TAG
	{
	strcat( pgn_str, $2);
	}
	|
	tags NEWLINE
	{
	strcat( pgn_str, "\n");
	}
	;
moves:  RESULT
	{
	strcat( pgn_str, $1);
        syslog( LOG_NOTICE, "Flush pgn.");
	strcpy( pgn_str, "");
	}
	|
	MOVE
	{
	strcat( pgn_str, $1);
	strcat( pgn_str, " ");
	}
	|
	NUMBER MOVE
	{
	strcat( pgn_str, $1);
	strcat( pgn_str, " ");
	strcat( pgn_str, $2);
	strcat( pgn_str, " ");
	}
	|
	moves NUMBER
	{
	strcat( pgn_str, $2);
	strcat( pgn_str, " ");
	}
	|
	moves MOVE
	{
	strcat( pgn_str, $2);
	strcat( pgn_str, " ");
	}
	|
	moves RESULT
	{
	strcat( pgn_str, $2);
        syslog( LOG_NOTICE, "Flush pgn: %d %s", strlen( pgn_str), pgn_str);
	strcpy( pgn_str, "");
	}
	|
	moves NEWLINE
	{
	strcat( pgn_str, "\n");
	}
	;
%%

int main( int argc, char **argv) {

	// Set log mask to avoid unnecessary output
	setlogmask( LOG_UPTO( LOG_DEBUG)); // LOG_NOTICE LOG_INFO LOG_DEBUG

	// Open syslog stream LOG_LOCAL1 
	openlog( "splitter", LOG_NDELAY, LOG_DAEMON);

        // Evaluator starting
        syslog( LOG_NOTICE, "Program start.");

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

	return(0);
}

int yylex( void);

int yyerror( const char *s)
//char *s;
{
  syslog( LOG_ERR, "yyerror: %s", s);

  return(1);
}

int yywrap( void)
{
//  sprintf( logstr, "yywrap");
//  syslog( LOG_DEBUG, logstr);

  return(1);
}

