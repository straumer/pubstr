.POSIX:

PREFIX = /usr/local
MANPREFIX = ${PREFIX}/share/man
# OpenBSD: change to ${PREFIX}/man

install:
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f pubstr ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/pubstr
	mkdir -p ${DESTDIR}${MANPREFIX}/man1
	cp -f pubstr.1 ${DESTDIR}${MANPREFIX}/man1/pubstr.1
	chmod 644 ${DESTDIR}${MANPREFIX}/man1/pubstr.1

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/pubstr\
		${DESTDIR}${MANPREFIX}/man1/pubstr.1
