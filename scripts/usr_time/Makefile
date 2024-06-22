CFLAGS ?= -Wall -O3 -g -march=native
CC = gcc
AR = gcc-ar
LDFLAGS = -flto=8
OBJECTS = align.o alnfrags.o ankers.o assembly.o chain.o compdna.o compkmers.o compress.o conclave.o db.o decon.o dist.o ef.o filebuff.o frags.o hashmap.o hashmapcci.o hashmapkma.o hashmapkmers.o hashtable.o index.o kma.o kmapipe.o kmeranker.o kmers.o kmmap.o loadupdate.o makeindex.o matrix.o mt1.o nw.o pherror.o printconsensus.o qseqs.o qualcheck.o runinput.o runkma.o sam.o savekmers.o seq2fasta.o seqmenttree.o seqparse.o shm.o sparse.o spltdb.o stdnuc.o stdstat.o trim.o tmp.o tsv.o update.o updateindex.o updatescores.o valueshash.o vcf.o xml.o
PROGS = kma kma_index kma_shm kma_update

all: $(PROGS)

kma: main.c $(OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c main.c $(OBJECTS)

kma_index: kma_index.c $(OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c kma_index.c $(OBJECTS)

kma_shm: kma_shm.c $(OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c kma_shm.c $(OBJECTS)

kma_update: kma_update.c $(OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c kma_update.c $(OBJECTS)

align.o: align.c align.h chain.h compdna.h hashmapcci.h nw.h stdnuc.h stdstat.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

alnfrags.o: alnfrags.c alnfrags.h align.h ankers.h compdna.h hashmapcci.h qseqs.h threader.h updatescores.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

ankers.o: ankers.c ankers.h compdna.h pherror.h qseqs.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

assembly.o: assembly.c assembly.h align.h filebuff.h hashmapcci.h kmapipe.h pherror.h stdnuc.h stdstat.h threader.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

chain.o: chain.c chain.h penalties.h pherror.h stdstat.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

compdna.o: compdna.c compdna.h pherror.h stdnuc.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

compkmers.o: compkmers.c compkmers.h pherror.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

compress.o: compress.c compress.h hashmap.h hashmapkma.h pherror.h valueshash.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

conclave.o: conclave.c conclave.h frags.h pherror.h qseqs.h stdnuc.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

db.o: db.c db.h hashmapkma.h pherror.h stdstat.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

decon.o: decon.c decon.h compdna.h filebuff.h hashmapkma.h seqparse.h stdnuc.h qseqs.h updateindex.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

dist.o: dist.c dist.h hashmapkma.h matrix.h pherror.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

ef.o: ef.c ef.h assembly.h stdnuc.h vcf.h version.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

filebuff.o: filebuff.c filebuff.h pherror.h qseqs.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

frags.o: frags.c frags.h filebuff.h pherror.h qseqs.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

hashmap.o: hashmap.c hashmap.h hashtable.h pherror.h stdstat.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

hashmapcci.o: hashmapcci.c hashmapcci.c hashmapcci.h pherror.h stdnuc.h stdstat.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

hashmapkma.o: hashmapkma.c hashmapkma.h pherror.h stdstat.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

hashmapkmers.o: hashmapkmers.c hashmapkmers.h pherror.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

hashtable.o: hashtable.c hashtable.h hashmapkma.h hashmapkmers.h pherror.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

index.o: index.c index.h compress.h decon.h hashmap.h hashmapkma.h loadupdate.h makeindex.h pherror.h stdstat.h version.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

kma.o: kma.c kma.h ankers.h assembly.h chain.h hashmapkma.h kmers.h mt1.h penalties.h pherror.h qseqs.h runinput.h runkma.h savekmers.h sparse.h spltdb.h tmp.h version.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

kmapipe.o: kmapipe.c kmapipe.h pherror.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

kmeranker.o: kmeranker.c kmeranker.h penalties.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

kmers.o: kmers.c kmers.h ankers.h compdna.h hashmapkma.h kmapipe.h pherror.h qseqs.h savekmers.h spltdb.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

kmmap.o: kmmap.c kmmap.h hashmapkma.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

loadupdate.o: loadupdate.c loadupdate.h pherror.h hashmap.h hashmapkma.h updateindex.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

makeindex.o: makeindex.c makeindex.h compdna.h filebuff.h hashmap.h pherror.h qseqs.h seqparse.h updateindex.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

matrix.o: matrix.c matrix.h pherror.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

mt1.o: mt1.c mt1.h assembly.h chain.h filebuff.h hashmapcci.h kmapipe.h nw.h penalties.h pherror.h printconsensus.h qseqs.h runkma.h stdstat.h tsv.h vcf.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

nw.o: nw.c nw.h pherror.h stdnuc.h penalties.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

pherror.o: pherror.c pherror.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

printconsensus.o: printconsensus.c printconsensus.h assembly.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

qseqs.o: qseqs.c qseqs.h pherror.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

qualcheck.o: qualcheck.c qualcheck.h compdna.h hashmap.h pherror.h stdnuc.h stdstat.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

runinput.o: runinput.c runinput.h compdna.h filebuff.h pherror.h qseqs.h seqparse.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

runkma.o: runkma.c runkma.h align.h alnfrags.h assembly.h chain.h compdna.h ef.h filebuff.h frags.h hashmapcci.h kmapipe.h nw.h pherror.h printconsensus.h qseqs.h stdnuc.h stdstat.h tmp.h tsv.h vcf.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

sam.o: sam.c sam.h nw.h pherror.h qseqs.h runkma.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

savekmers.o: savekmers.c savekmers.h ankers.h compdna.h hashmapkma.h kmeranker.h penalties.h pherror.h qseqs.h stdnuc.h stdstat.h threader.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

seq2fasta.o: seq2fasta.c seq2fasta.h pherror.h qseqs.h runkma.h stdnuc.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

seqmenttree.o: seqmenttree.c seqmenttree.h pherror.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

seqparse.o: seqparse.c seqparse.h filebuff.h qseqs.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

shm.o: shm.c shm.h pherror.h hashmapkma.h version.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

sparse.o: sparse.c sparse.h compkmers.h hashtable.h kmapipe.h pherror.h runinput.h savekmers.h stdnuc.h stdstat.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

spltdb.o: spltdb.c spltdb.h align.h alnfrags.h assembly.h chain.h compdna.h ef.h filebuff.h frags.h hashmapcci.h kmapipe.h nw.h pherror.h printconsensus.h qseqs.h runkma.h stdnuc.h stdstat.h tmp.h tsv.h vcf.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

stdnuc.o: stdnuc.c stdnuc.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

stdstat.o: stdstat.c stdstat.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

trim.o: trim.c trim.h compdna.h pherror.h runinput.h qseqs.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

tmp.o: tmp.c tmp.h pherror.h threader.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

tsv.o: tsv.c tsv.h assembly.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

update.o: update.c update.h hashmapkma.h pherror.h stdnuc.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

updateindex.o: updateindex.c updateindex.h compdna.h hashmap.h hashmapcci.h pherror.h qualcheck.h stdnuc.h pherror.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

updatescores.o: updatescores.c updatescores.h qseqs.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

valueshash.o: valueshash.c valueshash.h pherror.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

vcf.o: vcf.c vcf.h assembly.h filebuff.h stdnuc.h stdstat.h version.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

xml.o: xml.c xml.h pherror.h version.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -c $<

clean:
	$(RM) $(OBJECTS) $(PROGS)
