%{

#include <stdio.h>
#include <syslog.h>
#include "y.tab.h"

char s[BUFSIZ]="";

%}
%%
[[:digit:]]+\. {
	    syslog( LOG_DEBUG, "Read number: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(NUMBER);
	}
([a-h][1-8]){2}[BNRQ]? {
	    syslog( LOG_DEBUG, "Read san: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(SAN);
	}
[a-h1-8pbnrqkPBNRQKxO=\+\-]+ {
	    syslog( LOG_DEBUG, "Read move: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(MOVE);
	}
(1-0|0-1|1\/2-1\/2)$ {
	    syslog( LOG_DEBUG, "Read result: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(RESULT);
	}
[\[\]]   { 
	    syslog( LOG_DEBUG, "Read bracket");
            strcpy(s, yytext); 
	    yylval.s = s;
            return(BRACKET);
	}
[\"]   { 
	    syslog( LOG_DEBUG, "Read quote");
            strcpy(s, yytext); 
	    yylval.s = s;
            return(QUOTE);
	}
[,]   { 
	    syslog( LOG_DEBUG, "Read comma");
            strcpy(s, yytext); 
	    yylval.s = s;
            return(COMMA);
	}
[\n]   { 
	    syslog( LOG_DEBUG, "Read new line");
            strcpy(s, yytext); 
	    yylval.s = s;
            return(NEWLINE);
	}
[ ]  { 
//	    syslog( LOG_DEBUG, "Read space");
//          return(SPACE);
	}
^\[HashCode\ \"[0-9a-f]{8}\"\]$ {
	    syslog( LOG_DEBUG, "Read hash tag: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(HASHTAG);
	}
^\[[[:alpha:]]+\ \"[[:print:]]*\"\]$ {
	    syslog( LOG_DEBUG, "Read tag: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(TAG);
	}
.       { // Garbage
	    syslog( LOG_DEBUG, "???: %s", yytext);
	}
%%
