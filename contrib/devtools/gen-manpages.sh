#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

GREENCITYD=${GREENCITYD:-$BINDIR/greencityd}
GREENCITYCLI=${GREENCITYCLI:-$BINDIR/greencity-cli}
GREENCITYTX=${GREENCITYTX:-$BINDIR/greencity-tx}
GREENCITYQT=${GREENCITYQT:-$BINDIR/qt/greencity-qt}

[ ! -x $GREENCITYD ] && echo "$GREENCITYD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
BTCVER=($($GREENCITYCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for greencityd if --version-string is not set,
# but has different outcomes for bitcoin-qt and greencity-cli.
echo "[COPYRIGHT]" > footer.h2m
$GREENCITYD --version | sed -n '1!p' >> footer.h2m

for cmd in $GREENCITYD $GREENCITYCLI $GREENCITYTX $GREENCITYQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${BTCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${BTCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
