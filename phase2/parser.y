
%union {
	int ival;
	float fval;
	char cval;
  char* sval;
}

%token <sval> ID
%token <sval> NUM
%token  <sval> dtype
%token <sval> assop
%token <sval> sumop
%token <sval> mulop
%token <sval> unary
%token <sval> logicalopbin
%token <sval> logicalnot
%token <sval> relop
%token <sval> ifstmt
%token <sval> elsestmt
%token <sval> whilestmt
%token <sval> charcnst
%token <sval> floatcnst
%token <sval> stringcnst
%token <sval> breakval
%token <sval> returnval
%token <sval> switchval
%token <sval> casestmt
%token <sval> defaultstmt
%type<sval>statement
%type<sval>typeSpecifier
%type<sval>params
%type<sval>funDeclaration
%type<sval>funName
%{
	#include<stdio.h>
#include<string.h>
	FILE *yyin;
	extern int line;
unsigned long hash(unsigned char *str)
{
    unsigned long hash = 5381;
    int c;

    while (c = *str++)
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

    return hash;
}

//symbol table
struct symbol{
int valid;
char name[100];
char type[100];
int lineno[100];
int linecount;
struct symbol *next;
} symboltable[65535];

//constants table
struct constants{
int valid;
char name[100];
char type[100];
int lineno[100];
int linecount;
struct constants *next;
} constantstable[65535];

//no of constants
int countconstants=0;
int countsymbol=0;
//function to add symbol to symbol table
void push_to_symbol_table(char ctemp[],char type[],int l)
{
	unsigned long map=hash(ctemp);
map=map%65535;
	int len=strlen(ctemp);
	if(symboltable[map].valid==1&&strcmp(symboltable[map].name,ctemp)==0) //case when the symbol is already in table first
	{
		
		symboltable[map].lineno[symboltable[map].linecount]=l;
		symboltable[map].linecount++;

	}
	else if(symboltable[map].valid==1&&strcmp(symboltable[map].name,ctemp)!=0)//case when symbol not in table first
	{
		int found=0;
		struct symbol * pointer=&symboltable[map];
		while(pointer->next!=NULL)
		{
			if(strcmp(pointer->name,ctemp)==0)				
				{
					found=1;
				}
				pointer=pointer->next;
		}
		if(found==0)													////case when symbol not found
		{
			struct symbol * tempsymbol;
			strncpy(tempsymbol->name,ctemp,len);
			strcpy(tempsymbol->type,type);
			tempsymbol->linecount=0;
			tempsymbol->valid=1;
			tempsymbol->next=NULL;
			tempsymbol->lineno[tempsymbol->linecount]=l;
			tempsymbol->linecount++;
			pointer->next=tempsymbol;
		}
		if(found==1)													//case when symbol found at some other position
		{
			pointer->lineno[pointer->linecount]=l;
			pointer->linecount++;

		}

	}
	else{														   //hashtable map is free
		strncpy(symboltable[map].name,ctemp,len);
		strcpy(symboltable[map].type,type);
		symboltable[map].linecount=0;
		symboltable[map].valid=1;
		symboltable[map].next=NULL;
		symboltable[map].lineno[symboltable[map].linecount]=l;
		symboltable[map].linecount++;
		++countsymbol;
		}
		


}
//function to add constants to constant table
void push_to_constants_table(char ctemp[],char type[],int l)								//case when the symbol is already in table first
{
	unsigned long map=hash(ctemp);
	map=map%65535;
	int len=strlen(ctemp);
	if(constantstable[map].valid==1&&strcmp(constantstable[map].name,ctemp)==0)
			{
				constantstable[map].lineno[constantstable[map].linecount]=l;
				constantstable[map].linecount++;
				

			}
			else if(constantstable[map].valid==1&&strcmp(constantstable[map].name,ctemp)!=0)		//case when symbol not in table first
			{
				int found=0;
				struct constants * pointer=&constantstable[map];
				while(pointer->next!=NULL)
				{
					if(strcmp(pointer->name,ctemp)==0)
						{
							found=1;
						}
					pointer=pointer->next;
				}
				if(found==0)														////case when symbol not found
				{
					struct constants * tempconstants;
					strncpy(tempconstants->name,ctemp,l);
					strcpy(tempconstants->type,type);
					tempconstants->linecount=0;
					tempconstants->valid=1;
					tempconstants->next=NULL;
					tempconstants->lineno[tempconstants->linecount]=l;
					tempconstants->linecount++;
					pointer->next=tempconstants;
				}
				if(found==1)													//case when symbol found at some other position				
				{
					pointer->lineno[pointer->linecount]=l;
					pointer->linecount++;

				}

			}
			else{																				//hashtable map is free
				strncpy(constantstable[map].name,ctemp,l);
				strcpy(constantstable[map].type,type);
				constantstable[map].linecount=0;
				constantstable[map].valid=1;
				constantstable[map].next=NULL;
				constantstable[map].lineno[constantstable[map].linecount]=l;
				constantstable[map].linecount++;
				++countconstants;
				}
}

%}
%%

ED:program
{
	printf("Valid Expressions : ");
}
;
program:expressionsemi
|declarationList
|selectionstmt
|iterationwhile
|calling
|switch
;


declarationList:declaration declarationListhelper
;
declarationListhelper:
|declaration declarationListhelper
;




declaration: varDeclaration
|funDeclaration
;
varDeclaration: typeSpecifier varDeclList ';'
;

varDeclList:varDeclInitialize varDeclListhelper
;
varDeclListhelper:
|','varDeclInitialize varDeclListhelper
;






varDeclInitialize:varDeclId
;
varDeclId:ID {printf("%s",$1); push_to_symbol_table($1,"data",line);}
|
ID '[' NUM ']' {printf("%s",$1); push_to_symbol_table($1,"dataarr",line);push_to_constants_table($3,"function",line);}
;
typeSpecifier:dtype  {$$="hai";}
;

funDeclaration: typeSpecifier funName '(' params ')' statement {}
;
funName:ID{$$=$1; printf("%s",$1); push_to_symbol_table($1,"function",line);}
;
params: {$$="hello";}
|paramList {$$="hello";}
;

paramList: typeSpecifier varDeclId ','paramList
|typeSpecifier varDeclId
;
 
statement: '{' stmtlist '}' {$$="null";}
|'{''}'
;

loopstatement: '{'loopstmtlist'}'
|'{''}'
;
stmtlist:stmtlist expressionsemi
|stmtlist varDeclaration
|expressionsemi
|varDeclaration
|stmtlist selectionstmt
|stmtlist iterationwhile
|stmtlist returnstmt
|stmtlist switch
|stmtlist calling
|calling
|switch
|returnstmt
|selectionstmt
;


returnstmt: returnval ';'
|returnval simpleExpression ';'
;
loopstmtlist:stmtlist
|breakval ';'
;
selectionstmt:ifstmt '(' simpleExpression ')' statement
|ifstmt '(' simpleExpression ')' statement elsestmt  selectionhelper
;
selectionhelper: selectionstmt
|statement
;
expressionsemi:expression ';'
;
expression: mutable assop expression  { /*printf( " found assignment an:   %s\n" ,$2); */}
|simpleExpression 
|unary mutable 
|mutable unary
;
simpleExpression: simpleExpression logicalopbin unaryRelExpression
|unaryRelExpression 
;

unaryRelExpression: logicalnot unaryRelExpression
|relExpression
;
relExpression:sumExpression relop sumExpression
|sumExpression
;

sumExpression:sumExpression sumop term 
|term
;

term:term mulop factor
|factor
;

iterationwhile:whilestmt'('simpleExpression')'loopstatement
;

factor:immutable
|mutable
;

mutable:mutable'['simpleExpression']'
|mutable'['unary mutable']'
|mutable'['mutable unary']'
|'&' ID {printf("%s",$2);  push_to_symbol_table($2,"data",line); }
|ID	{printf("%s",$1);  }
;


immutable:NUM	{printf("%s",$1); push_to_constants_table($1,"number",line);}
|charcnst	{printf("%s",$1); push_to_constants_table($1,"character",line);}
|stringcnst	{printf("%s",$1); push_to_constants_table($1,"string",line);}
|floatcnst	{printf("%s",$1); push_to_constants_table($1,"float",line);}
;

calling:funName'('args')'';'	
;
args:
|arglist
;
arglist:arglist','expression
|expression
;




switch:switchval '(' expression ')''{' switchstatement '}'
;
switchstatement:
| casestmt  switchimmutable ':' loopstmtlist switchstatement
|casestmt  switchimmutable ':''{' loopstmtlist '}' switchstatement
|defaultstmt ':' loopstmtlist
|defaultstmt ':''{'loopstmtlist'}'
;
switchimmutable:NUM {printf("%s",$1); push_to_constants_table($1,"function",line);}
|charcnst {printf("%s",$1); push_to_constants_table($1,"function",line);}
;	
%%
void yyerror()
{
	printf("Invalid expressions at line %d : \n",line);
}
int main()
{
	yyin=fopen("tester.c","r");
	yyparse();
	printf("\n\t\t\t\t\tsymbols table\n");
	printf("%s \t\t %s \t\t %s \t\t %s \t\t %s \n","ID","name","type","linecount","linenumbers");
	for(int i=0;i<65535;++i)
	{
			if(symboltable[i].valid==1)
			{
				struct symbol * pointer=&symboltable[i];
				while(pointer->next!=NULL)
					{
						printf("%d \t\t %s \t\t %s \t\t %d ",i,pointer->name,pointer->type,pointer->linecount);
						for(int j=0;j<pointer->linecount;++j)
						{
							printf("\t%d ",pointer->lineno[j]);
						}
							pointer=pointer->next;
						
					}
				printf("%d \t\t %s \t\t %s\t\t %d ",i,pointer->name,pointer->type,pointer->linecount);
						for(int j=0;j<pointer->linecount;++j)
						{
							printf("\t%d ",pointer->lineno[j]);
						}
							pointer=pointer->next;
			
				printf("\n");
			}
	}
printf("\n\n\t\t\t\t\tconstant table\n");
	printf("%s \t\t %s \t\t %s \t\t %s \t\t %s \n","ID","name","type","linecount","linenumbers");
	for(int i=0;i<65535;++i)
	{
			if(constantstable[i].valid==1)
			{
				struct constants * pointer=&constantstable[i];
				while(pointer->next!=NULL)
					{
						printf("%d \t\t %s \t\t %s \t\t %d ",i,pointer->name,pointer->type,pointer->linecount);
						for(int j=0;j<pointer->linecount;++j)
						{
							printf("\t%d ",pointer->lineno[j]);
						}
						pointer=pointer->next;
						
					}
				printf("%d \t\t %s \t\t %s \t\t %d ",i,pointer->name,pointer->type,pointer->linecount);
				for(int j=0;j<pointer->linecount;++j)
				{
					printf("\t%d ",pointer->lineno[j]);
				}
				pointer=pointer->next;
				printf("\n");
			}
	}
	return 0;
}
