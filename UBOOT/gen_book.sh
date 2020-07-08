#!/bin/bash
#
# Copyright (c) 2019 Fuzhou Rockchip Electronics Co., Ltd
#
# SPDX-License-Identifier: GPL-2.0
#

set -e

TMP_DIR=".book"
BOOK_NAME="Rockchip_Developer_Guide_UBoot_Nextdev_CN.md"
FILE_LIST=`ls CH*.md | sort`

# Remove old
rm $BOOK_NAME -rf
rm $TMP_DIR -rf

# Copy
mkdir $TMP_DIR && cp CH*.md $TMP_DIR/

# Append if there is not newline.
ls $TMP_DIR/CH*.md | while read f; do tail -n1 $f | read -r _ || echo >> $f; done

for file in $FILE_LIST
do
	echo "Pack: $file"

	# Trim space at the end of line
	sed -i 's/\ \+$//g' $TMP_DIR/$file

	# Append chapter prefix id from CH01-*.md.
	id=`echo $file | cut -b 3,4`
	id=`echo $id | awk '{print int($0)}'`
	if [ $id -gt 0 ]; then
		sed -i \
		    -e 's/^######[[:blank:]]\+/####### /' \
		    -e 's/^#####[[:blank:]]\+/###### /' \
		    -e 's/^####[[:blank:]]\+/##### /' \
		    -e 's/^###[[:blank:]]\+/#### /' \
		    -e 's/^##[[:blank:]]\+/### /' \
		    -e "s/^#[[:blank:]]\+/## Chapter-${id} /" $TMP_DIR/$file

		# Page break for PDF export
		echo -e "\n---\n" >> $BOOK_NAME
	fi

	# Append Chapter content
	cat $TMP_DIR/$file >> $BOOK_NAME
done

rm $TMP_DIR -rf

# Only leave the 1st [TOC] in CH00-*.md, delete others.
sed -i '0,/\[TOC\]/s//TTOOCC/' $BOOK_NAME
sed -i '/\[TOC\]/d' $BOOK_NAME
sed -i '0,/TTOOCC/s//\[TOC\]/' $BOOK_NAME

echo
echo "$BOOK_NAME is ready. (Note: remember to update release version/date)"
echo
