#!/bin/bash

readonly CURDIR="$(dirname $(readlink -f "$0"))"

get_context() {
	case $1 in
		actions)
			context=Actions
			;;
		animations)
			context=Animations
			;;
		apps)
			context=Applications
			;;
		categories)
			context=Categories
			;;
		devices)
			context=Devices
			;;
		emblems)
			context=Emblems
			;;
		emotes)
			context=Emotes
			;;
		mimetypes)
			context=MimeTypes
			;;
		places)
			context=Places
			;;
		status)
			context=Status
			;;
		stock)
			context=Stock
			;;
	esac
	echo $context
}

get_theme_name() {
	if [ "$1" = "." ]; then
		echo Faience-ng
	else
		echo "$1" | sed s/__/Faience-ng-/
	fi
}

OUTSIZES="8x8 16x16 22x22 24x24 32x32 48x48 256x256"

case $1 in
	all) # Cook drawn icons to DESTDIR
	#rm -rf ${CURDIR}/DESTDIR
	for theme in $(ls ${CURDIR}/ | egrep "^Faience-ng"); do #Faience-ng Faience-ng-Dark Faience-ng-Light Faience-ng-Blue Faience-ng-Green
			INDIR="${CURDIR}/${theme}"
			OUTDIR="${CURDIR}/DESTDIR/$theme"
			mkdir -p "${OUTDIR}"
		for i in $OUTSIZES; do #scalable 256x256 32x32
			for j in actions animations apps categories devices emblems mimetypes places status stock; do
				mkdir -p ${OUTDIR}/${i}/${j}
			done
		done
		#if false; then
		for j in actions apps categories devices emblems mimetypes places status stock; do
			[ ! -d "${INDIR}/${j}" ] && continue
			if [ -d "${INDIR}/${j}/16x16" ]; then
				for f in "${INDIR}/${j}/16x16"/*.svg; do
					[ ! -f "$f" ] && continue
					inkscape -z -y 0.0 -w 16 -h 16 --file="${f}" --export-png="${OUTDIR}/16x16/${j}/$(basename -s .svg "${f}").png"
				done
			fi
			if [ -d "${INDIR}/${j}/24x24" ]; then
				for f in "${INDIR}/${j}/24x24"/*.svg; do
					[ ! -f "$f" ] && continue
					#size=$(identify "${f}" | cut -d\   -f3 | cut -dx -f1)
					size=$(grep -Po -m1 'width="[\d]+"' "${f}" | cut -d'"' -f2)
					fname=$(basename -s .svg "${f}")
					if [ "$size" = "22" ]; then
						inkscape -z -y 0.0 -w 22 -h 22 --file="${f}" --export-png="${OUTDIR}/22x22/${j}/${fname}.png"
						inkscape -z -y 0.0 -w 24 -h 24 --export-area=-1:-1:23:23 --file="${f}" --export-png="${OUTDIR}/24x24/${j}/${fname}.png"
					elif [ "$size" = "24" ]; then
						inkscape -z -y 0.0 -w 22 -h 22 --export-area=1:1:23:23 --file="${f}" --export-png="${OUTDIR}/22x22/${j}/${fname}.png"
						inkscape -z -y 0.0 -w 24 -h 24 --file="${f}" --export-png="${OUTDIR}/24x24/${j}/${fname}.png"
					else
						echo "ERROR_________________________________"
						exit
					fi
				done
			fi
			[ ! -e "${INDIR}/${j}/96x96"/*.svg ] && continue
			for f in "${INDIR}/${j}/96x96"/*.svg; do
				[ ! -f "$f" ] && continue
				for s in ${OUTSIZES}; do
					case $s in
						8x8|16x16|22x22|24x24)
							continue
						;;
					esac
					inkscape -z -y 0.0 -w ${s} -h ${s} --file="${f}" --export-png="${OUTDIR}/${s}/${j}/$(basename -s .svg "${f}").png"
				done
				#inkscape -z -y 0.0 --file="${f}" --export-plain-svg="${OUTDIR}/scalable/${j}/$(basename "${f}")"
			done
		done
		#[ -d "${INDIR}/__symbolic" ] && cp -a "${INDIR}/__symbolic" "${OUTDIR}/symbolic"
		#if [ -d "${INDIR}/animations" ]; then
			#for sz in $(ls ${INDIR}/animations/); do
				#for f in ${INDIR}/animations/${sz}/*.svg; do
					#inkscape -z -y 0.0 -d 90 --file="${f}" --export-png="${OUTDIR}/${sz}/animations/$(basename -s .svg "${f}").png"
				#done
				#cp -a ${INDIR}/animations/${sz}/* ${OUTDIR}/${sz}/animations/
			#done
		#fi

		#fi ###!!

		for j in actions animations apps categories devices emblems mimetypes places status stock; do
			while read line; do
				for lnk in $(echo ${line} | cut -s -d' ' -f2-); do
					dirnm=$(echo ${lnk} | cut -s -d: -f1)
					if [ "$dirnm" ]; then
						trgt="../${j}/"
					else
						trgt=
						dirnm="${j}"
					fi
					for s in ${OUTSIZES}; do
						[ ! -d "${OUTDIR}/${s}/${j}" ] && continue
						ext=png
						#[ "$s" = "scalable" ] && ext=svg
						cd "${OUTDIR}/${s}/${j}"
						if [ -e "${line%% *}.${ext}" ]; then
							[ ! -e "${OUTDIR}/${s}/${dirnm}/${lnk#*:}.${ext}" ] && ln -s "${trgt}${line%% *}.${ext}" "${OUTDIR}/${s}/${dirnm}/${lnk#*:}.${ext}"
						else
							if [ -e "${CURDIR}/DESTDIR/Faience-ng/${s}/${dirnm}/${lnk#*:}.${ext}" -a ! -e "${OUTDIR}/${s}/${dirnm}/${lnk#*:}.${ext}" ]; then
								ln -s "../../../Faience-ng/${s}/${dirnm}/${lnk#*:}.${ext}" "${OUTDIR}/${s}/${dirnm}/${lnk#*:}.${ext}"
							else
								echo "WARNING: '${line%% *}.${ext}' not found. Skiping"
							fi
						fi
					done
				done
			done < "${CURDIR}/${j}.lst"
		done

		for j in actions animations apps categories devices emblems mimetypes places status stock; do
			for s in ${OUTSIZES}; do #scalable
				if [ -d "${CURDIR}/DESTDIR/Faience-ng/${s}/${j}" ]; then
					for f in "${CURDIR}/DESTDIR/Faience-ng/${s}/${j}"/*.png; do
						b=$(basename $f)
						if [ ! -L "$f" ]; then
							for theme in Faience-ng-Blue Faience-ng-Green Faience-ng-Dark; do
								if [ ! -e "${CURDIR}/DESTDIR/${theme}/${s}/${j}/${b}" ]; then
									ln -s "../../../Faience-ng/${s}/${j}/${b}" "${CURDIR}/DESTDIR/${theme}/${s}/${j}/${b}"
								fi
							done
						fi
					done
				fi
			done
		done

		#find ${OUTDIR} -type d -empty -delete
		cp "${INDIR}/index.theme" "${OUTDIR}/"
		dirs=""
		for s in ${OUTSIZES} scalable; do #symbolic scalable
			for j in actions apps categories devices emblems mimetypes places status stock; do
				[ ! -d "${OUTDIR}/${s}/${j}" ] && continue
				dirs+="${s}/${j},"
				echo >> "${OUTDIR}/index.theme"
				echo "[${s}/${j}]" >> "${OUTDIR}/index.theme"

				echo "Context=$(get_context ${j})" >> "${OUTDIR}/index.theme"
				if [ "${s}" = "scalable" ]; then
					echo "Size=16" >> "${OUTDIR}/index.theme"
					echo "MinSize=8" >> "${OUTDIR}/index.theme"
					echo "MaxSize=512" >> "${OUTDIR}/index.theme"
					echo "Type=Scalable" >> "${OUTDIR}/index.theme"
				elif [ "${s}" = "256x256" ]; then
					echo "Size=256" >> "${OUTDIR}/index.theme"
					echo "MinSize=8" >> "${OUTDIR}/index.theme"
					echo "MaxSize=512" >> "${OUTDIR}/index.theme"
					echo "Type=Scalable" >> "${OUTDIR}/index.theme"
				else
					echo "Size=${s##*x}" >> "${OUTDIR}/index.theme"
					echo "Type=Fixed" >> "${OUTDIR}/index.theme"
				fi
			done
		done
	sed -i "${OUTDIR}/index.theme" -e s#Directories=#Directories="${dirs}"#
	done
	;;
	check)
		for l in $(find -type l -xtype l); do echo "$l -> $(readlink -nq "$l")"; done
	;;
	clean)
		rm -rf ${CURDIR}/DESTDIR
	;;
	export)
		inkscape -z -y 0.0 --file="${2}" --export-png="${CURDIR}/$(basename -s .svg "${2}").png";;
	test)
		mkdir -p $HOME/.icons
		cd $HOME/.icons
		rm -f ./Faience-ng*
		for d in ${CURDIR}/DESTDIR/*; do
			[ ! -d "$d" ] && continue
			ln -s "$d"
			gtk-update-icon-cache -f $d/
		done
	;;
	rm)
		cd "${CURDIR}/$2"
		for dir in . "extra small" "small"; do
			cd "${CURDIR}/$2/$dir"
			if [ -L "$3.svg" ]; then
				rm "$3.svg"
				echo "$3.svg"
			fi
		done
	;;
	rmlns)
		find ${CURDIR}/DESTDIR/ -type l -delete
	;;
	symbolic)
		# Cook symbolic icons to colored
		theme=Faience-ng-Light #-Light
		varnum=3
		if [ $theme = "Faience-ng-Dark" ]; then
			varnum=2
		elif [ $theme = "Faience-ng-Light" ]; then
			varnum=1
		fi
		sizes="96 24 16"
		if [ -n "$2" ]; then
			sizes="$2"
		fi

		for g in $sizes; do
		case "$g" in
			96)
			[ "$theme" != "Faience-ng" ] && continue
			for subdir in $(ls ${CURDIR}/scalable-up-to-96 | egrep -v "categories|devices|apps|mimetypes" ); do
				mkdir -p ${CURDIR}/PREBUILD/${theme}/96x96/${subdir}
				SVGS=$(find ${CURDIR}/scalable-up-to-96/${subdir} -name "*.svg"  2>/dev/null | sort)
				for f in $SVGS; do
					if [ ! -f "${CURDIR}/PREBUILD/${theme}/96x96/${subdir}/$(basename ${f/-symbolic/})" ]; then
						echo "${CURDIR}/PREBUILD/${theme}/96x96/${subdir}/$(basename ${f/-symbolic/})"
						php -c $CURDIR/php.ini ./big.php "$f" "${CURDIR}/PREBUILD/${theme}/96x96/${subdir}"
						#exit 1
					fi
				done
			done
			;;
			16)
			for subdir in $(ls ${CURDIR}/scalable | egrep -v "categories|devices|apps|mimetypes"); do
				mkdir -p ${CURDIR}/PREBUILD/${theme}/16x16/${subdir}
				SVGS=$(find ${CURDIR}/scalable/${subdir} -name "*.svg"  2>/dev/null | sort)
				for f in $SVGS; do
					if [ ! -f "${CURDIR}/PREBUILD/${theme}/16x16/${subdir}/$(basename ${f/-symbolic/})" ]; then
						echo "${CURDIR}/PREBUILD/${theme}/16x16/${subdir}/$(basename ${f/-symbolic/})"
						php -c $CURDIR/php.ini ./icon.php $varnum "$f" "${CURDIR}/PREBUILD/${theme}/16x16/${subdir}"
						#exit 1
					fi
				done
			done
			;;
			24)
			for subdir in $(ls ${CURDIR}/scalable-up-to-24 | egrep -v "categories|devices|apps|mimetypes"); do
				mkdir -p ${CURDIR}/PREBUILD/${theme}/24x24/${subdir}
				SVGS=$(find ${CURDIR}/scalable-up-to-24/${subdir} -name "*.svg"  2>/dev/null | sort)
				for f in $SVGS; do
					if [ ! -f "${CURDIR}/PREBUILD/${theme}/24x24/${subdir}/$(basename ${f/-symbolic/})" ]; then
						echo "${CURDIR}/PREBUILD/${theme}/24x24/${subdir}/$(basename ${f/-symbolic/})"
						php -c $CURDIR/php.ini ./icon.php $varnum "$f" "${CURDIR}/PREBUILD/${theme}/24x24/${subdir}"
						#exit 1
					fi
				done
			done
			;;
		esac
		done
	;;
	dbls)
		rm -f ${CURDIR}/${2}.new
		for f in $(cat ${CURDIR}/${2}.lst); do
			echo "$f" >> ${2}.new
		done
		uniq -d ${2}.new
	;;
	grub)
		SVGS=$(find "$(dirname "$2")" -maxdepth 1 -name "*.svg")
		for f in $SVGS; do
			php ./grub.php "$f" "${CURDIR}/test"
		done
	;;
	to96)
		SVGS=$(find "$(dirname "$2")" -maxdepth 1 -name "*.svg")
		for f in $SVGS; do
			php ./to96.php "$f" "${CURDIR}/test"
		done
	;;
	fix)

		#rm ${CURDIR}/DESTDIR/Faience-ng/{16x16,22x22,24x24}/status/xfpm-ac-adapter.png
		#for f in 16x16 22x22 24x24; do
			#ln -s battery-full-charged.png ${CURDIR}/DESTDIR/Faience-ng/${f}/status/xfpm-ac-adapter.png
		#done
	;;
	go)
	#Cook PREBUILD svg's -> DESTDIR
	for theme in Faience-ng Faience-ng-Dark Faience-ng-Light Faience-ng-Blue Faience-ng-Green; do
		INDIR="${CURDIR}/PREBUILD/${theme}"
		OUTDIR="${CURDIR}/DESTDIR/${theme}"
		mkdir -p "${OUTDIR}"

		for g in ${OUTSIZES}; do
		g=${g#*x}
		case "${g}" in
			16)
				i="${g}x${g}"
				for j in actions apps categories devices emblems mimetypes places status; do
					if [ -d "${INDIR}/${i}/${j}/" ]; then
						mkdir -p ${OUTDIR}/${i}/${j}
						for f in ${INDIR}/${i}/${j}/*.svg; do
							fname=$(basename -s .svg "${f}")
							inkscape -z -y 0.0 -w 16 -h 16 --file="${f}" --export-png="${OUTDIR}/${i}/${j}/${fname}.png" # -d 90
						done
					fi
				done
				;;
			22|24)
				i="${g}x${g}"
				for j in actions apps categories devices emblems mimetypes places status; do
					if [ -d "${INDIR}/24x24/${j}/" ]; then
						mkdir -p ${OUTDIR}/22x22/${j} ${OUTDIR}/24x24/${j}
						for f in ${INDIR}/24x24/${j}/*.svg; do
							[ ! -f "$f" ] && continue
							fname=$(basename -s .svg "${f}")
							#size=$(identify "${f}" | cut -d\   -f3 | cut -dx -f1)
							size=$(grep -Po -m1 'width="[\d]+"' "${f}" | cut -d'"' -f2)
							if [ "$size" = "22" ]; then
								inkscape -z -y 0.0 -w 22 -h 22 --file="${f}" --export-png="${OUTDIR}/22x22/${j}/${fname}.png"
								inkscape -z -y 0.0 -w 24 -h 24 --export-area=-1:-1:23:23 --file="${f}" --export-png="${OUTDIR}/24x24/${j}/${fname}.png"
							elif [ "$size" = "24" ]; then
								inkscape -z -y 0.0 -w 22 -h 22 --export-area=1:1:23:23 --file="${f}" --export-png="${OUTDIR}/22x22/${j}/${fname}.png"
								inkscape -z -y 0.0 -w 24 -h 24 --file="${f}" --export-png="${OUTDIR}/24x24/${j}/${fname}.png"
							else
								echo "ERROR____________$size_____________________"
								exit
							fi
						done
					fi
				done
			;;
			32|48|64|96|128|256|512)
				for j in actions apps categories devices emblems mimetypes places status; do
					if [ -d "${INDIR}/96x96/${j}/" ]; then
						mkdir -p ${OUTDIR}/${g}x${g}/${j}
						for f in ${INDIR}/96x96/${j}/*.svg; do
							[ ! -f "$f" ] && continue
							fname=$(basename -s .svg "${f}")
							inkscape -z -y 0.0 -w ${g} -h ${g} --file="${f}" --export-png="${OUTDIR}/${g}x${g}/${j}/${fname}.png"
						done
					fi
				done
			;;
			*)
				echo "ERROR: wrong value '${g}'"
				continue
			#exit 1;
			;;
		esac
		done
	done
	;;
	*)
		echo "ERROR: unknown command"
	;;
esac

# Xvfb :1 -screen 0 640x480x24 -fbdir /var/tmp&
# export DISPLAY=:1.0
# https://habrahabr.ru/post/113928/
# https://habrahabr.ru/sandbox/20989/
# Формируем список симлинков в главной Faience-ng.
# Расставляем ссылки не допуская ссылок на ссылки
# grep -rl "style" ./scalable/ | sort

# Get list of Adwaita symbolic icons
#find /usr/share/icons/Adwaita/scalable -name "*-symbolic*" | sed 's|/usr/share/icons/Adwaita/||' | sort > adwaita.list
#find scalable -name "*-symbolic*" | sort > scalable.list
#comm -13 ./scalable.list ./adwaita.list

# grep -rl "style" ./scalable*/ |  xargs  sed -Ei 's/ style="[^"]*"//'
# grep -rl "<svg " ./scalable/ |  xargs  sed -Ei 's|<svg [^\>]+>|<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">|'
# grep -rl "<svg " ./scalable-up-to-24/ |  xargs  sed -Ei 's|<svg [^\>]+>|<svg width="22" height="22" version="1.1" xmlns="http://www.w3.org/2000/svg">|'
# grep -rl "<svg " ./scalable-up-to-96/ |  xargs  sed -Ei 's|<svg [^\>]+>|<svg width="96" height="96" version="1.1" xmlns="http://www.w3.org/2000/svg">|'
# grep -rl "<path " ./scalable*/ | xargs   sed -Ei 's|^<path|\t<path|'
# grep -rl " id=" ./scalable*/ |  xargs  sed -Ei 's/ id="[^"]*"//'
# grep -rl "<?xml" ./scalable*/ | xargs sed -Ei 's|<\?xml [^\>]+>||'
# find . -name "*.lst" -exec md5sum {} \;
