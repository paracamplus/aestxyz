# Makefile generated by imake - do not edit!

# ================ Generic Header ====================================
# $Id: Imake.tmpl,v 1.42 2005/06/11 08:24:05 queinnec Exp queinnec $

# Define commands and other parameters specific to site:

# ====================# Generic Site Parameters =======================
# $Id: Site.def,v 1.29 2005/06/11 08:24:16 queinnec Exp queinnec $

HOME   		= /home/queinnec
HOST		= bijou
HOSTTYPE	= x86_64
CVSROOT         = /CVS.src/master

LATEX		= latex
BIBTEX		= bibtex
DELATEX		= detex -l
MAKEINDEX	= makeindex
SPELL		= ispell -l
EPELLE		= epelle -latex
PACK		= gzip
UNPACK		= gunzip
RM		= rm -f
CC		= cc
MAKE            = make
DVIPS           = dvips
DVIPSFLAGS	= -D600 -Z
LiSP2TeXFLAGS   = -vU -I/usr/local/lib/LiSP2TeX
RSYNC		= rsync --rsh ssh -z
RDIST		= rdist -P /usr/bin/ssh
RSH		= ssh -A -g -X
HEVEA		= hevea
HEVEAFLAGS	= -v -I ${HOME}/Hevea
HACHA		= hacha
HACHAFLAGS	= -v

XDVI            =       xdvi
ADVI            =       advi

TRANG	=	${HOME}/Cours/ILP/Java/jars/trang.jar
JING	=	${HOME}/Cours/ILP/Java/jars/jing.jar

# The generic rules that hold everywhere. They mainly concern
# concern TeX generation which is a not naive task given the
# circular constraints that exist.
.SUFFIXES: .epelle .spell .ind .idx .pdf .ps .dvi .bbl .aux .tex .bk .hbk

.tex.dvi: ;	${LATEX} $*.tex
.tex.aux: ;	${LATEX} $*.tex
.tex.bbl: ;	-${BIBTEX} $*
.idx.ind: ;	${MAKEINDEX} $*
.tex.spell: ;	${DELATEX} $*.tex | ${SPELL} | sort -u >$*.spell
.tex.epelle:
	DICOPLUS=${HOME}/.dicoplus.z ${EPELLE} $*.tex >$*.epelle

.dvi.ps:
	${DVIPS} ${DVIPSFLAGS} $*.dvi -o $*.ps
.ps.pdf:
	ps2pdf13 -r1800 -sPAPERSIZE=a4 -dPDFSETTINGS=/printer $*.ps $*.pdf

.SUFFIXES: .tex .rtf
LATEX2RTFFLAGS	=	-i french
.tex.rtf :
	latex2rtf -l ${LATEX2RTFFLAGS} -o $*.rtf $*.tex

# Default entry for the LiSP2TeX tool
L2TFLAGS   = -vU -I/usr/local/lib/l2t
.SUFFIXES: .tex .bk
.bk.tex :
	l2t ${L2TFLAGS} -- $*.bk > $*.tx
	expand < $*.tx > $*.tex && rm $*.tx
.SUFFIXES: .tex .hbk
.hbk.tex :
	l2t ${L2TFLAGS} -- $*.hbk > $*.tx
	expand < $*.tx > $*.tex && rm $*.tx

# Rules to convert xfig figures.
.SUFFIXES: .tex .ps .eps .xfig .fig .gif
.xfig.ps : ;	fig2dev -L ps $*.xfig > $*.ps
.fig.ps : ;	fig2dev -L ps ${FIG2DEV_FLAGS} $*.fig > $*.ps
.xfig.eps : ;	fig2dev -L eps $*.xfig > $*.eps
.fig.eps : ;	fig2dev -L eps ${FIG2DEV_FLAGS} $*.fig > $*.eps
.xfig.tex : ;	fig2dev -L latex $*.xfig > $*.tex
.fig.tex : ;	fig2dev -L latex ${FIG2DEV_FLAGS} $*.fig > $*.tex
.xfig.gif :
	fig2dev -L gif -t '#ffffff' $*.xfig $*.gf
	giftrans -t '#ffffff' -o $*.gif $*.gf
	rm $*.gf
.fig.gif :
	fig2dev -L gif -t '#ffffff' ${FIG2DEV_FLAGS} $*.fig $*.gf
	giftrans -t '#ffffff' -o $*.gif $*.gf
	rm $*.gf
.gif.eps :
	convert $*.gif $*.eps

.SUFFIXES: .rnc .rng
.rnc.rng :
	java -jar ${TRANG} 		-i encoding=iso-8859-15 		-o encoding=iso-8859-15 		$*.rnc $*.rng

# =====================================================================
# $Id: Imake.rules,v 1.38 2005/04/08 18:17:13 queinnec Exp queinnec $

# ==================== Specific entries ===============================

# $Id$

HOSTTYPE	=	x86_64

TRANSCODE	=	bin/${HOSTTYPE}/transcode

work : ${TRANSCODE} tests
clean :: cleanMakefile

CFLAGS	+=	-std=c99 -Wall -pedantic -Werror

${TRANSCODE} : transcode.c
	[ "${HOSTTYPE}" ] || { echo Missing HOSTTYPE ; exit 1 ; }
	-mkdir -p bin/${HOSTTYPE}
	${CC} ${CFLAGS} -o ${TRANSCODE} transcode.c

test tests : 	test.transcode 		test.transcode.utf8 		test.options

	@echo; echo '		ALL TESTS SUCCESSFUL'

TRANSCODE_FLAGS	=

test.transcode : ${TRANSCODE}
	${TRANSCODE} ${TRANSCODE_FLAGS} < TestFiles/ok1.txt > /tmp/ok1
	cmp TestFiles/ok1.txt /tmp/ok1
	${TRANSCODE} ${TRANSCODE_FLAGS} < TestFiles/ok2.txt > /tmp/ok2
	cmp TestFiles/ok2.txt /tmp/ok2
	[ 4 -eq `printf "&'<>" | ${TRANSCODE} | tr '&' '\n' | grep -c ';'` ]
	[ 4 -eq `printf '&"<>' | ${TRANSCODE} | tr '&' '\n' | grep -c ';'` ]

test.transcode.utf8 :
	printf "\351t\351" | ${TRANSCODE} | grep 271c
	printf "\351t\351" | ${TRANSCODE} | grep E9
	printf "\351t\351" | ${TRANSCODE} | grep t
	printf "\303\251t\303\251" | ${TRANSCODE} | grep -v 271c

test.options : 	test.option.verbose 		test.option.help 		test.option.s 		test.option.b 		test.option.g 		test.option.l 		test.option.c

test.option.c :
	echo abc | ${TRANSCODE} -c
	[ 'abc' = `echo abc | ${TRANSCODE} -c` ]
	[ 'abc' = `echo abc | ${TRANSCODE} --charHTML` ]
	[ '<&>' = `echo '<&>' | ${TRANSCODE} -c` ]

test.option.help :
	${TRANSCODE} --help 2>/tmp/v
	[ `wc -l </tmp/v` -ge 2 ]
	${TRANSCODE} --h 2>/tmp/v
	[ `wc -l </tmp/v` -ge 2 ]

test.option.verbose :
	make test.transcode TRANSCODE_FLAGS=-v 2>/tmp/v
	[ `grep transcode < /tmp/v | wc -l` -ge 100 ]

test.option.s :
	${TRANSCODE} --s=-10 ; [ "$$?" -ne 0 ]
	${TRANSCODE} --s=ab ; [ "$$?" -ne 0 ]
	[ 1 = `echo "12345678" | ${TRANSCODE} --s=10 | wc -l` ]
	[ 1 = `echo "123456789" | ${TRANSCODE} --s=10 | wc -l` ]
	[ 1 = `echo "1234567890" | ${TRANSCODE} --s=10 | wc -l` ]
	[ 2 = `echo "12345678901" | ${TRANSCODE} --s=10 | wc -l` ]
	[ 2 = `echo "1234567890123456789" | ${TRANSCODE} --s=10 | wc -l` ]
	[ 2 = `echo "12345678901234567890" | ${TRANSCODE} --s=10 | wc -l` ]
	[ 3 = `echo "123456789012345678901" | ${TRANSCODE} --s=10 | wc -l` ]
	[ 1 = `echo "123456789012345678901" | ${TRANSCODE} --s=0 | wc -l` ]

test.option.b :
	${TRANSCODE} --b=a ; [ "$$?" -ne 0 ]
	[ 4 -eq `echo 123 | ${TRANSCODE} --b=1 | wc -c` ]
	printf 'a\7c' | ${TRANSCODE} --b=1 | grep 275a
	printf 'a\7c' | ${TRANSCODE} --b=1 | grep -v 2639
	printf 'a\7\2c' | ${TRANSCODE} --b=1 | grep 2639
	printf 'a\7\2c' | ${TRANSCODE} --b=0 | grep -v 2639

test.option.g :
	${TRANSCODE} --g=1b ; [ "$$?" -ne 0 ]
	[ 4 -eq `echo 123 | ${TRANSCODE} --g=0 | wc -c` ]
	[ 4 -eq `echo abc | ${TRANSCODE} --g=10 | wc -c` ]
	[ 4 -eq `echo abc | ${TRANSCODE} --g=4 | wc -c` ]
	[ 4 -lt `echo abc | ${TRANSCODE} --g=3 | wc -c` ]
	[ 4 -lt `echo abc | ${TRANSCODE} --g=2 | wc -c` ]
	echo abc | ${TRANSCODE} --g=3 | grep abc
	echo abc | ${TRANSCODE} --g=2 | grep 2340

test.option.l :
	printf "a\nbc\n" | ${TRANSCODE} --l | grep lineNumber
	printf "a\nbc\n" | ${TRANSCODE} --l | grep 1
	printf "a\nbc\n" | ${TRANSCODE} --l | grep 2

# end of Imakefile

# ==================== Generic entries ================================
# The generic entries that must be everywhere;
PROMPT	=	">>>>>>>>>>>>>>>>>"

# This one does nothing
nothing :

# Check-in back all files that are checked-out whether RCS or CVS
ckpt :
	@perl ${HOME}/perl/ckpt.prl .
rec.ckpt : ckpt
	@PWD=`pwd` ; export PWD                                 ; \
	for d in `find . -type d -print`                        ; \
	  do ( cd $$d ; echo Checkpointing $$d                        ; \
	    ${MAKE} -f $$PWD/Makefile ckpt ) ; done

# Sanitize with respect to RCS or CVS (faster than old.notci)
notci sanitize :
	@perl ${HOME}/perl/sanitize.prl .
rec.notci : notci
	@PWD=`pwd` ; export PWD                                 ; \
	for d in `find . -type d -print`                        ; \
	  do ( cd $$d ; echo Sanitizing $$d                        ; \
	    ${MAKE} -f $$PWD/Makefile notci ) ; done

# Erase useless files
clean ::
	-${RM} core *.BAK *~ .*.BAK .*~ *.~*.~ .*.~*.~
rec.clean : clean
	@PWD=`pwd` ; export PWD                                 ; \
	for d in `find . -type d -print`                        ; \
	  do ( cd $$d ; echo Cleaning $$d                        ; \
	    ${MAKE} -f $$PWD/Makefile clean ) ; done

# Erase useless files in a Tex, LaTeX, BibTeX contexts, ChangeBar files
cleantex ::
	-${RM} *.log *.aux *.lof *.lot *.toc
	-${RM} *.blg *.bbl
	-${RM} *.idx *.ilg *.ind
	-${RM} *.spell *.epelle
	-${RM} *.cb
cleandvi ::
	-${RM} *.dvi

advi.pro :
	ln -sf /usr/share/texmf/tex/latex/advi/advi.pro ./

# Calm down the screen saver during a presentation:
xset.off :
	xset s off

# This entry maps a make entry on all subdirectories, the work to be
# done is held in the MAPWORK variable
MAPWORK=clean
mapdirectories ::
	@for d in `ls -F | sed -e '/\/\$$/s,.\$$,,p' -e d` 	; 	do ( cd $$d 						; 	     echo "			on $$d: m ${MAPWORK}" 	; 	     m ${MAKEFLAGS} "${MAPWORK}" ) 			; 	done

# This entry compresses all not yet compressed files of a directory. The
# makefile is not compressed in order to ease the reverse action.
compress ::
	@for f in `ls -AF`					; 	 do case $$f in *[mM]akefile|*/|*.Z) :			;;                         *) echo ${PACK} $$f ; ${PACK} $$f	;;             esac						;          done

# This entry removes the generated Makefile.
# Usually one uses it as                clean :: cleanMakefile
cleanMakefile :
	-@if [ -f Imakefile ] ; then ${RM} -f Makefile ; fi

# This entry depends on FILE, STAMP and DATE
# It changes all occurrences of STAMP...tar into STAMPDATE.tar
# This is used to keep track of files within html pages.

update.file :
	@if [ -z "${FILE}" ] ; then echo Define FILE first ; exit 1 ;		else exit 0 ; fi

	@if [ -z "${STAMP}" ] ; then echo Define STAMP first ; exit 1 ;		else exit 0 ; fi

	@if [ -z "${DATE}" ] ; then echo Define DATE first ; exit 1 ;		else exit 0 ; fi

	@echo
	@echo "	Updating ${FILE} ..."
	@echo
	if [ -f ${FILE}.BAK ]; then exit 0; else 	  mv ${FILE} ${FILE}.BAK ; cp ${FILE}.BAK ${FILE} ; fi

	$$HOME/perl/updatefile.prl -stamp="${STAMP}" -date="${DATE}" -- ${FILE}
	chmod u+w ${FILE}

# Turn off the screen saver during a talk

screen.saver.off :
	xset s off

