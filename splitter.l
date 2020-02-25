%{

#include <stdio.h>
#include <syslog.h>
#include "y.tab.h"

char s[80]="";
char k[80]="";

%}
%%
[[:digit:]]+\. {
	    syslog( LOG_DEBUG, "Read number: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(NUMBER);
	}
([a-h][1-8]){2}[BNRQ]? {
	    syslog( LOG_DEBUG, "Read lan: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(LAN);
	}
[a-h1-8pbnrqkPBNRQKxO=\+\-]+ {
	    syslog( LOG_DEBUG, "Read san: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(SAN);
	}
(1-0|0-1|1\/2-1\/2)$ {
	    syslog( LOG_DEBUG, "Read result: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(RESULT);
	}
[\[\]] { 
	    syslog( LOG_DEBUG, "Read bracket");
            strcpy(s, yytext); 
	    yylval.s = s;
            return(BRACKET);
	}
[\"] { 
	    syslog( LOG_DEBUG, "Read quote");
            strcpy(s, yytext); 
	    yylval.s = s;
            return(QUOTE);
	}
[,] { 
	    syslog( LOG_DEBUG, "Read comma");
            strcpy(s, yytext); 
	    yylval.s = s;
            return(COMMA);
	}
[\n] { 
	    syslog( LOG_DEBUG, "Read new line");
            strcpy(k, yytext); 
	    yylval.k = k;
            return(NEWLINE);
	}
[ ] { 
//	    syslog( LOG_DEBUG, "Read space");
//          return(SPACE);
	}
^\[HashCode\ \"[0-9a-f]{8}\"\]$ {
	    syslog( LOG_DEBUG, "Read hash tag: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(HASHTAG);
	}
^\[(Event|Site|Date|Round|White|Black|Result)\ \"[[:print:]\x80-\xf3]*\"\]$ {
// \x80-\xbf\xc2-\xdf\xe0-\xef\xf0-\xf4
	    syslog( LOG_DEBUG, "Read roster tag: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(ROSTER);
	}
^\[[[:alpha:]]+\ \"[[:print:]\x80-\xf3]*\"\]$ {
	    syslog( LOG_DEBUG, "Read tag: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(TAG);
	}
.       { // Garbage
	    syslog( LOG_DEBUG, "???: %s", yytext);
	}
%%
