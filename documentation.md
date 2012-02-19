Title:    C Template Library
Author:   Stephen C. Losen, University of Virginia


# Introduction

*C Template* is a template expander library written in C and is similar to the perl `HTML::Template` module. Input to the expander is a template file (or string), a *variable list* (`TMPL_varlist`), and an optional *format function list* (`TMPL_fmtlist`).  The expander processes the template using the variables in the variable list, and outputs the result.

Using templates makes it easier to separate *information* (the variable list) from the *presentation* (the template file and format functions). You can construct a variable list that can be output in a variety of formats or languages, using different templates. The template language is simple, but powerful enough for you to design flexible templates that handle many different situations. The C Template library is fast and efficient because it is written in C, and the API is easy to use.


# Template Files

A template file consists of *text sequences*, *template tags* and *comments*. Text sequences are copied to the output. Template tags are removed from the input, processed, and the result is output. Comments are removed from the input and do not appear in the output.

The template language supports these features:

- variable substitution (with optional formatting)

- *if statements* for defining conditionally expanded template sections

- *loop statements* for defining repeatedly expanded template sections

- file inclusion

- comments


# Text Sequences

A *text sequence* is any sequence of characters that is not a template tag and not a comment. A text sequence is copied unchanged to the output with a few exceptions. You can use a backslash (`\\`) to suppress outputting a line terminator. A single `\\` at the end of a line is not output and neither is the line terminator. You can escape this behavior with two backslashes (`\\`) at the end of a line, which is output as a single `\\` followed by the line terminator. Any other `\\` is copied unchanged to the
output.


# Comments

Any text (including template tags and line terminators) enclosed by `<*` and `*>` is a comment, which the expander does not output. Comments cannot be nested. Within a comment `<*` is ignored and the comment ends at the first `*>` A `*>` without a preceding `<*` is considered ordinary text. A `<*` without a following `*>` is an error. Template tags may not contain comments because inserting a comment into a tag splits it into ordinary text sequences. If your template needs to output a literal `<*`, you can split `<` and `*` with a short comment like this:

		<<**>*.

You are certainly free to use comments supported by whatever language that your template outputs. For example, you can use HTML comments such as `<!-- this is a comment -->`. The template expander treats this as ordinary text and copies it to the output.


# Template Tags

The template language has the following tags.

`<TMPL_VAR name="varname" default="value" fmt="fmtname">`
: Variable substitution. The tag is replaced in the output with the value of the variable named *varname*. If *varname* does not exist, then the tag disappears in the output, unless you specify a default value to output with the optional `default="value"` attribute. If *varname* exists, but has a null value (""), then the null value is output.

	Usually the value is output without modification. The optional `fmt="fmtname"` attribute specifies a *format function* that the expander calls to output the value with appropriate formatting or encoding. The format function is also called when a tag's default value is output.

`<TMPL_IF name="varname" value="testvalue">`
: Introduces an if statement. The `value="testvalue"` attribute is optional. The tag evaluates to true or false as follows:

	`<TMPL_IF name="varname">`
	: is true if variable *varname* exists and has a non-null value, otherwise false. You can also use this to test for the existence of a loop variable.

	`<TMPL_IF name="varname" value="testvalue">`
	: is true if variable *varname* exists and has the value *testvalue*, otherwise false.

	`<TMPL_IF name="varname" value="">`
	: is true if variable *varname* does not exist or has a null value, otherwise false. You can also use this to test for the non-existence of a loop variable.

`<TMPL_ELSIF name="varname" value="testvalue">`
:	A component of an if statement. The *value="testvalue"* attribute is optional. The `TMPL_ELSIF` tag evaluates to true or false using the same rules as the `TMPL_IF` tag.

`<TMPL_ELSE>`
:	A component of an if statement.

`</TMPL_IF>`
:	Terminates an if statement.

`<TMPL_LOOP name="loopname">`
:	Introduces a loop statement where *loopname* is the name of a *loop variable*, which is a list of variable lists.

`<TMPL_BREAK level=*N*>`print_latex_element_list
:	Loop break. This tag must always be inside of a loop statement. It causes the current iteration of the loop statement to stop and processing resumes immediately after the loop statement. By default `TMPL_BREAK` breaks out of the closest surrounding loop statement, whose *nesting level* is one. The optional `level=N` attribute, where *N* is a number greater than zero, can be used to specify a loop statement at a higher nesting level, i.e., a loop statement that surrounds the closest surrounding loop statement.

`<TMPL_CONTINUE level=*N*>`
:	Loop continue. This tag must always be inside of a <a href= "#loopstmt">loop statement</a>. It causes the current iteration of the loop statement to stop and processing resumes at the beginning of the next loop iteration. By default the `TMPL_CONTINUE` tag operates on the closest surrounding loop statement and the optional *level=N* attribute has the same purpose as in the `TMPL_BREAK` tag.

`</TMPL_LOOP>`
:	Terminates a loop statement.

`<TMPL_INCLUDE name="filename">`
: 	File inclusion. The tag is replaced with the contents of template file *filename* and the result is expanded. The included file must be a syntactically correct and complete template. For example, you cannot have a `TMPL_IF` tag in one file and have its corresponding `</TMPL_IF>` in another file. However, you can place `TMPL_INCLUDE` tags inside of if statements or inside of loop statements. The included file is not actually opened and processed until the flow of control reaches the `TMPL_INCLUDE` tag. An included file may include other files, which may also include files, up to a depth of thirty. Exceeding this limit is an error and probably indicates a cycle where a file includes itself either directly or indirectly.

	If *filename* begins with `.../` then `...` is replaced with the directory name of the enclosing template filename. If there is no directory name (no slash) then the `.../` is removed. For example, if the enclosing file is `dir/templates/main.tmpl` and *filename* is `.../include/incl1.tmpl`, then the result is `dir/templates/include/incl1.tmpl`.


# Tag Syntax

Template tag syntax has these features.

- For better compatibility with XML and XHTML, any tag except for `TMPL_IF`, `</TMPL_IF>`, `TMPL_LOOP` and `</TMPL_LOOP>` may be terminated by `/>`. For example, `<TMPL_VAR name="varname" />`.

- You may camouflage a template tag so that it looks like a HTML comment by surrounding it with `<!--` and `-->`, such as `<!-- TMPL_VAR name="varname" -->`. This can make template tags more palatable to tools that understand HTML.

- In an attribute such as `value="testvalue"`, the attribute value *testvalue* may be surrounded by double quotes (") or single quotes ('). If *testvalue* consists of only letters or digits or . or - , then quotes are not required, but still recommended. Any text may be enclosed within quotes except for line terminators. To place a double quote within quotes, use single quotes, and vice versa.

- Tag attributes can come in any order. For example, `<TMPL_VAR name="varname" default="value">` is the same as `<TMPL_VAR default="value" name="varname">`.

- The tag name and attribute names are case insensitive, but attribute values are case sensitive. For example, `<tmpl_if NAME=varname Value="testvalue">` is the same as `<TMPL_IF name=varname value="testvalue">`.

- *White space* is any sequence of spaces, tabs or line terminators. As with HTML tags, white space is not allowed between a beginning < and the tag name. However, white space is optional between a beginning `<!--` and the tag name. If a tag has any attributes, then white space is required between the tag name and the first attribute. Otherwise, white space is optional. For example, here is a tag with minimal white space followed by the same tag with white space inserted everywhere that it is allowed.

    `<TMPL_IF  name="varname"value="testvalue">`

    `<TMPL_IF  name   =   "varname"  value  =   "testvalue"  >`

- If you do not surround an attribute value with quotes then you may need white space to separate it from what follows. For example, the white space in this tag is necessary:

		<!--TMPL_IF   name=varname   value=testvalue  -->

- Any text that looks like a template tag (but is not a legal tag) is copied to the output as if it were ordinary text, and you get a warning message indicating that the bad tag was ignored. For example, `<TMPL_VAR color="red">` and `<TMPL_LOOP name=>` would be handled this way.

- Template tags are recognized without any regard for the surrounding text, so you can combine template tags with HTML tags in unusual ways. For example, the following looks odd but works fine:

		<a href="<TMPL_VAR name="link">">

- Although template tags look like HTML tags, your template does not have to output HTML, it can output whatever you want.


## The If Statement

The syntax of the if statement is

		<TMPL_IF name="varname" value="testvalue">

			...

		<TMPL_ELSIF name="varname" value="testvalue">

			...

		<TMPL_ELSE>

			...

		</TMPL_IF>

Where ... is any sequence (including an empty sequence) of comments, text sequences, template tags, if statements, or loop statements. One `<TMPL_IF>` tag is required and must come first. There can be zero or more `<TMPL_ELSIF>` tags and zero or one `<TMPL_ELSE>`, which must come after any `TMPL_ELSIF` tags. The final `</TMPL_IF>` is always required.  Any other use of these tags is an error.

Zero or one of the template-lists in an if statement is expanded and the rest of the if statement disappears. The `TMPL_IF` and `TMPL_ELSIF` tags are evaluated in order until a tag evaluates to true. Then the template-list immediately following the true tag is expanded. If no tags are true then the template-list after the `<TMPL_ELSE>` is expanded. Since the `<TMPL_ELSE>` is optional, possibly no template-lists are expanded and the entire if statement disappears.

The if statement syntax shown above is formatted for readability. You can format if statements any way you want, such as putting an entire if statement on one line. The same is true for loop statements.

## The Loop Statement

The syntax of the loop statement is

    <TMPL_LOOP name="loopname">

        *template-list*

    </TMPL_LOOP>

Any other use of these tags is an error. *Loopname* is
the name of a <a href="#types">*loop variable*</a>, which is
a list of variable lists. Each variable list is essentially a
  *row of data*. If *loopname* does not exist, then the
loop statement silently disappears. Otherwise the template-list
is expanded repeatedly, one time for each variable list (row) in
  *loopname*. Within the template-list you can refer to
variables in *loopname's* current variable list and refer to
variables in enclosing variable lists, such as the variable list
that contains *loopname*. A variable in an inner list
overrides a variable with the same name in an enclosing list.

Within a loop statement you can use the TMPL_BREAK tag to
break out of the loop and resume processing immediately after the
loop statement. Or you can use the TMPL_CONTINUE tag to skip the
rest of the current loop iteration and resume at the beginning of
the next iteration.

# C Template Library Data Types

In your C source you include the `ctemplate.h` header
file, which declares these data types.

`TMPL_varlist`
:	is a *variable list*, which is a list of *simple
    variables* and/or *loop variables*. A simple variable
    is a name and value, both null terminated strings.

`TMPL_loop`
:	is a *loop variable*, which is a name and a list of
    variable lists (rows of data).

`TMPL_fmtlist`
:	is a *format function list*, which is a list of
    functions that the template expander calls to output variables.
    Each list entry consists of a function pointer and a name that
    TMPL_VAR tags use to select the function.

`TMPL_fmtfunc`
:	is a format function pointer, which has this declaration:

		typedef void (*TMPL_fmtfunc)(const char *, FILE *);


## C Template Library Functions

The C Template library provides these functions.

`TMPL_write()`
:	expands and outputs a template.

`TMPL_add_var()`
:	adds simple variables to a variable list.

`TMPL_add_varlist()`
:	adds a variable list to a loop variable.

`TMPL_add_loop`
:	adds a loop variable to a variable list.

`TMPL_add_fmt`
:	adds a function to a format function list.

`TMPL_free_varlist()`
:	frees memory used by a variable list.

`TMPL_free_fmtlist()`
:	frees memory used by a format function list.

These functions are reentrant because they do not use global variables or static local variables, so you can use this library with threads.

Some functions accept null terminated string parameters of type `const char*`. These functions make copies of strings as necessary so that after the function returns you can safely do anything you want with any string that you have passed as a parameter.

`int TMPL_write(
	const char *filename,
	const char *tmplstr,
	const TMPL_fmtlist *fmtlist,
	const TMPL_varlist *varlist,
	FILE *out,
	FILE *errout
);`
:	`TMPL_write()` processes a template file and a variable list and outputs the result. Parameter *filename* is the name of the template file. If parameter *tmplstr* is non-null, then it is the template, a null terminated string. (You can still pass a name for the template in *filename*, which will appear in error messages.) Parameter *fmtlist* (which may be null) is an optional format function list that the template uses to output variables. Parameter *varlist* is a variable list and parameter *out* is an open file pointer where the result is written. Error messages are written to open file pointer *errout*, which may be null to suppress error messages. If successful, `TMPL_write()` returns zero, otherwise -1. `TMPL_write()` fails if the template file (or any included file) cannot be opened or if any template file has syntax errors.

`TMPL_varlist *TMPL_add_var (
	TMPL_varlist *varlist,
	const char *name1,
	const char *value1,
	...,
	0
);`
:	`TMPL_add_var()` adds one or more simple variables to variable list *varlist*. If *varlist* is null, then a new variable list is created and returned, otherwise *varlist* is returned. After *varlist* comes an even number of *const char ** parameters, which are null terminated strings. Each pair of strings is a variable name and value to be added to *varlist*. <b>The parameter list must be terminated by a null pointer.</b> If the parameter list does not contain at least one name and value, then `TMPL_add_var()` returns *varlist* without doing anything.  If you add a new variable to a list that already has a variable with the same name, then the new variable overrides the old variable. You may add variables to *varlist* even if *varlist* was previously added to a loop variable with `TMPL_add_varlist()`.

`TMPL_loop *TMPL_add_varlist (
	TMPL_loop *loop,
    TMPL_varlist *varlist
);`
`TMPL_add_varlist()` adds variable list *varlist* to loop variable *loop*. If *loop* is null, then a new loop variable is created and returned, otherwise *loop* is returned. If *varlist* is null, or if *varlist* has already been added to a loop variable, or if *varlist* contains *loop* (which would create a cycle), then `TMPL_add_varlist()` returns *loop* without doing anything. You may add *varlist* to *loop* even if *loop* was previously added to a variable list with `TMPL_add_loop()`. A loop statement processes the variable lists (rows) in *loop* in the same order that they were added.

`TMPL_varlist *TMPL_add_loop(
	TMPL_varlist *varlist,
	const char *name,
	TMPL_loop *loop
);
: `TMPL_add_loop()` adds loop variable *loop* to variable list *varlist*, setting the name of *loop* to *name*. If *varlist* is null, then a new variable list is created and returned, otherwise *varlist* is returned. If *name* is null, or if *loop* is null, or if *loop* has already been added to a variable list, or if *loop* contains *varlist* (which would create a cycle), then `TMPL_add_loop()` returns *varlist* without doing anything. You may add *loop* to *varlist* even if *varlist* was previously added to a loop variable with `TMPL_add_varlist()`.

`TMPL_fmtlist *TMPL_add_fmt(
	TMPL_fmtlist *fmtlist,
	const char *name,
	TMPL_fmtfunc fmtfunc
);`
: `TMPL_add_fmt()` adds the string *name* and the function pointer *fmtfunc* to format function list *fmtlist*. If *fmtlist* is null, then a new format function list is created and returned, otherwise *fmtlist* is returned. Parameter *name* is the name that `TMPL_VAR` tags use to select the function. If *name* is null or if *fmtfunc* is null, then nothing happens and *fmtlist* is returned.

	If you write your own format function, then it must have a prototype like this:

		void yourfunc(const char *value, FILE *out);

	and it should output *value* to open file pointer *out*, with appropriate formatting or encoding.

`void TMPL_free_varlist(
	TMPL_varlist *varlist
);`
: `TMPL_free_varlist()` frees all memory used by variable list *varlist*. Because variable lists can contain loop variables, which in turn consist of variable lists, a variable list can be a rather elaborate tree. To free the entire tree, call TMPL_free_varlist() once, passing the variable list at the root of the tree.

`void TMPL_free_fmtlist(
	TMPL_fmtlist *fmtlist
);`
: `TMPL_free_fmtlist()` frees all memory used by format function list *fmtlist*.


# Using the C Template Library

In your C source, include `stdio.h` and `ctemplate.h` and link your program with `libctemplate.a`.

		#include <stdio.h>
		#include <ctemplate.h>

		int main(int argc, char **argv) {
			TMPL_varlist *mylist;   /* declare the variable list */

			/* load the variable list with TMPL_add_var()  */

			mylist = TMPL_add_var(0, "var1", "value1", "var2", "value2", 0);
			mylist = TMPL_add_var(mylist, "var3", "value3", 0);
			TMPL_add_var(mylist, "var4", "value4", 0);

			/* output the template */

			TMPL_write("tmplfile", 0, 0, mylist, stdout, stderr);

			/* TMPL_write() frees any memory that it allocates. */

			TMPL_free_varlist(mylist);   /* free the variable list */
			return 0;
		}

Constructing a loop variable for a loop statement is a bit trickier. Construct variable lists with `TMPL_add_var()` and add each one to the loop variable with `TMPL_add_varlist()`. Add the loop variable to the main variable list with `TMPL_add_loop()`.

		#include <stdio.h>
		#include <ctemplate.h>

		int main(int argc, char **argv) {
			TMPL_varlist *vl, *mainlist;
			TMPL_loop    *loop;

			/* build the loop variable */

			loop = 0;
			vl = TMPL_add_var(0, "row", "one", "user", "Bill", 0);
			loop = TMPL_add_varlist(loop, vl);
			vl = TMPL_add_var(0, "row", "two", "user", "Susan", 0);
			loop = TMPL_add_varlist(loop, vl);
			TMPL_add_varlist(loop, TMPL_add_var(0, "row", "three", "user", "Jane", 0));

			/* add the loop variable to the main variable list */

			mainlist = TMPL_add_loop(0, "myloop", loop);

			/* output the template and free variable list memory */

			TMPL_write("tmplfile", 0, 0, mainlist, stdout, stderr);

			TMPL_free_varlist(mainlist);
			return 0;
		}

Here is an example template for expanding the loop.

		Before loop.
		<TMPL_LOOP name = "myloop">
			This is row <TMPL_VAR name = "row">
			and the user is <TMPL_VAR name = "user">
		</TMPL_LOOP>
		After loop.

Here is the output.

		Before loop.

			This is row one
			and the user is Bill

			This is row two
			and the user is Susan

			This is row three
			and the user is Jane

		After loop.

Those blank lines appear because all the line terminators in the template file are outside of template tags and are therefore
copied to the output. You can suppress outputting a line terminator by preceding it with a <a href="#text">backslash</a> (\\) or enclosing it in a comment.

Nested loops are supported with no limit to the depth of nesting. You can build a loop variable, add it to a variable list and then add the variable list to an enclosing loop variable,
etc.

Cycles are not permitted, however. You cannot add a loop variable to a variable list that is contained by the loop variable and you cannot add a variable list to a loop variable that is contained by the variable list. A loop variable can be added to a variable list one time only and a variable list can be added to a loop variable one time only. The template library enforces these rules by silently declining to perform any illegal operation.

# Using Format Functions

To better separate *information* from *presentation*, you may want to store unformatted strings in a variable list and let the template expander format the strings when outputting them. That way the same variable list can be output in a variety of formats by passing it to different templates. For example, your variable list may have a variable named *greeting* with value `<<HELLO>>` that you want to insert into a HTML document. You could convert this string to *&amp;lt;&amp;lt;HELLO&amp;gt;&amp;gt;* before storing it in the variable list, but that encoding is specific to HTML, making the variable list unsuitable for a template that outputs something other than HTML.

To solve this problem use a `TMPL_VAR` tag such as `<TMPL_VAR name="greeting" fmt="entity">`, where `fmt="entity"` specifies a format function that does the necessary conversion.  The expander calls this function to output the value of `greeting`.

You are welcome to write your own format functions and for your convenience the C Template library includes these functions that are helpful when outputting HTML.

`void TMPL_encode_entity(const char *value, FILE *out);`
: `TMPL_encode_entity()` outputs *value* with the following conversions:
	- & becomes &amp;
	- < becomes &lt;
	- > becomes &gt;
	- " becomes &quot;
	- ' becomes &#39;
	- *newline* becomes &#10;
	- *return* becomes &#13;

For security it is always a good idea to sanitize any user input before outputting it, and `TMPL_encode_entity()` is very useful for this.

`void TMPL_encode_url(const char *value, FILE *out);`
: `TMPL_encode_url()` outputs *value* converting space to + and any other character that is not a letter or digit or . or - or _ to *%xx* where *xx* is the character's numeric code expressed as two hexadecimal digits.

To allow the attribute `fmt="entity"` to be used in TMPL_VAR tags, you must add the name `entity` and the function pointer `TMPL_encode_entity` to a format function list with `TMPL_add_fmt()` and pass the format function list to TMPL_write().

		TMPL_varlist *varlist;
		TMPL_fmtlist *fmtlist;

		fmtlist = TMPL_add_fmt(0, "entity", TMPL_encode_entity);
		varlist = TMPL_add_var(0, "greeting", "<<HELLO>>", 0);
		TMPL_write("tmplfile", 0, fmtlist, varlist, stdout, stderr);
		TMPL_free_varlist(varlist);
		TMPL_free_fmtlist(fmtlist);


# The `template` Command

The C Template library comes with a program named `template`, which takes a template file name and variable list on the command line and outputs the result on stdout. This command is handy for checking a template file for syntax errors and for testing a template with a variety of input data.

The `template` command uses the format functions `TMPL_encode_entity()` and `TMPL_encode_url()`, which you can select in `TMPL_VAR` tags with `fmt="entity"` and `fmt="url"`, respectively.

Usage:
		template filename [varname1 value1 [varname2 value2 [ ... ] ] ]

where `filename` is a template file and the rest of the arguments are variable names and values, each of which must be a separate argument.

		template weather.tmpl title "Current Weather" temp 62 \
			dewpoint 45 windspeed 8 windgust 15 winddir WNW \
			condition "mostly sunny"

You can also define a loop variable with its name followed by one or more variable lists, each enclosed by { and }.

		template tmplfile myloop { row one user Bill } \
			{ row two user Susan } { row three user Jane }

Each { and } must be a separate argument. A loop variable can appear anywhere that a simple name/value pair may appear, so they can be nested, which is necessary if the template has nested loops. For example,

		template tmplfile title "Nested Loops" \
		outerloop \
			{ var1 first  innerloop { var2 third } { var2 fourth } } \
			{ var1 second innerloop { var2 fifth } { var2 sixth  } }

The template file might look like this.

		<h1><TMPL_VAR name = "title"></h1>
		<TMPL_LOOP name = "outerloop">
			Begin outer loop
			<TMPL_LOOP name = "innerloop">
				Begin inner loop
				The value of var1 is <TMPL_VAR name = "var1">
				The value of var2 is <TMPL_VAR name = "var2">
				End inner loop
			</TMPL_LOOP>
			End outer loop
		</TMPL_LOOP>
		End template

And here is the output.

		<h1>Nested Loops</h1>

			Begin outer loop

				Begin inner loop
				The value of var1 is first
				The value of var2 is third
				End inner loop

				Begin inner loop
				The value of var1 is first
				The value of var2 is fourth
				End inner loop

			End outer loop

			Begin outer loop

				Begin inner loop
				The value of var1 is second
				The value of var2 is fifth
				End inner loop

				Begin inner loop
				The value of var1 is second
				The value of var2 is sixth
				End inner loop

			End outer loop

		End template

See the examples directory and the `t/test.sh` script for more examples.

# Design Philosophy

The template language was designed to provide as much functionality as possible while keeping the syntax as simple as possible. In particular, `TMPL_IF` supports only rudimentary tests of variable values. While it would be nice if `TMPL_IF` supported more general expressions, this would greatly complicate the syntax.

The deficiencies of `TMPL_IF` can be mitigated by coding complicated logic in the C program and saving the result in a template variable. Then the template can use the rudimentary `TMPL_IF` syntax to test this variable. For example, suppose we have a template that outputs total disk space, used disk space and available space and we want this information to appear in red when over 90% of the space is used. The template language provides no direct way to accomplish this, but we can easily do the necessary calculation in C and set another template variable named *almost_full* when the information should appear in red.

		<p>
		<TMPL_IF name="almost_full"><font color="red"></TMPL_IF>
		Total: <TMPL_VAR name="total">
		Used:  <TMPL_VAR name="used">
		Available: <TMPL_VAR name="avail">
		<TMPL_IF name="almost_full"></font></TMPL_IF>
		</p>

Similarly, `TMPL_LOOP` has no support for complicated logic and does little more than iterate through a list of variable lists. However, most of the functionality that `TMPL_LOOP` lacks can be easily provided by the C program and passed to the template in variables. Suppose we are displaying a very long HTML table and we would like to output a row of column headers every 25 rows so that the reader does not need to scroll all the way back to the top of the table to see them. The `TMPL_LOOP` statement has no built in support for this, but in our C program we can easily keep count of the rows and insert an extra template variable named `need_headers` on every 25th row.

		<TMPL_LOOP name="table_rows">
		<TMPL_IF name="need_headers">
			<tr>
			<th>Col Header1</th>
			<th>Col Header2</th>
			<th>Col Header3</th>
			</tr>
		</TMPL_IF>
		<tr>
		<td><TMPL_VAR name="colvar1"></td>
		<td><TMPL_VAR name="colvar2"></td>
		<td><TMPL_VAR name="colvar3"></td>
		</tr>
		</TMPL_LOOP>

You can also use (abuse?) format functions to provide more complicated logic, since a format function can potentially do just about anything.
