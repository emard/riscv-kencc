/*
 * The authors of this software are Rob Pike and Ken Thompson.
 *              Copyright (c) 2002 by Lucent Technologies.
 * Permission to use, copy, modify, and distribute this software for any
 * purpose without fee is hereby granted, provided that this entire notice
 * is included in all copies of any software which is or includes a copy
 * or modification of this software and in all copies of the supporting
 * documentation for such software.
 * THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTY.  IN PARTICULAR, NEITHER THE AUTHORS NOR LUCENT TECHNOLOGIES MAKE ANY
 * REPRESENTATION OR WARRANTY OF ANY KIND CONCERNING THE MERCHANTABILITY
 * OF THIS SOFTWARE OR ITS FITNESS FOR ANY PARTICULAR PURPOSE.
 */
#include "lib9.h"
#include "fmtdef.h"


/*
 * format a string into the output buffer
 * designed for formats which themselves call fmt,
 * but ignore any width flags
 */
 int
 fmtvprint(Fmt *f, char *fmt, va_list args)
 {
   va_list va;
   int n;
 
   f->flags = 0;
   f->width = 0;
   f->prec = 0;
   VA_COPY(va,f->args);
   VA_END(f->args);
   VA_COPY(f->args,args);
   n = dofmt(f, fmt);
   f->flags = 0;
   f->width = 0;
   f->prec = 0;
   VA_END(f->args);
   VA_COPY(f->args,va);
   VA_END(va);
   if(n >= 0)
     return 0;
   return n;
 }


