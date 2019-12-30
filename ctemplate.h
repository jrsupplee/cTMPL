/*
 * C Template Library 1.0
 *
 * Copyright 2009 Stephen C. Losen.  Distributed under the terms
 * of the GNU General Public License (GPL)
 */

#ifndef _CTEMPLATE_H
#define _CTEMPLATE_H

typedef enum {
	/*
	 * The following numbers must be representable in binary
	 * by a single one
	 */
	TMPL_Tag_ElseIf			= 0x01,
	TMPL_Tag_Else			= 0x02,
	TMPL_Tag_EndIf			= 0x04,
	TMPL_Tag_EndLoop		= 0x08,

	/*
	 * One bit only not needed for these
	 */
	TMPL_Tag_Unknown		= 0x00,
	TMPL_Tag_Loop			= 0x03,
	TMPL_Tag_If				= 0x05,
	TMPL_Tag_Text			= 0x06,
	TMPL_Tag_Var			= 0x07,
	TMPL_Tag_Include		= 0x09,
	TMPL_Tag_Break			= 0x0a,
	TMPL_Tag_Continue		= 0x0b,
	TMPL_Tag_DelimStart		= 0x0c,
	TMPL_Tag_DelimEnd		= 0x0d,
	TMPL_Tag_CommentStart	= 0x0e,
	TMPL_Tag_CommentEnd		= 0x0f,
	TMPL_Tag_Comment2Start	= 0x10,
	TMPL_Tag_Comment2End	= 0x11
} TMPL_Tags;


typedef struct TMPL_varlist TMPL_varlist;
typedef struct TMPL_loop  TMPL_loop;
typedef struct TMPL_fmtlist TMPL_fmtlist;
typedef void (*TMPL_fmtfunc) (const char *, FILE *);

/*

TMPL_varlist *TMPL_add_var(TMPL_varlist *varlist,
    const char *varname1, const char *value1, ... , 0);
*/

TMPL_varlist *TMPL_add_var(TMPL_varlist *varlist, ...);

TMPL_varlist *TMPL_add_loop(TMPL_varlist *varlist,
    const char *name, TMPL_loop *loop);

TMPL_loop *TMPL_add_varlist(TMPL_loop *loop, TMPL_varlist *varlist);

void TMPL_free_varlist(TMPL_varlist *varlist);

TMPL_fmtlist *TMPL_add_fmt(TMPL_fmtlist *fmtlist,
    const char *name, TMPL_fmtfunc fmtfunc);

void TMPL_free_fmtlist(TMPL_fmtlist *fmtlist);

int TMPL_write(const char *filename, const char *tmplstr,
    const TMPL_fmtlist *fmtlist, const TMPL_varlist *varlist,
    FILE *out, FILE *errout);

void TMPL_encode_entity(const char *value, FILE *out);

void TMPL_encode_url(const char *value, FILE *out);

void TMPL_tagname_set( TMPL_Tags tag, const char* label );

const char* TMPL_tagname_get( TMPL_Tags tag );

#endif
