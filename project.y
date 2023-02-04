%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <map>
	#include <vector>
	#include <unordered_set>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);

	int linenumber = 1;

	//variable to count tabs
	int tabCount = 0;

	//variable to save block number
	int blockNum = 0;


	//array for hold block and condition flags relation
	vector<int> ifFlags(10);
	vector<int> elifFlags(10);
	vector<int> elseFlags(10);


	//save conditions blocks empty or not
	vector<int> is_if_empty(10);
	vector<int> is_elif_empty(10);
	vector<int> is_else_empty(10);	
	
	
	//for saving current variable type	
	int expr_type_int = 0;	
	int expr_type_float = 0;	
	int expr_type_string = 0;	
	
	
	//for saving variable types	
	vector<string> intVarNames;
	vector<string> floatVarNames;
	vector<string> stringVarNames;

%}



%union
{
	int number;
	char * str;
}



%token      ASSIGNOP
%token<str> INTEGER VARIABLE MATHOP FLOAT STRING IFSTR ELIFSTR ELSESTR COMPOP COLON TAB
%type<str>  condition value expression assignment statement program comparison if elif else 



%%


start:
	program{

		cout<<"void main()"<<endl;
		cout<<"{"<<endl;
		


		if(intVarNames.empty() == 0){cout<<"\tint ";}
		//print loop for type int
		if(intVarNames.empty() == 0 )
		{
			cout<< intVarNames[0] <<"_int";

			for(int i=1; i<intVarNames.size(); i++)
			{
				cout<<","<<intVarNames[i] <<"_int";
			}
		}
		if(intVarNames.empty() == 0){cout<<";"<<endl;}
		

		if(floatVarNames.empty() == 0) {cout<<"\tfloat ";}
		//print loop for type float
		if(floatVarNames.empty() == 0 )
		{
			cout<< floatVarNames[0] <<"_flt";

			for(int i=1; i<floatVarNames.size(); i++)
			{
				cout<<","<<floatVarNames[i] <<"_flt";
			}
		}
		if(floatVarNames.empty() == 0){cout<<";"<<endl;}


		if(stringVarNames.empty() == 0){cout<<"\tstring ";}
		//print loop for type string
		if(stringVarNames.empty() == 0 )
		{
			cout<< stringVarNames[0] <<"_str";

			for(int i=1; i<stringVarNames.size(); i++)
			{
				cout<<","<<stringVarNames[i] <<"_str";
			}
		}
		if(stringVarNames.empty() == 0){cout<<";"<<endl;}
		
		cout<<endl;
	
		cout<<$1;

		cout<<"}"<<endl;
	}



program:
	statement{

		$$=strdup($1);
		
	}
	|
	statement program{
		string combined=string($1)+string($2);
		$$=strdup(combined.c_str());
	}
    ;



statement:
	tabs assignment
	{
		//increment line num
		linenumber++;
		
		//checking else is empty or not 
		//if empty error 
		//else close else block and decrease blocknum

		if(blockNum == tabCount)
		{

			//for change else block empty or not
			if((elseFlags[blockNum] == 1) && (is_else_empty[blockNum] == 1))
			{
				is_else_empty[blockNum] = 0;
			}

			//cout<<"assgn line 1"<<endl;


			// add tabs to beginning
			std::string stuff(tabCount, '	');

			//combine string
			string combined="	"+stuff + string($2)+"\n";
			$$=strdup(combined.c_str());

		}
		else if((blockNum >= tabCount) && 
		((is_else_empty[blockNum] == 0)||(is_elif_empty[blockNum] == 0)||(is_if_empty[blockNum] == 0)))
		{

			blockNum = tabCount;
			elseFlags[blockNum] = 0;

			//cout<<"assgn line 0"<<endl;
			//cout<<is_else_empty[blockNum]<<endl;

			// add tabs to beginning
			std::string stuff(tabCount, '	');

			//combine string
			string combined="	}\n	"+stuff + string($2)+"\n";
			$$=strdup(combined.c_str());
		}
		else
		{
			cout<<"error in line  "<< linenumber-1 <<": at least one line should be inside if/elif/else block "<<endl;
			exit(1);
		}
		//reset tab counter
		tabCount = 0;
	}
	|
	condition
	{
		//increment line num
		linenumber++;

		//reset tab counter
		tabCount = 0;
	}
	;


  
condition:
	tabs if
	{
		
		if(blockNum == tabCount)
		{

			//cout<<"if condition"<<endl;
			is_if_empty[blockNum] = 1;
			// add tabs to beginning
			std::string stuff(tabCount, '	'); 
			//combine string
			string combined="	"+ stuff + string($2)+"\n"+"	"+stuff+"{"+"\n";
			$$=strdup(combined.c_str());


			//new condition block opened create new block
			blockNum++;

			//if flag is opened
			ifFlags[blockNum] = 1;

		}
		else
		{
			cout<<"tab inconsistency in line "<<linenumber<<endl;
			exit(1);
		}
	}
	|
	tabs elif
	{

		if((blockNum-1 == tabCount) && (ifFlags[blockNum] != 0))
		{

			//cout<<"elif condition"<<endl;

			//combine string
			string combined="	"+string($2)+"\n	{\n";
			$$=strdup(combined.c_str());


			//elif block oepened
			elifFlags[blockNum] = 1;

			//if block closed when elif opened
			ifFlags[blockNum] = 0;
			//cout<<"!! if closed !!"<<endl;

		}
		else
		{
			cout<<"tab inconsistency in line "<<linenumber<<endl;
			exit(1);
		}
	}
	|
	tabs else 
	{

		if((blockNum-1 == tabCount) && ((elifFlags[blockNum] != 0) || (ifFlags[blockNum] != 0)))
		{

			//combine string
			string combined="	}\n	"+string($2)+"\n	{\n";
			$$=strdup(combined.c_str());
			//cout<<"else condition"<<endl;


			//else block opened
			elseFlags[blockNum] = 1;

			//set else block empty at initilization
			is_else_empty[blockNum] = 1;

			//if block closed when else opened
			ifFlags[blockNum] = 0;
			//cout<<"!! if closed !!"<<endl;

			//elif block closed when else opened
			elifFlags[blockNum] = 0;
			//cout<<"!! elif closed !!"<<endl;

			
			
		}
		else
		{
			cout<<"tab inconsistency in line "<<linenumber<<endl;
			exit(1);
		}
	}
	;



tabs:
	tabs TAB {tabCount++;} //for counting tabs 
	|

	;



if:
	IFSTR comparison COLON
	{
		string combined="if " + string($2) ;
		$$=strdup(combined.c_str());
	}
	;




elif:
	ELIFSTR comparison COLON
	{
		string combined="elif "+string($2) ;
		$$=strdup(combined.c_str());
	}
	;



else:
	ELSESTR COLON
	{
		string combined="else";
		$$=strdup(combined.c_str());
	}
	;


comparison:
	value COMPOP value
	{
		string combined=string($1)+string($2)+string($3);
		$$=strdup(combined.c_str());
	}
	;




assignment:
	VARIABLE ASSIGNOP expression
	{
		//put variable to right array from looking type of espression


		//string for x_typeName
		string typeString;

		
		if((expr_type_int == 1)&&(expr_type_float == 0))
		{

			//cout<<"int"<<endl;
			typeString = "_int";

			int flag = 0;

			//fix for double variable declaration
			for(int i=0; i<intVarNames.size(); i++)
			{

				if(intVarNames[i] == string($1)){flag = 1;;}
			}
			
			if(flag == 0){intVarNames.push_back(string($1));}
		}
		else if((expr_type_float == 1)&&(expr_type_int == 1))
		{
			//cout<<"flot"<<endl;

			typeString = "_flt";

			int flag = 0;

			//fix for double variable declaration
			for(int i=0; i<floatVarNames.size(); i++)
			{

				if(floatVarNames[i] == string($1)){flag = 1;}
			}
			if(flag == 0){floatVarNames.push_back(string($1));}
		}
		else if((expr_type_float == 1))
		{

			//cout<<"flot"<<endl;

			typeString = "_flt";

			int flag = 0;

			//fix for double variable declaration
			for(int i=0; i<floatVarNames.size(); i++)
			{
				
				if(floatVarNames[i] == string($1)){flag = 1;}
			}
			if(flag == 0){floatVarNames.push_back(string($1));}
		}
		else if((expr_type_string == 1))
		{

			//cout<<"str"<<endl;

			typeString = "_str";

			int flag = 0;

			//fix for double variable declaration
			for(int i=0; i<stringVarNames.size(); i++)
			{
				
				if(stringVarNames[i] == string($1)){flag = 1;}
			}
			if(flag == 0){stringVarNames.push_back(string($1));}
		}
		else
		{
			cout<<"!! unkown type !!"<<endl;
			exit(1);
		}


		// check variable type in type arrays?
		// travel array backwards (to find latest updated type)


		string combined =   string($1) + typeString + "="+string($3);
		$$=strdup(combined.c_str());


		//reset type flags
		expr_type_int = 0;
		expr_type_float = 0;
		expr_type_string = 0;
	}
	;



expression:
	value 
	{
		$$=strdup($1);
	}
	|
	expression MATHOP value
	{
		string combined=string($1)+string($2)+string($3);
		$$=strdup(combined.c_str());
	}
	;


value:
	VARIABLE
	{
		string typeString;
		for(int i=0; i<floatVarNames.size(); i++)
		{
			if(floatVarNames[i] == string($1))
			{
				expr_type_float = 1;
				typeString = "_flt";
			}
		}
		for(int i=0; i<intVarNames.size(); i++)
		{
			if(intVarNames[i] == string($1))
			{
				expr_type_int = 1;
				typeString = "_int";
			}
		}
		for(int i=0; i<stringVarNames.size(); i++)
		{
			if(stringVarNames[i] == string($1))
			{
				expr_type_string = 1;
				typeString = "_str";
			}
		}

		string combined = string($1) + typeString;
		$$=strdup(combined.c_str());
	}
	|
	INTEGER 
	{
		//set flag expr type
		expr_type_int = 1;

		$$=strdup($1);
	}
	|
	FLOAT 
	{
		//set flag expr type
		expr_type_float = 1;

		$$=strdup($1);
	}
	|
	STRING 
	{
		//set flag expr type
		expr_type_string = 1;

		$$=strdup($1);
	}
	;


%%



void yyerror(string s){
	cout<<"error: "<<s<<endl;
}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
    return 0;
}