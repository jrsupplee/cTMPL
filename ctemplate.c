/*
 * C Template: template expander library based on the perl
 * HTML::Template package.
 *
 * Version: 1.0
 *
 * Author: Stephen C. Losen, University of Virginia
 *
 * Copyright 2009 Stephen C. Losen.  Distributed under the terms
 * of the GNU General Public License (GPL)
 *
 * A template consists of text sequences, comments and template tags.
 * Anything that is not a tag and not a comment is considered text.
 * The tags include:
 *
 * <TMPL_Tag_Var name = "varname" default = "value" fmt = "fmtname">
 * <TMPL_Tag_Include name = "filename">
 * <TMPL_Tag_Loop name = "loopname">
 * <TMPL_Tag_Break level = N>
 * <TMPL_Tag_Continue level = N>
 * </TMPL_Tag_Loop>
 * <TMPL_Tag_If name = "varname" value = "testvalue">
 * <TMPL_Tag_ElseIf name = "varname" value = "testvalue">
 * <TMPL_Tag_Else>
 * </TMPL_Tag_If>
 *
 * The "name =" attribute is required, and the "value =", "fmt =",
 * "default =", and "level ="  attributes are optional.
 *
 * A comment is any text enclosed by <* and *>
 *
 * We read the entire template into memory, scan it, parse it, and
 * build a parse tree.  To generate the output, we walk the parse
 * tree and output the tree nodes.  A list of variables and values
 * determines what tree nodes we visit and what we output.
 *
 * The scanner splits the template into text sequences and tags.
 * Each call of scan() returns a tagnode struct representing the
 * next text sequence or tag.  The parser uses recursive descent
 * to link the tagnodes into a parse tree.
 */

#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/stat.h>
#include <stdarg.h>
#include <ctemplate.h>

/* To prevent infinite TMPL_Tag_Include cycles, we limit the depth */

#define MAX_INCLUDE_DEPTH 30


/* template tag kinds (used in bitmaps) */

static char* TMPL_Tag_Names[] = {
	[TMPL_Tag_DelimStart] = "{{",
	[TMPL_Tag_DelimEnd] = "}}",
	[TMPL_Tag_CommentStart] = "{{!--",
	[TMPL_Tag_CommentEnd] = "--}}",
	[TMPL_Tag_Comment2Start] = "{{*",
	[TMPL_Tag_Comment2End] = "*}}",
	[TMPL_Tag_Var] = "VAR",
	[TMPL_Tag_Include] = "INCLUDE",
	[TMPL_Tag_If] = "IF",
	[TMPL_Tag_ElseIf] = "ELSIF",
	[TMPL_Tag_Else] = "ELSE",
	[TMPL_Tag_EndIf] = "ENDIF",
	[TMPL_Tag_Loop] = "LOOP",
	[TMPL_Tag_EndLoop] = "ENDLOOP",
	[TMPL_Tag_Break] = "BREAK",
	[TMPL_Tag_Continue] = "CONTINUE",
	[TMPL_Tag_Text] = "TEXT",
	[TMPL_Tag_Unknown] = "unknown"
};

typedef enum {
	TMPL_Oper_Equal = 1,
	TMPL_Oper_NotEqual = 2,
	TMPL_Oper_LessThan = 3,
	TMPL_Oper_GreaterThan = 4,
	TMPL_Oper_GreaterThanOrEqual = 5,
	TMPL_Oper_LessThanOrEqual =6,
	TMPL_Oper_IsNull = 7
} TMPL_Operators;

static char* TMPL_Operator_Names[] = {
	[TMPL_Oper_Equal] = "==",
	[TMPL_Oper_NotEqual] = "!=",
	[TMPL_Oper_LessThan] = "<",
	[TMPL_Oper_GreaterThan] = ">",
	[TMPL_Oper_GreaterThanOrEqual] = ">=",
	[TMPL_Oper_LessThanOrEqual] = "<=",
	[TMPL_Oper_IsNull] = "ISNULL"
};


typedef struct tagnode tagnode;
typedef struct template template;

/* The parse tree consists of tagnodes */

struct tagnode {
    TMPL_Tags kind;
    tagnode *next;
    union {

        /* text sequence */

        struct {
            const char *start;
            int len;
        }
        text;

        /* TMPL_Tag_Var tag */

        struct {
            const char *varname, *dfltval;
            TMPL_fmtfunc fmtfunc;
        }
        var;

        /* TMPL_Tag_If tag or TMPL_Tag_ElseIf tag */

        struct {
            const char *varname, *operator, *testval;
            tagnode *tbranch, *fbranch;
        }
        ifelse;

        /* TMPL_Tag_Loop tag */

        struct {
            const char *loopname;
            tagnode *body;
        }
        loop;

        /* TMPL_Tag_Break tag or TMPL_Tag_Continue tag */

        struct {
            int level;
        }
        breakcont;

        /* TMPL_Tag_Include tag */

        struct {
            const char *filename;
            template *tmpl;
        }
        include;
    }
    tag;
};

/* template information */

struct template {
    const char *filename;  /* name of template file */
    const char *tmplstr;   /* contents of template file */
    FILE *out;             /* template output file pointer */
    FILE *errout;          /* error output file pointer */
    tagnode *roottag;      /* root of parse tree */
    const TMPL_fmtlist
        *fmtlist;          /* list of format functions */

    /* scanner and parser state variables */

    const char *scanptr;  /* next character to be scanned */
    tagnode *nexttag;     /* next tag to be returned by scanner */
    tagnode *curtag;      /* current tagnode being parsed */
    int linenum;          /* current template line number */
    int tagline;          /* line number of current tag's name */
    int error;            /* error indicator */
    int include_depth;    /* avoids TMPL_Tag_Include cycles */
    int loop_depth;       /* current loop nesting depth */
    int break_level;      /* for processing a TMPL_Tag_Break tag */
    int cont_level;       /* for processing a TMPL_Tag_Continue tag */
    tagnode reusable;     /* reusable storage for simple tags */
};

/*
 * TMPL_fmtlist is a list of format functions, which are passed to
 * a template.  A TMPL_Tag_Var tag can specify a format function for
 * outputting the variable with the fmt="fmtname" attribute.
 */

struct TMPL_fmtlist {
    TMPL_fmtlist *next;   /* next list member */
    TMPL_fmtfunc fmtfunc; /* pointer to format function */
    char name[1];         /* name of format function */
};

/*
 * variables are passed to a template in a tree consisting of
 * TMPL_var, TMPL_varlist and TMPL_loop nodes.
 *
 * TMPL_var is a simple variable (name and value)
 */

typedef struct TMPL_var TMPL_var;

struct TMPL_var {
    TMPL_var *next;     /* next simple variable on list */
    const char *name;
    char value[1];      /* value and name stored here */
};

/*
 * TMPL_varlist is a variable list of simple variables and/or
 * loop variables
 */

struct TMPL_varlist {
    TMPL_varlist *next;  /* next variable list on a list */
    TMPL_var   *var;     /* list of my simple variables */
    TMPL_loop  *loop;    /* list of my loop variables */
    TMPL_loop  *parent;  /* my parent loop variable (if any) */
};

/* TMPL_loop is a loop variable, which is a list of variable lists */

struct TMPL_loop {
    TMPL_loop *next;       /* next loop variable on a list */
    const char *name;      /* my name */
    TMPL_varlist *varlist; /* list of my variable lists */
    TMPL_varlist *tail;    /* tail of "varlist" */
    TMPL_varlist *parent;  /* my parent variable list */
};

/* mymalloc() is a malloc wrapper that exits on failure */

static void *
mymalloc(size_t size) {
    void *ret = malloc(size);
    if (ret == 0) {
        fputs("C Template library: out of memory\n", stderr);
        exit(1);
    }
    return ret;
}


void TMPL_tagname_set( TMPL_Tags tag, const char* label ) {
	// this code creates a memory leak.
	TMPL_Tag_Names[tag] = mymalloc( strlen(label+1) );
	strcpy(TMPL_Tag_Names[tag], label);
}


const char* TMPL_tagname_get( TMPL_Tags tag ) {
	return TMPL_Tag_Names[tag];
}


/*
 * newtemplate() creates a new template struct and reads the template
 * file "filename" into memory.  If "tmplstr" is non-null then it is
 * the template, so we do not read "filename".
 */

static template *
newtemplate(const char *filename, const char *tmplstr,
    const TMPL_fmtlist *fmtlist, FILE *out, FILE *errout)
{
    template *t;
    FILE *fp;
    char *buf = 0;
    struct stat stb;

    if (tmplstr == 0 && filename == 0) {
        if (errout != 0) {
            fputs("C Template library: no template specified\n", errout);
        }
        return 0;
    }
    if (tmplstr == 0) {
        if ((fp = fopen(filename, "r")) != 0 &&
            fstat(fileno(fp), &stb) == 0 &&
            S_ISREG(stb.st_mode) != 0 &&
            (buf = (char *) mymalloc(stb.st_size + 1)) != 0 &&
            (stb.st_size == 0 ||
            fread(buf, 1, stb.st_size, fp) == stb.st_size))
        {
            fclose(fp);
            buf[stb.st_size] = 0;
        }
        else {
            if (errout != 0) {
                fprintf(errout, "C Template library: failed to read "
                    "template from file \"%s\"\n", filename);
            }
            if (buf != 0) {
                free(buf);
            }
            if (fp != 0) {
                fclose(fp);
            }
            return 0;
        }
    }
    t = (template *) mymalloc(sizeof(*t));
    t->filename = filename != 0 ? filename : "(none)";
    t->tmplstr = tmplstr != 0 ? tmplstr : buf;
    t->fmtlist = fmtlist;
    t->scanptr = t->tmplstr;
    t->roottag = t->curtag = t->nexttag = 0;
    t->out = out;
    t->errout = errout;
    t->linenum = 1;
    t->error = 0;
    t->include_depth = 0;
    t->loop_depth = 0;
    t->break_level = t->cont_level = 0;
    return t;
}

/* newtag() allocates a new tagnode */

static tagnode *
newtag(template *t, TMPL_Tags kind) {
    tagnode *ret;

    switch(kind) {

    /*
     * The following tags are simple parse tokens that are
     * never linked into the parse tree so they share storage.
     */

    case TMPL_Tag_Else:
    case TMPL_Tag_EndIf:
    case TMPL_Tag_EndLoop:
        ret = &t->reusable;
        break;

    default:
        ret = (tagnode *) mymalloc(sizeof(*ret));
        break;
    }
    ret->kind = kind;
    ret->next = 0;
    return ret;
}

/*
 * freetag() recursively frees parse tree tagnodes.  We do not free
 * the text in a TMPL_Tag_Text tagnode because it points to memory where
 * the input template is stored, which we free elsewhere.
 */

static void
freetag(tagnode *tag) {
    template *t;

    if (tag == 0) {
        return;
    }
    switch(tag->kind) {

    case TMPL_Tag_Var:
        free((void *) tag->tag.var.varname);
        if (tag->tag.var.dfltval != 0) {
            free((void *) tag->tag.var.dfltval);
        }
        break;

    case TMPL_Tag_If:
    case TMPL_Tag_ElseIf:
        free((void *) tag->tag.ifelse.varname);
        if (tag->tag.ifelse.testval != 0) {
            free((void *) tag->tag.ifelse.testval);
        }
        freetag(tag->tag.ifelse.tbranch);
        freetag(tag->tag.ifelse.fbranch);
        break;

    case TMPL_Tag_Loop:
        free((void *) tag->tag.loop.loopname);
        freetag(tag->tag.loop.body);
        break;

    case TMPL_Tag_Include:
        free((void *) tag->tag.include.filename);
        if ((t = tag->tag.include.tmpl) != 0) {
            free((void *) t->filename);
            free((void *) t->tmplstr);
            freetag(t->roottag);
            free(t);
        }
        break;
    }
    freetag(tag->next);
    free(tag);
}

/* map TMPL_Tags to a human readable string */

static const char *
tagname(TMPL_Tags kind) {
	return TMPL_Tag_Names[kind];
}


/*
 * SCANNER FUNCTIONS
 *
 * scanspaces() scans white space
 */


int is_name_char( const char ch ) {
	return (isalnum(ch) || (ch == '_'));
}


int tag_length( TMPL_Tags tag ) {
	return strlen(tagname(tag));
}


int is_tag( TMPL_Tags tag, const char *p ) {
	return (strncasecmp(p, tagname(tag), tag_length(tag)) == 0);
}


int is_delim_start( const char *p ) {
	return is_tag( TMPL_Tag_DelimStart, p );
}


int is_delim_end( const char *p ) {
	return is_tag( TMPL_Tag_DelimEnd, p );
}


static const char *
scanspaces(template *t, const char *p) {
    while (isspace(p[0])) {
        if (*p++ == '\n') {
            t->linenum++;
        }
    }
    return p;
}


/*
 * scancomment() scans a comment delimited by <* and *>. If we find a
 * comment then we advance t->scanptr to the first character after the
 * comment and return 1.  Otherwise we return 0.
 */

static int
scancomment(template *t, const char *p) {
    int linenum = t->linenum;

    if (!is_tag(TMPL_Tag_Comment2Start,p))
    {
        return 0;
    }

    p += tag_length(TMPL_Tag_Comment2Start);
    
    for (p; *p != 0; p++) {
        if (*p == '\n') {
            t->linenum++;
        }
		if (is_tag(TMPL_Tag_Comment2End, p)) {
            t->scanptr = p + tag_length(TMPL_Tag_Comment2End);
            return 1;
        }
    }

    /* end of template, comment not terminated */

    if (t->errout != 0) {
        fprintf(t->errout, "\"%s\" in file \"%s\" line %d "
            "has no \"%s\"\n", tagname(TMPL_Tag_Comment2Start), t->filename, linenum, tagname(TMPL_Tag_Comment2End));
    }
    t->error = 1;
    return 0;
}


/*
 * scanattr() scans an attribute such as:  name="value".  If
 * successful we advance t->scanptr to the character after the
 * attribute and return a copy of the attribute value.  Otherwise
 * we return null.  We accept double or single quotes around "value".
 * We accept no quotes if "value" contains only letters, digits,
 * '.' or '-'.
 */

static char *
scanattr(template *t, const char *attrname, const char *p) {
    int len = strlen(attrname);
    int i;
    int quote = 0;
    char *ret;

    if (strncasecmp(p, attrname, len) != 0) {
        return 0;
    }
    p = scanspaces(t, p + len);
    if (*p++ != '=') {
        return 0;
    }
    p = scanspaces(t, p);
    if (*p == '"' || *p == '\'') {
        quote = *p++;
    }

    /* p now points to the start of the attribute value */

    if (quote != 0) {
        for (i = 0; p[i] != quote && p[i] != '\n' && p[i] != 0; i++)
            ;
        if (p[i] != quote) {
            return 0;
        }
        t->scanptr = p + i + 1;
    }
    else {
        for (i = 0; isalnum(p[i]) || p[i] == '.' || p[i] == '-'; i++)
            ;
        if (i == 0) {
            return 0;
        }
        t->scanptr = p + i;
    }

    /* i is now the length of the attribute value */

    ret = (char *) mymalloc(i + 1);
    memcpy(ret, p, i);
    ret[i] = 0;
    return ret;
}



static char *
scanname(template *t, const char *p) {
    char *ret;

    p = scanspaces(t, p);
    
    int i=0;
	while(is_name_char(p[i])) {    
        i++;
    }
    
    if (i < 1) {
    	return 0;
    }
    	
    t->scanptr = p + i;

    ret = (char *) mymalloc(i + 1);
    memcpy(ret, p, i);
    ret[i] = 0;
    return ret;
}


static char *
scanoperator(template *t, const char *p) {
    char *ret;

    p = scanspaces(t, p);
    
    int i=0;
	while(p[i] == '!' || p[i] == '=' || p[i] == '<' || p[i] == '>') {    
        i++;
    }
    
    if (i < 1) {
    	return 0;
    }
    	
    t->scanptr = p + i;

    ret = (char *) mymalloc(i + 1);
    memcpy(ret, p, i);
    ret[i] = 0;
    return ret;
}


static char *
scanvalue(template *t, const char *p) {
	int i = 0;
    int quote = 0;
    char *ret;

    p = scanspaces(t, p);
    if (*p == '"' || *p == '\'') {
        quote = *p++;
    }

    /* p now points to the start of the value */

    if (quote != 0) {
        for (i = 0; p[i] != quote && p[i] != '\n' && p[i] != 0; i++)
            ;
        if (p[i] != quote) {
            return 0;
        }
        t->scanptr = p + i + 1;
    }
    else {
        for (i = 0; isalnum(p[i]) || p[i] == '.'; i++)
            ;
        if (i == 0) {
            return 0;
        }
        t->scanptr = p + i;
    }

    /* i is now the length of the value */

    ret = (char *) mymalloc(i + 1);
    memcpy(ret, p, i);
    ret[i] = 0;
    return ret;
}


/*
 * findfmt() looks up a format function by name.  If successful
 * we return a pointer to the function, otherwise we return null.
 */

static TMPL_fmtfunc
findfmt(const TMPL_fmtlist *fmtlist, const char *name) {
    for (; fmtlist != 0; fmtlist = fmtlist->next) {
        if (strcmp(fmtlist->name, name) == 0) {
            return fmtlist->fmtfunc;
        }
    }
    return 0;
}

/*
 * scantag() scans a template tag.  If successful we return a tagnode
 * for the tag and advance t->scanptr to the first character after the
 * tag.  Otherwise we clean up and return null.
 */

static tagnode *
scantag(template *t, const char *p) {
    TMPL_Tags kind;
    int commentish = 0; /* true if tag enclosed by <!-- and --> */
    int hasname = 0;    /* true if tag has name= attribute */
    int container = 0;  /* true if tag may not end with /> */
    tagnode *tag;
    int linenum = t->linenum;
    int len, level;
    char *name = 0, *value = 0, *fmt = 0, *operator = 0;
    TMPL_fmtfunc func;
    char *err = "";

    if (is_tag(TMPL_Tag_CommentStart, p)) {
    	len = tag_length(TMPL_Tag_CommentStart);
        commentish = 1;
        p = scanspaces(t, p + len);
    }
	else if (strncmp(p, tagname(TMPL_Tag_DelimStart), len = strlen(tagname(TMPL_Tag_DelimStart))) == 0) {
		p += len;
	}
	else {
        return 0;
    }

    t->tagline = t->linenum;   /* tag name is on this line */

    if (strncasecmp(p, tagname(TMPL_Tag_Var), len = strlen(tagname(TMPL_Tag_Var))) == 0) {
        kind = TMPL_Tag_Var;
        hasname = 1;
    }
    else if (strncmp(p, "=", len = 1) == 0) {
        kind = TMPL_Tag_Var;
        //hasname = 1;
    }
    else if (strncasecmp(p, tagname(TMPL_Tag_Include), len = strlen(tagname(TMPL_Tag_Include))) == 0) {
        kind = TMPL_Tag_Include;
        hasname = 1;
    }
    else if (strncasecmp(p, tagname(TMPL_Tag_If), len = strlen(tagname(TMPL_Tag_If))) == 0) {
        kind = TMPL_Tag_If;
        hasname = 1;
        container = 1;
    }
    else if (strncasecmp(p, tagname(TMPL_Tag_ElseIf), len = strlen(tagname(TMPL_Tag_ElseIf))) == 0) {
        kind = TMPL_Tag_ElseIf;
        hasname = 1;
    }
    else if (strncasecmp(p, tagname(TMPL_Tag_Else), len = strlen(tagname(TMPL_Tag_Else))) == 0) {
        kind = TMPL_Tag_Else;
    }
    else if (strncasecmp(p, tagname(TMPL_Tag_EndIf), len = strlen(tagname(TMPL_Tag_EndIf))) == 0) {
        kind = TMPL_Tag_EndIf;
        container = 1;
    }
    else if (strncasecmp(p, tagname(TMPL_Tag_Loop), len = strlen(tagname(TMPL_Tag_Loop))) == 0) {
        kind = TMPL_Tag_Loop;
        hasname = 1;
        container = 1;
    }
    else if (strncasecmp(p, tagname(TMPL_Tag_EndLoop), len = strlen(tagname(TMPL_Tag_EndLoop))) == 0) {
        kind = TMPL_Tag_EndLoop;
        container = 1;
    }
    else if (strncasecmp(p, tagname(TMPL_Tag_Break), len = strlen(tagname(TMPL_Tag_Break))) == 0) {
        kind = TMPL_Tag_Break;
    }
    else if (strncasecmp(p, tagname(TMPL_Tag_Continue), len = strlen(tagname(TMPL_Tag_Continue))) == 0) {
        kind = TMPL_Tag_Continue;
    }
    else {
        kind = 0;
        goto failure;
    }
    t->scanptr = p + len;

    /* white space required between tag name and attributes */

    p = scanspaces(t, t->scanptr);
    if (hasname != 0 && p == t->scanptr) {
		fprintf(t->errout, "No spaces :-<\n");
        goto failure;
    }

    /*
     * These tags require one "name =" attribute. The TMPL_Tag_Var tag
     * may have optional "fmt =" and "default =" attributes.  The
     * TMPL_Tag_If and TMPL_Tag_ElseIf tags may have an optional "value ="
     * attribute. Attributes can come in any order.
     */

    switch(kind) {

    case TMPL_Tag_Include:
    case TMPL_Tag_Loop:
    	if ((name = scanattr(t, "name", p)) != 0 || (name = scanvalue(t, p)) != 0) {
			p = scanspaces(t, t->scanptr);
		}
        break;

    case TMPL_Tag_Var:
		if ((name = scanattr(t, "name", p)) != 0 || (name = scanname(t, p)) != 0)
		{
			p = scanspaces(t, t->scanptr);
		}
		
		while ((name  == 0 && (name  = scanattr(t, "name",    p)) != 0) ||
			   (fmt   == 0 && (fmt   = scanattr(t, "format",  p)) != 0) ||
			   (fmt   == 0 && (fmt   = scanattr(t, "fmt",     p)) != 0) ||
			   (value == 0 && (value = scanattr(t, "default", p)) != 0))
		{
			p = scanspaces(t, t->scanptr);
		}
        break;

    case TMPL_Tag_If:
    case TMPL_Tag_ElseIf:
    	if ((name = scanname(t, p)) == 0) {
			err = "(missing variable name) ";
			goto failure;
		}
		p = scanspaces(t, t->scanptr);
		
		if (operator = scanoperator(t, p)) {
			if (
					!strcmp(operator, "==") &&
					!strcmp(operator, "!=") &&
					!strcmp(operator, "<") &&
					!strcmp(operator, ">") &&
					!strcmp(operator, "<=") &&
					!strcmp(operator, ">=")
				)
			{
				if (strlen(operator) > 10 || strlen(operator) == 0) {
					err = "(unknown operator) ";
				} else {
					err = mymalloc( 30 );
					sprintf(err, "(unkown operator %s)", operator);
				}
				goto failure;
			}

			p = scanspaces(t, t->scanptr);
			
			if ((value = scanvalue(t,p)) == 0) {
				err = "(operator without value) ";
				goto failure;
			}
		}
		
        p = scanspaces(t, t->scanptr);
        
        /*
     	while ((name  == 0 && (name  = scanattr(t, "name",    p)) != 0) ||
			   (value == 0 && (value = scanattr(t, "value",   p)) != 0))
		{
			p = scanspaces(t, t->scanptr);
		}
		*/
		
        break;

    /*
     * These tags may have an optional "level =" attribute, which
     * must be preceded by white space.
     */

    case TMPL_Tag_Break:
    case TMPL_Tag_Continue:
        if (p != t->scanptr &&
            (value = scanattr(t, "level", p)) != 0)
        {
            p = scanspaces(t, t->scanptr);
        }
        break;
    }

    /* check for end of tag */

    p = scanspaces(t, p);
    if (commentish == 0 && is_tag(TMPL_Tag_DelimEnd, p)) {
    	len = tag_length(TMPL_Tag_DelimEnd);
    }
    else if (commentish == 0 && container == 0 && p[0] == '/' && is_tag(TMPL_Tag_DelimEnd, p+1)) {
		len = tag_length(TMPL_Tag_DelimEnd) + 1;
    }
    else if (commentish != 0 && is_tag( TMPL_Tag_CommentEnd, p)) {
    	len = tag_length(TMPL_Tag_CommentEnd);
    }
    else {
		fprintf(t->errout, "No DELIM_RIGHT found. line %d\n", t->tagline);
        goto failure;
    }

    t->scanptr = p + len;

    /* check attributes and build tag node */

    if (hasname != 0 && name == 0) {
        err = "(missing \"name=\" attribute) ";
        goto failure;
    }

    switch(kind) {

    case TMPL_Tag_Var:
        func = 0;
        if (fmt != 0) {
            if ((func = findfmt(t->fmtlist, fmt)) == 0) {
                err = "(bad \"fmt=\" attribute) ";
                goto failure;
            }
            free(fmt);
        }
        tag = newtag(t, kind);
        tag->tag.var.varname = name;
        tag->tag.var.dfltval = value;
        tag->tag.var.fmtfunc = func;
        break;

    case TMPL_Tag_Include:
        if (t->include_depth >= MAX_INCLUDE_DEPTH) {
            err = "(check for include cycle) ";
            goto failure;
        }
        tag = newtag(t, kind);
        tag->tag.include.filename = name;
        tag->tag.include.tmpl = 0;
        break;

    case TMPL_Tag_Loop:
        tag = newtag(t, kind);
        tag->tag.loop.loopname = name;
        tag->tag.loop.body = 0;
        break;

    case TMPL_Tag_Break:
    case TMPL_Tag_Continue:
        if (t->loop_depth < 1) {
            err = "(not inside a loop) ";
            goto failure;
        }
        level = 1;
        if (value != 0) {
            if ((level = atoi(value)) < 1 || level > t->loop_depth) {
                err = "(bad \"level=\" attribute) ";
                goto failure;
            }
            free(value);
        }
        tag = newtag(t, kind);
        tag->tag.breakcont.level = level;
        break;

    case TMPL_Tag_If:
    case TMPL_Tag_ElseIf:
        tag = newtag(t, kind);
        tag->tag.ifelse.varname = name;
        tag->tag.ifelse.operator = operator;
        tag->tag.ifelse.testval = value;
        tag->tag.ifelse.tbranch = 0;
        tag->tag.ifelse.fbranch = 0;
        break;

    default:
        tag = newtag(t, kind);
        break;
    }
    return tag;

failure:

    /* restore line number, clean up and return null */

    t->linenum = linenum;
    if (name != 0) {
        free(name);
    }
    if (value != 0) {
        free(value);
    }
    if (fmt != 0) {
        free(fmt);
    }
    if (kind != 0 && t->errout != 0) {
        fprintf(t->errout, "Ignoring bad %s tag %sin file \"%s\" line %d\n",
            tagname(kind), err, t->filename, t->tagline);
    }
    return 0;
}

/*
 * scan() is the main scanner function.  We return the next text sequence
 * or template tag in t->curtag or we set it to null at the end of the
 * template.  We start scanning at t->scanptr and when we are done,
 * t->scanptr points to where the next call to scan() should
 * start scanning.  We scan text until we find a tag or comment.  If we
 * find a comment, then we return the text.  If we find a tag, then we
 * save it in t->nexttag and return the text.  We will return t->nexttag
 * the next time scan() is called.  If we find a tag with no preceding
 * text, then we return the tag.  If we find a comment with no preceding
 * text, then we try again.
 */

static void
scan(template *t) {
    tagnode *tag = 0;
    const char *p;
    int i;

    if (t->nexttag != 0) {   /* return tag from previous call */
        t->curtag = t->nexttag;
        t->nexttag = 0;
        return;
    }

    /* scan text until we find a tag or a comment or null */

    p = t->scanptr;
    for (i = 0; p[i] != 0; i++) {
        if (p[i] == '\n') {
            t->linenum++;
        }

		if (is_tag(TMPL_Tag_Comment2Start, p+i))
		{
			if (scancomment(t, p + i) != 0) {
				if (i == 0) {
					scan(t);  /* no text so try again */
					return;
				}
				break;
			}
		}
		else if (is_tag(TMPL_Tag_DelimStart, p+i) || is_tag(TMPL_Tag_CommentStart, p+i))
		{
			if ((tag = scantag(t, p + i)) != 0) {
				break;
			}
		}
    }

    /*
     * At this point p is where we started scanning and p[i] is
     * the first character of the tag or comment that ended this
     * scan or else p[i] is the null at the end of the template.
     */

    if (p[i] == 0) {
        t->scanptr = p + i;
    }
    if (i > 0) {
        t->nexttag = tag;            /* save the tag (if any)    */
        tag = newtag(t, TMPL_Tag_Text);   /* return the text sequence */
        tag->tag.text.start = p;
        tag->tag.text.len   = i;
    }
    t->curtag = tag;
}

/*
 * PARSER FUNCTIONS
 *
 * forward declaration for recursive calls
 */

static tagnode *parselist(template *t, int stop);

/*
 * parseif() parses a TMPL_Tag_If statement, which looks like this:
 *
 * <TMPL_Tag_If name = "varname" value = "testvalue" >
 *    template-list
 * <TMPL_Tag_ElseIf name = "varname" value = "testvalue" >
 *    template-list
 * <TMPL_Tag_Else>
 *    template-list
 * </TMPL_Tag_If>
 *
 * A template-list is any sequence (including an empty sequence)
 * of text, template tags, if statements or loop statements.  There
 * can be zero or more TMPL_Tag_ElseIf tags followed by zero or one
 * TMPL_Tag_Else tag.  There must be a final /TMPL_Tag_If tag.
 *
 * "iftag" is a TMPL_Tag_If tagnode, which has pointers for a true branch
 * and a false branch.  We construct a parse tree for the if statement
 * with "iftag" at the root.  When we are done t->curtag points to
 * the tag that follows the /TMPL_Tag_If tag for this statement.
 */

static void
parseif(template *t, int stop) {
    tagnode *iftag = t->curtag;
    int linenum = t->tagline;
    int mystop = stop | TMPL_Tag_Else | TMPL_Tag_ElseIf | TMPL_Tag_EndIf;

    iftag->tag.ifelse.tbranch = parselist(t, mystop);
    while (t->curtag != 0 && t->curtag->kind == TMPL_Tag_ElseIf) {
        iftag->tag.ifelse.fbranch = t->curtag;
        iftag = t->curtag;
        iftag->tag.ifelse.tbranch = parselist(t, mystop);
    }
    if (t->curtag != 0 && t->curtag->kind == TMPL_Tag_Else) {
        iftag->tag.ifelse.fbranch = parselist(t, stop | TMPL_Tag_EndIf);
    }
    if (t->curtag != 0 && t->curtag->kind == TMPL_Tag_EndIf) {
        scan(t);  /* success, scan next tag */
    }
    else {
        if (t->errout != 0) {
            fprintf(t->errout, "%s tag in file \"%s\" line %d "
                "has no %s tag\n", tagname(TMPL_Tag_If), t->filename, linenum, tagname(TMPL_Tag_EndIf));
        }
        t->error = 1;
    }
}

/*
 * parseloop() parses a TMPL_Tag_Loop statement which looks like this:
 *
 * <TMPL_Tag_Loop name = "loopname">
 *   template-list
 * </TMPL_Tag_Loop>
 *
 * "looptag" is a TMPL_Tag_Loop tagnode, which has a pointer for the
 * loop body.  We construct a parse tree for the loop statement
 * with "looptag" at the root.  When we are done, t->curtag points
 * to the tag that follows the /TMPL_Tag_Loop tag for this statement.
 */

static void
parseloop(template *t, int stop) {
    tagnode *looptag = t->curtag;
    int linenum = t->tagline;

    t->loop_depth++;
    looptag->tag.loop.body = parselist(t, stop | TMPL_Tag_EndLoop);
    t->loop_depth--;

    if (t->curtag != 0 && t->curtag->kind == TMPL_Tag_EndLoop) {
        scan(t);  /* success, scan next tag */
    }
    else {
        if (t->errout != 0) {
            fprintf(t->errout, "%s tag in file \"%s\" line %d "
                "has no %s tag\n", tagname(TMPL_Tag_Loop), t->filename, linenum, tagname(TMPL_Tag_EndLoop));
        }
        t->error = 1;
    }
}

/*
 * parselist() is the top level parser function.  It parses a
 * template-list which is any sequence of text, TMPL_Tag_Var tags,
 * TMPL_Tag_Include tags, if statements or loop statements.
 * We return a parse tree which is a linked list of tagnodes.  The
 * "stop" parameter is a bitmap of tag kinds that we expect to end
 * this list.  For example, if we are parsing the template-list
 * following a TMPL_Tag_If tag, then we expect the list to end with a
 * TMPL_Tag_ElseIf tag or TMPL_Tag_Else tag or /TMPL_Tag_If tag.  If we are parsing the
 * template-list that comprises the entire template, then "stop" is zero
 * so that we keep going to the end of the template.  When we are done,
 * t->curtag is the tag that caused us to stop, or null at the end of
 * the template.
 */

static tagnode *
parselist(template *t, int stop) {
    tagnode *list = 0, *tail, *tag;

    scan(t);
    while ((tag = t->curtag) != 0) {
        switch(tag->kind) {

        case TMPL_Tag_ElseIf:    /* check for terminator tag */
        case TMPL_Tag_Else:
        case TMPL_Tag_EndIf:
        case TMPL_Tag_EndLoop:
            if ((tag->kind & stop) != 0) {
                return list;
            }

            /* unexpected terminator tag -- keep going */

            if (t->errout != 0) {
                fprintf(t->errout, "Unexpected %s tag in file \"%s\" "
                    "line %d\n", tagname(tag->kind), t->filename,
                    t->tagline);
            }
            t->error = 1;
            scan(t);
            if (tag->kind == TMPL_Tag_ElseIf) {
                break;  /* tag linked to list to be freed later */
            }
            continue;   /* tag not linked to list */

        case TMPL_Tag_If:
            parseif(t, stop);
            break;

        case TMPL_Tag_Loop:
            parseloop(t, stop);
            break;

        default:
            scan(t);
            break;
        }

        /* link the tag into the list of tags */

        tag->next = 0;
        if (list == 0) {
            list = tail = tag;
        }
        else {
            tail->next = tag;
            tail = tag;
        }
    }
    return list;
}

/*
 * PARSE TREE WALKING FUNCTIONS
 *
 * valueof() looks up a variable by name and returns its value
 * or returns null if not found.  We search "varlist" and any
 * enclosing variable lists.  The parent of "varlist" is a
 * loop variable, whose parent is a variable list that encloses
 * "varlist".
 */

static char *
valueof(const char *varname, const TMPL_varlist *varlist) {
    TMPL_var *var;

    while(varlist != 0) {
        for (var = varlist->var; var != 0; var = var->next) {
            if (strcmp(varname, var->name) == 0) {
                return var->value;
            }
        }
        varlist = varlist->parent == 0 ? 0 : varlist->parent->parent;
    }
    return 0;
}

/*
 * findloop() looks up a loop variable by name and returns it or
 * returns null if not found.  We search "varlist" and any
 * enclosing variable lists.
 */

static TMPL_loop *
findloop(const char *loopname, const TMPL_varlist *varlist) {
    TMPL_loop *loop;

    while (varlist != 0) {
        for (loop = varlist->loop; loop != 0; loop = loop->next) {
            if (strcmp(loopname, loop->name) == 0) {
                return loop;
            }
        }
        varlist = varlist->parent == 0 ? 0 : varlist->parent->parent;
    }
    return 0;
}

/*
 * istrue() evaluates a TMPL_Tag_If (or TMPL_Tag_ElseIf) tag for true or false.
 *
 * <TMPL_Tag_If name="varname"> is true if 1) simple variable "varname"
 * exists and is not the null string or 2) the loop variable "varname"
 * exists.  Otherwise false.
 *
 * <TMPL_Tag_If name="varname" value=""> is true if "varname" does not exist
 * or if "varname" has a null value.
 *
 * <TMPL_Tag_If name="varname" value="testvalue"> is true if simple variable
 * "varname" has value "testvalue". Otherwise false.
 */

static int
is_true(const tagnode *iftag, const TMPL_varlist *varlist) {
    const char *testval = iftag->tag.ifelse.testval;
    const char *operator = iftag->tag.ifelse.operator;
    const char *value = valueof(iftag->tag.ifelse.varname, varlist);
    //TMPL_loop *loop = 0;

    if (operator == 0) {
    	if (value) {
    		return (strlen(value) > 1);
    	}
    	
    	return (findloop(iftag->tag.ifelse.varname, varlist) > 0);
    	
    } else if (value == 0 || testval == 0) {
    	return 0;
    	
    } else {
    	return
    		(strcmp(operator, "==") == 0 && strcmp(value, testval) == 0) ||
			(strcmp(operator, "!=") == 0 && strcmp(value, testval) != 0) ||
			(strcmp(operator, "<") == 0 && strcmp(value, testval) < 0) ||
			(strcmp(operator, ">") == 0 && strcmp(value, testval) > 0) ||
			(strcmp(operator, ">=") == 0 && strcmp(value, testval) >= 0) ||
			(strcmp(operator, "<=") == 0 && strcmp(value, testval) <= 0);
	}
	
	return 0;
}

/*
 * write_text() writes a text sequence handling \ escapes.
 *
 * A single \ at the end of a line is not output and neither
 * is the line terminator (\n or \r\n).
 *
 * \\ at the end of a line is output as a single \ followed
 * by the line terminator.
 *
 * Any other \ is output unchanged.
 */

static void
write_text(const char *p, int len, FILE *out) {
    int i, k;

    for (i = 0; i < len; i++) {

        /* check for \ or \\ before \n or \r\n */

        if (p[i] == '\\') {
            k = i + 1;
            if (k < len && p[k] == '\\') {
                k++;
            }
            if (k < len && p[k] == '\r') {
                k++;
            }
            if (k < len && p[k] == '\n') {
                if (p[i + 1] == '\\') {
                    i++;      /* skip first \ */
                }
                else {
                    i = k;    /* skip \ and line terminator */
                    continue;
                }
            }
        }
        fputc(p[i], out);
    }
}

/*
 * newfilename() returns a copy of an include file name with
 * possible modifications.  If the include file name begins
 * with ".../" then we replace "..." with the directory name
 * of the parent template file.  If there is no directory
 * name then we strip ".../".
 */

static const char *
newfilename(const char *inclfile, const char *parentfile) {
    char *newfile, *cp;

    newfile = mymalloc(strlen(parentfile) + strlen(inclfile));
    if (strncmp(inclfile, ".../", 4) != 0) {
        return strcpy(newfile, inclfile);
    }
    strcpy(newfile, parentfile);
    cp = strrchr(newfile, '/');
    strcpy(cp == 0 ? newfile : cp + 1, inclfile + 4);
    return newfile;
}

/*
 * walk() walks the template parse tree and outputs the result.  We
 * process the tree nodes according to the data in "varlist".
 */

static void
walk(template *t, tagnode *tag, const TMPL_varlist *varlist) {
    const char *value;
    TMPL_loop *loop;
    TMPL_varlist *vl;
    template *t2;
    const char *newfile;

    /*
     * if t->break_level is non zero then we are unwinding the
     * recursion after encountering a TMPL_Tag_Break tag.  The same
     * is true for t->cont_level and TMPL_Tag_Continue.
     */

    if (tag == 0 || t->break_level > 0 || t->cont_level > 0 ||
        t->error != 0)
    {
        return;
    }
    switch(tag->kind) {

    case TMPL_Tag_Text:
        write_text(tag->tag.text.start, tag->tag.text.len, t->out);
        break;

    case TMPL_Tag_Var:
        if ((value = valueof(tag->tag.var.varname, varlist)) == 0 &&
            (value = tag->tag.var.dfltval) == 0)
        {
            break;
        }

        /* Use the tag's format function or else just use fputs() */

        if (tag->tag.var.fmtfunc != 0) {
            tag->tag.var.fmtfunc(value, t->out);
        }
        else {
            fputs(value, t->out);
        }
        break;

    case TMPL_Tag_If:
    case TMPL_Tag_ElseIf:
        if (is_true(tag, varlist)) {
            walk(t, tag->tag.ifelse.tbranch, varlist);
        }
        else {
            walk(t, tag->tag.ifelse.fbranch, varlist);
        }
        break;

    case TMPL_Tag_Loop:
        if ((loop = findloop(tag->tag.loop.loopname, varlist)) == 0) {
            break;
        }

        for (vl = loop->varlist; vl != 0; vl = vl->next) {
            walk(t, tag->tag.loop.body, vl);

            /*
             * if t->break_level is nonzero then we encountered a
             * TMPL_Tag_Break tag inside this TMPL_Tag_Loop so we need to
             * break here.
             */

            if (t->break_level > 0) {
                t->break_level--;
                break;
            }

            /*
             * if t->cont_level is nonzero then we encountered a
             * TMPL_Tag_Continue inside this TMPL_Tag_Loop.  Depending
             * on the level we either break here or continue
             */

            if (t->cont_level > 0 && --t->cont_level > 0) {
                break;
            }
        }
        break;

    /*
     * For a TMPL_Tag_Break or TMPL_Tag_Continue tag we terminate the walk
     * of this TMPL_Tag_Loop body and set t->break_level or t->cont_level
     * to unwind the recursion.
     */

    case TMPL_Tag_Break:
        t->break_level = tag->tag.breakcont.level;
        return;

    case TMPL_Tag_Continue:
        t->cont_level = tag->tag.breakcont.level;
        return;

    case TMPL_Tag_Include:

        /* if first visit, open and parse the included file */

        if ((t2 = tag->tag.include.tmpl) == 0) {
            newfile = newfilename(tag->tag.include.filename, t->filename);
            t2 = newtemplate(newfile, 0, t->fmtlist,
                t->out, t->errout);
            if (t2 == 0) {
                free((void *) newfile);
                t->error = 1;
                break;
            }
            tag->tag.include.tmpl = t2;
            t2->include_depth = t->include_depth + 1;
            t2->roottag = parselist(t2, 0);
        }

        /* walk the included file's parse tree */

        walk(t2, t2->roottag, varlist);
        t->error = t2->error;
        break;
    }
    walk(t, tag->next, varlist);
}

/*
 * EXPORTED FUNCTIONS
 *
 * TMPL_add_var() adds one or more simple variables to variable list
 * "varlist" and returns the result.  If "varlist" is null, then we
 * create it.  The parameter list has a variable number of "char *"
 * parameters terminated by a null parameter.  Each pair of parameters
 * is a variable name and value that we store in a TMPL_var struct and
 * link into "varlist".
 */

TMPL_varlist *
TMPL_add_var(TMPL_varlist *varlist, ...) {
    va_list ap;
    const char *name, *value;
    TMPL_var *var;
    int nlen, vlen;

    va_start(ap, varlist);
    while ((name = va_arg(ap, char *)) != 0 &&
        (value = va_arg(ap, char *)) != 0)
    {
        /*
         * get enough memory to store the TMPL_var struct and
         * the name string and the value string
         */

        nlen = strlen(name) + 1;
        vlen = strlen(value) + 1;
        var = (TMPL_var *) mymalloc(sizeof(*var) + nlen + vlen);
        strcpy(var->value, value);
        var->name = strcpy(var->value + vlen, name);
        if (varlist == 0) {
            varlist = (TMPL_varlist *) mymalloc(sizeof(*varlist));
            memset(varlist, 0, sizeof(*varlist));
        }
        var->next = varlist->var;
        varlist->var = var;
    }
    va_end(ap);
    return varlist;
}

/*
 * TMPL_add_loop() adds loop variable "loop" to variable list "varlist"
 * and returns the result.  If "varlist" is null, then we create it.
 * We decline to add "loop" if 1) "loop" has already been added to a
 * variable list or 2) adding "loop" would create a cycle because
 * "loop" contains "varlist".
 */

TMPL_varlist *
TMPL_add_loop(TMPL_varlist *varlist, const char *name, TMPL_loop *loop) {
    TMPL_loop *lp;

    /* if sanity check fails, just return */

    if (name == 0 || loop == 0 || loop->parent != 0) {
        return varlist;
    }
    if (varlist == 0) {
        varlist = (TMPL_varlist *) mymalloc(sizeof(*varlist));
        memset(varlist, 0, sizeof(*varlist));
    }

    /* if sanity check for cycle fails, just return */

    for (lp = varlist->parent; lp != 0;
        lp = lp->parent == 0 ? 0 : lp->parent->parent)
    {
        if (lp == loop) {
            return varlist;
        }
    }
    loop->name = strdup(name);
    loop->parent = varlist;
    loop->next = varlist->loop;
    varlist->loop = loop;
    return varlist;
}

/*
 * TMPL_add_varlist() adds variable list "varlist" to loop variable
 * "loop" and returns the result.  If "loop" is null, then we create it.
 * We decline to add "varlist" if 1) "varlist" has already been added
 * to a loop variable or 2) adding "varlist" would create a cycle
 * because "varlist" contains "loop".
 */

TMPL_loop *
TMPL_add_varlist(TMPL_loop *loop, TMPL_varlist *varlist) {
    TMPL_varlist *vl;

    /* if sanity check fails, just return */

    if (varlist == 0 || varlist->parent != 0) {
        return loop;
    }
    if (loop == 0) {
        loop = (TMPL_loop *) mymalloc(sizeof(*loop));
        memset(loop, 0, sizeof(*loop));
    }

    /* if sanity check for cycle fails, just return */

    for (vl = loop->parent; vl != 0;
        vl = vl->parent == 0 ? 0 : vl->parent->parent)
    {
        if (vl == varlist) {
            return loop;
        }
    }
    varlist->parent = loop;
    varlist->next = 0;
    if (loop->varlist == 0) {
        loop->varlist = loop->tail = varlist;
    }
    else {
        loop->tail->next = varlist;
        loop->tail = varlist;
    }
    return loop;
}

/* TMPL_free_varlist() recursively frees memory used by a TMPL_varlist */

void
TMPL_free_varlist(TMPL_varlist *varlist) {
    TMPL_loop *loop, *loopnext;
    TMPL_var  *var,  *varnext;

    if (varlist == 0) {
        return;
    }
    for (loop = varlist->loop; loop != 0; loop = loopnext) {
        loopnext = loop->next;
        TMPL_free_varlist(loop->varlist);
        free((void *) loop->name);
        free(loop);
    }
    for (var = varlist->var; var != 0; var = varnext) {
        varnext = var->next;
        free(var);
    }
    TMPL_free_varlist(varlist->next);
    free(varlist);
}

/*
 * TMPL_add_fmt() adds a name and function pointer to format function
 * list "fmtlist" and returns the result.  If "fmtlist" is null, then
 * we create it, otherwise we return "fmtlist".  Parameter "name" is
 * the name used in the in the fmt="fmtname" attribute of a TMPL_Tag_Var
 * tag.  Parameter "fmtfunc" is a pointer to a user supplied function
 * with a prototype like this:
 *
 *   void funcname(const char *value, FILE *out);
 *
 * The function should output "value" to "out" with appropriate
 * formatting or encoding.
 */

TMPL_fmtlist *
TMPL_add_fmt(TMPL_fmtlist *fmtlist, const char *name,
    TMPL_fmtfunc fmtfunc)
{
    TMPL_fmtlist *newfmt;
    if (name == 0 || fmtfunc == 0) {
        return fmtlist;
    }
    newfmt = (TMPL_fmtlist *) mymalloc(sizeof(*newfmt) + strlen(name));
    strcpy(newfmt->name, name);
    newfmt->fmtfunc = fmtfunc;
    if (fmtlist == 0) {
        newfmt->next = 0;
        return newfmt;
    }

    /* if fmtlist is not null, then we return its original value */

    newfmt->next = fmtlist->next;
    fmtlist->next = newfmt;
    return fmtlist;
}

/* TMPL_free_fmtlist frees memory used by a format function list */

void
TMPL_free_fmtlist(TMPL_fmtlist *fmtlist) {
    if (fmtlist != 0) {
        TMPL_free_fmtlist(fmtlist->next);
        free(fmtlist);
    }
}

/*
 * TMPL_write() outputs a template to open file pointer "out" using
 * variable list "varlist".  If "tmplstr" is null, then we read the
 * template from "filename", otherwise "tmplstr" is the template.
 * Parameter "fmtlist" is a format function list that contains
 * functions that TMPL_Tag_Var tags can specify to output variables.
 * We return 0 on success otherwise -1.  We write errors to open
 * file pointer "errout".
 */

int
TMPL_write(const char *filename, const char *tmplstr,
    const TMPL_fmtlist *fmtlist, const TMPL_varlist *varlist,
    FILE *out, FILE *errout)
{
    int ret;
    template *t;

    if ((t = newtemplate(filename, tmplstr, fmtlist, out, errout)) == 0) {
        return -1;
    }
    t->roottag = parselist(t, 0);
    walk(t, t->roottag, varlist);
    ret = t->error == 0 ? 0 : -1;
    if (tmplstr == 0 && t->tmplstr != 0) {
        free((void *) t->tmplstr);
    }
    freetag(t->roottag);
    free(t);
    return ret;
}

/*
 * Some handy format functions
 *
 * TMPL_encode_entity() converts HTML markup characters to entities
 */

void
TMPL_encode_entity(const char *value, FILE *out) {
    for (; *value != 0; value++) {
        switch(*value) {

        case '&':
            fputs("&amp;", out);
            break;

        case '<':
            fputs("&lt;", out);
            break;

        case '>':
            fputs("&gt;", out);
            break;

        case '"':
            fputs("&quot;", out);
            break;

        case '\'':
            fputs("&#39;", out);
            break;

        case '\n':
            fputs("&#10;", out);
            break;

        case '\r':
            fputs("&#13;", out);
            break;

        default:
            fputc(*value, out);
            break;
        }
    }
}

/* TMPL_encode_url() does URL encoding (%xx)  */

void
TMPL_encode_url(const char *value, FILE *out) {
    static const char hexdigit[] = "0123456789ABCDEF";
    int c;

    for (; *value != 0; value++) {
        if (isalnum(*value) || *value == '.' ||
            *value == '-' || *value == '_')
        {
            fputc(*value, out);
            continue;
        }
        if (*value == ' ') {
            fputc('+', out);
            continue;
        }
        c = (unsigned char) *value;
        fputc('%', out);
        fputc(hexdigit[c >> 4],  out);
        fputc(hexdigit[c & 0xf], out);
    }
}
