/* Copyright (c) 2002-2006 Lucent Technologies; see LICENSE */
#include "lib9.h"

#include "fmtdef.h"


Rune*
runevseprint(Rune *buf, Rune *e, char *fmt, va_list args)
{
  Fmt f;

  if(e <= buf)
    return nil;
  f.runes = 1;
  f.start = buf;
  f.to = buf;
  f.stop = e - 1;
  f.flush = nil;
  f.farg = nil;
  f.nfmt = 0;
  VA_COPY(f.args,args);
  dofmt(&f, fmt);
  VA_END(f.args);
  *(Rune*)f.to = '\0';
  return (Rune*)f.to;
}

