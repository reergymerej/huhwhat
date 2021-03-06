#!/usr/bin/env bash
# Purpose: move current journal entry to archive, start new journal entry with defaults.
# Supports specific journals identified with single-word names. If there's no name or 
# the wrong name, script exits with the message "No." Makes use of some external templates
# where identified. Also takes preffered modelines from an external file to avoid editor
# confusion.
#
# Use: sh journal_archive.sh [Journal Name]

JOURNALNAME=$1
CURRENT="$JOURNALNAME"_Journal_Current.markdown
ARCHIVE="$JOURNALNAME"_Journal_Archive.markdown
JOURNALMODELINES=$(cat modelines_for_journals)

case "$JOURNALNAME" in
	"Professional")
		# sed prints everyting between the two strings below, including the strings.
		# https://www.gnu.org/software/sed/manual/html_node/sed-commands-list.html
		# sed -n start_pattern,end_pattern/p
		#
		# I do this because I want to preserve everything that's still on my list of
		# things to do between professional journal entries.
		DEFAULTENTRY=$(sed -n "/## Things and Stuff/,/## Completed/p" $CURRENT);;
	"Nethack")
		# I have a standard set of things I want to see in each new Nethack journal
		# page. I keep them stored elsewhere for inclusion here.
		DEFAULTENTRY=$(cat Nethack_Journal_Template.markdown);;
	*) echo "No"; exit ;;
esac

# If the archive doesn't already exist, create it with the preferred modelines at the
# top of the file.
if [ ! -f "$ARCHIVE" ]; then
	echo -e "$JOURNALMODELINES\n\n" > $ARCHIVE
fi

# When the above case is done, get all the lines from the current page EXCEPT the last one,
# which only contains modelines.
head $CURRENT --lines=-1 >> $ARCHIVE

# Then overwrite the existing journal page with a new one starting with the date at headline 1,
# the default entry, and (you guessed it) any modelines we want.
echo -e "# $(date)\n\n$DEFAULTENTRY\n\n\n$JOURNALMODELINES" > $CURRENT
