CFLAGS = -I .

.PHONY: clean test all doc

template: template.o libctemplate.a
	$(CC) $(CFLAGS) -o template -L . template.o -lctemplate

libctemplate.a: ctemplate.o
	ar r libctemplate.a ctemplate.o
	ranlib libctemplate.a

ctemplate.o: ctemplate.c ctemplate.h

template.o: template.c ctemplate.h

clean:
	rm -f *.o *.a template

test:
	cd t; ./test.sh

doc: documentation.html documentation.pdf

documentation.html: documentation.md
	multimarkdown -t html documentation.md > documentation.html
	
documentation.pdf: documentation.md
	mmdtops --format=pdf documentation.md > documentation.pdf
