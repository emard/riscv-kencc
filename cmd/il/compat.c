#include	"l.h"

/*
 * fake malloc
 */
/*
void*
malloc(ulong n)
{
	void *p;

	while(n & 7)
		n++;
	while(nhunk < n)
		gethunk();
	p = hunk;
	nhunk -= n;
	hunk += n;
	return p;
}

void
free(void *p)
{
	(void*)p; //	USED(p);
}

void*
calloc(ulong m, ulong n)
{
	void *p;

	n *= m;
	p = malloc(n);
	memset(p, 0, n);
	return p;
}

void*
realloc(void* n, ulong m)
{
	fprint(2, "realloc called\n", n,  m);
	abort();
	return 0;
}

void
setmalloctag(void *v, ulong pc)
{
	(void*)v; pc; // USED(v, pc);
}

void*
mysbrk(ulong size)
{
	return sbrk(size);
}
*/
