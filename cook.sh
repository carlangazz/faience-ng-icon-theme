#!/bin/bash

readonly CURDIR="$(dirname $(readlink -f "$0"))"


xorg_background() {
	mv $HOME/.config/inkscape/preferences.xml $HOME/.config/inkscape/preferences.xml_
	if command -v Xvfb &>/dev/null; then
		Xvfb :1 -screen 0 640x480x24 -fbdir /var/tmp &
		xorgpid="$!"
		trap "kill $xorgpid && mv $HOME/.config/inkscape/preferences.xml_ $HOME/.config/inkscape/preferences.xml" EXIT
		export DISPLAY=:1.0
		:
	else
		echo "Xvfb is missing in your system"
	fi
}


make_theme_index() {
	local theme="$1"
	local types="$2"
	OUTDIR="${CURDIR}/DESTDIR/${theme}"
	mkdir -p $OUTDIR
	cp "${CURDIR}/themes/${theme}/index.theme" "${OUTDIR}/"
	dirs=""

	for size in ${OUTSIZES}; do
		mkdir -p ${OUTDIR}/${size}x${size}/
		for type in $types; do
			[ -d ${CURDIR}/DESTDIR/Faience-ng/${type}/${size}x${size} ] || continue
			find ${CURDIR}/DESTDIR/Faience-ng/${type}/${size}x${size}/ -type f -name "*.png" | while read line; do
				filename="$(basename $line)"
				[ -e ${OUTDIR}/${size}x${size}/${filename} ] && continue
				ln -s ../../Faience-ng/${type}/${size}x${size}/${filename} ${OUTDIR}/${size}x${size}/${filename}
			done
			echo $theme $type $size

			cat "${CURDIR}/symlinks.lst" | while read line; do
				filename="${line%% *}.png"
				#[ -e ${OUTDIR}/${size}x${size}/${filename} ] && continue

				cd ${OUTDIR}/${size}x${size}

				if [ -f "${CURDIR}/DESTDIR/Faience-ng/${type}/${size}x${size}/${filename}" ]; then
					for lnk in ${line#* }; do
						if [ ! -f ${CURDIR}/DESTDIR/${theme}/${size}x${size}/${lnk}.png ]; then
							ln -s ../../Faience-ng/${type}/${size}x${size}/${filename} ${lnk}.png
						fi
					done
				fi
			done
		done
	done
	ln -s ../Faience-ng/symbolic $OUTDIR

	#for type in $types; do
		cd $OUTDIR
		for size in ${OUTSIZES}; do
			d="${size}x${size}"
			[ ! -d "${OUTDIR}/${d}" ] && continue
			dirs+="${d},"
			echo >> "${OUTDIR}/index.theme"
			echo "[${d}]" >> "${OUTDIR}/index.theme"
			#if [ "${size}" = 256 ]; then
			#	echo "Size=256" >> "${OUTDIR}/index.theme"
			#	echo "MinSize=8" >> "${OUTDIR}/index.theme"
			#	echo "MaxSize=512" >> "${OUTDIR}/index.theme"
			#	echo "Type=Scalable" >> "${OUTDIR}/index.theme"
			#else
				echo "Size=${size}" >> "${OUTDIR}/index.theme"
				echo "Type=Fixed" >> "${OUTDIR}/index.theme"
			#fi
		done
		d="symbolic"
		dirs+="${d},"
		echo >> "${OUTDIR}/index.theme"
		echo "[${d}]" >> "${OUTDIR}/index.theme"
		echo "Size=16" >> "${OUTDIR}/index.theme"
		echo "MinSize=8" >> "${OUTDIR}/index.theme"
		echo "MaxSize=512" >> "${OUTDIR}/index.theme"
		echo "Type=Scalable" >> "${OUTDIR}/index.theme"
	#done
	sed -i "${OUTDIR}/index.theme" -e s#Directories=#Directories="${dirs}"#
}



OUTSIZES="8 16 22 24 32 48 256" #


case $1 in
	check-scalable)
		mkdir -p "${CURDIR}/DESTDIR/Faience-ng/symbolic"
		cd "${CURDIR}/scalable-up-to-16/"
		while read file; do
			if [ ! -f "${file%% *}" ]; then
				echo "Missing: ${file%% *}"
			else
				cp --parents "${file%% *}" "${CURDIR}/DESTDIR/Faience-ng/symbolic/"
				for f in ${file#* }; do
					ln -s "../${file%% *}" "${CURDIR}/DESTDIR/Faience-ng/symbolic/${f}"
				done
			fi
		done < "${CURDIR}/scalable.lst"
		cd "${CURDIR}"
	;;
	test)
		mkdir -p $HOME/.icons
		cd $HOME/.icons
		rm -f ./Faience-ng*
		for d in ${CURDIR}/DESTDIR/*; do
			[ ! -d "$d" ] && continue
			ln -s "$d"
			gtk-update-icon-cache -fi $d/
		done
        gsettings set org.gnome.desktop.interface icon-theme Faience-ng-Mono
		if command -v xfconf-query &>/dev/null; then
			xfconf-query -c xsettings -p /Net/IconThemeName -s Faience-ng-Mono
			xfconf-query -c xsettings -p /Gtk/IconSizes -s "panel-menu=24,24:panel=24,24:gtk-button=16,16:gtk-large-toolbar=24,24"
		fi
	;;
	release)
		VERSION=$(git show -s --format=%cd --date=format:%Y%m%d HEAD)
		#git tag -f $VERSION
		#git push origin --tags
		ln -fs DESTDIR ${CURDIR}/faience-ng-icon-theme
		cd faience-ng-icon-theme
		tar -acf ../faience-ng-icon-theme-${VERSION}.tar.gz *
		rm ${CURDIR}/faience-ng-icon-theme
	;;
	png)
		inkscape -z -d 96 -y 0.0 --file="${2}" --export-png="$CURDIR/$(basename -s .svg ${2}).png"
	;;
	all)
		$0 step1
		$0 step2
		$0 step3
		$0 step4
		$0 test
	;;
	rename)
		sed -e 's|Icon=.*|Icon=fceux|' -i /usr/share/applications/fceux.desktop
		sed -e 's|Icon=.*|Icon=hardinfo|' -i /usr/share/applications/hardinfo.desktop
		sed -e 's|Icon=.*|Icon=hp_logo|' -i /usr/share/applications/hplip.desktop
		sed -e 's|Icon=.*|Icon=guvcview|' -i /usr/share/applications/guvcview.desktop
		sed -e 's|Icon=.*|Icon=gcolor2|' -i /usr/share/applications/gcolor2.desktop
	;;
	step1)
		# Шаг первый: Преобразовываем symbolic в градиентные actions\status
		# Преобразовываются только новые или измененные
		# Запускаем в фоне
		xorg_background

		for theme in dark light; do
			OUTDIR="${CURDIR}/PREBUILD/symbolic/${theme}"
			for size in 16 24; do
				[ ! -d "${CURDIR}/scalable-up-to-${size}/" ] && continue
				files=$(find ${CURDIR}/scalable-up-to-${size} -name "*.svg" 2>/dev/null | sort)
				for file in $files; do
					outfile="${OUTDIR}/${size}x${size}/$(basename ${file})"
					outfile=${outfile/-symbolic-rtl.svg/-rtl.svg}
					outfile=${outfile/-symbolic.svg/.svg}
					if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
						mkdir -p "${OUTDIR}/${size}x${size}"
						echo "$outfile"
						php -c $CURDIR/php.ini ./icon.php "$theme" "$file" "$outfile"
					fi
				done
			done
		done
		# 96x96
		theme=light
		size=96
		OUTDIR="${CURDIR}/PREBUILD/symbolic/${theme}"
		[ ! -d "${CURDIR}/scalable-up-to-${size}" ] && continue
		files=$(find ./scalable-up-to-${size} -name "*.svg" 2>/dev/null | sort)
		for file in $files; do
			outfile="${OUTDIR}/${size}x${size}/$(basename ${file})"
			outfile=${outfile/-symbolic-rtl.svg/-rtl.svg}
			outfile=${outfile/-symbolic.svg/.svg}
			if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
				mkdir -p "${OUTDIR}/${size}x${size}"
				echo "$outfile"
				php -c $CURDIR/php.ini ./big.php "$file" "$outfile"
			fi
		done

		# Удаляем удаленные
		for theme in dark light; do
			#OUTDIR="${CURDIR}/PREBUILD/symbolic/${theme}"
			for size in 16 24 96; do
				if [ -d "${CURDIR}/PREBUILD/symbolic/${theme}/${size}x${size}/" ]; then
					cd "${CURDIR}/PREBUILD/symbolic/${theme}/${size}x${size}/"
					for file in $(find . -name "*.svg" 2>/dev/null | sort); do
						f=${file/.svg/-symbolic.svg}
						f=${f/-rtl-symbolic.svg/-symbolic-rtl.svg}
						if [ ! -f "${CURDIR}/scalable-up-to-${size}/${f}" ]; then
							echo "$f"
							echo "rm: ${CURDIR}/PREBUILD/symbolic/${theme}/${size}x${size}/${file}"
							rm "${CURDIR}/PREBUILD/symbolic/${theme}/${size}x${size}/${file}"
						fi
					done
				fi
			done
		done
	;;
	step2)
		# Преобразовываем градиентные svg в png
		for theme in dark light; do
			INDIR="${CURDIR}/PREBUILD/symbolic/${theme}"
			OUTDIR="${CURDIR}/PREBUILD/png/symbolic/${theme}"
			mkdir -p "${OUTDIR}"
			for size in ${OUTSIZES}; do
				case "$size" in
					16)
						if [ -d "${INDIR}/${size}x${size}/" ]; then
							mkdir -p ${OUTDIR}/${size}x${size}/
							for file in ${INDIR}/${size}x${size}/*.svg; do
								outfile="${OUTDIR}/${size}x${size}/$(basename -s .svg "${file}").png"
								if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
									inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
								fi
							done
						fi
						# Удаляем удаленные
						if [ -d "${OUTDIR}/${size}x${size}" ]; then
							cd "${OUTDIR}/${size}x${size}"
							for file in $(find . -name "*.png" 2>/dev/null | sort); do
								f=${file/.png/.svg}
								if [ ! -f "${INDIR}/${size}x${size}/${f}" ]; then
									echo "rm: ${OUTDIR}/${size}x${size}/${file}"
									rm "${OUTDIR}/${size}x${size}/${file}"
								fi
							done
						fi
					;;
					22)
						if [ -d "${INDIR}/24x24/" ]; then
							mkdir -p ${OUTDIR}/${size}x${size}
							for file in ${INDIR}/24x24/*.svg; do
								outfile="${OUTDIR}/22x22/$(basename -s .svg "${file}").png"
								if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
									inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
								fi
							done
						fi
						# Удаляем удаленные
						if [ -d "${OUTDIR}/${size}x${size}" ]; then
							cd "${OUTDIR}/${size}x${size}"
							for file in $(find . -name "*.png" 2>/dev/null | sort); do
								f=${file/.png/.svg}
								if [ ! -f "${INDIR}/24x24/${f}" ]; then
									echo "rm: ${OUTDIR}/${size}x${size}/${file}"
									rm "${OUTDIR}/${size}x${size}/${file}"
								fi
							done
						fi
					;;
					24)
						if [ -d "${INDIR}/${size}x${size}/" ]; then
							mkdir -p ${OUTDIR}/${size}x${size}
							for file in ${INDIR}/${size}x${size}/*.svg; do
								outfile="${OUTDIR}/${size}x${size}/$(basename -s .svg "${file}").png"
								if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
									inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --export-area=-1:-1:23:23 --file="${file}" --export-png="$outfile"
								fi
							done
						fi
						# Удаляем удаленные
						if [ -d "${OUTDIR}/${size}x${size}" ]; then
							cd "${OUTDIR}/${size}x${size}"
							for file in $(find . -name "*.png" 2>/dev/null | sort); do
								f=${file/.png/.svg}
								if [ ! -f "${INDIR}/${size}x${size}/${f}" ]; then
									echo "rm: ${OUTDIR}/${size}x${size}/${file}"
									rm "${OUTDIR}/${size}x${size}/${file}"
								fi
							done
						fi
					;;
					32|48|64|96|128|256|512)
						if [ -d "${INDIR}/96x96/" ]; then
							mkdir -p ${OUTDIR}/${size}x${size}
							for file in ${INDIR}/96x96/*.svg; do
								outfile="${OUTDIR}/${size}x${size}/$(basename -s .svg "${file}").png"
								if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
									inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
								fi
							done
						fi
						# Удаляем удаленные
						if [ -d "${OUTDIR}/${size}x${size}" ]; then
							cd "${OUTDIR}/${size}x${size}"
							for file in $(find . -name "*.png" 2>/dev/null | sort); do
								f=${file/.png/.svg}
								if [ ! -f "${INDIR}/96x96/${f}" ]; then
									echo "rm: ${OUTDIR}/${size}x${size}/${file}"
									rm "${OUTDIR}/${size}x${size}/${file}"
								fi
							done
						fi
					;;
				esac
			done
		done
	;;
	step3)
		#Рендерим иконки, нарисованные вручную
		for theme in dark light folders-blue folders-green folders-default pool; do
			INDIR="${CURDIR}/SRC/${theme}"
			OUTDIR="${CURDIR}/PREBUILD/png/drawed/$theme"
			mkdir -p "${OUTDIR}"
			for size in ${OUTSIZES}; do
				case "$size" in
					16)
						if [ -d "${INDIR}/${size}x${size}/" ]; then
							mkdir -p ${OUTDIR}/${size}x${size}
							for file in ${INDIR}/${size}x${size}/*.svg; do
								[ ! -f "$file" ] && continue
								outfile="${OUTDIR}/${size}x${size}/$(basename -s .svg "${file}").png"
								if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
									inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
								fi
							done
						fi
					;;
					22)
						if [ -d "${INDIR}/24x24/" ]; then
							mkdir -p ${OUTDIR}/${size}x${size}
							for file in ${INDIR}/24x24/*.svg; do
								[ ! -f "$file" ] && continue
								outfile="${OUTDIR}/22x22/$(basename -s .svg "${file}").png"
								if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
									rsize=$(grep -Po -m1 'width="[\d]+"' "${file}" | cut -d'"' -f2)
									if [ "$rsize" = "22" ]; then
										inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
									elif [ "$rsize" = "24" ]; then
										inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --export-area=1:1:23:23 --file="${file}" --export-png="$outfile"
									else
										echo "ERROR_________________________________"
										exit 1
									fi
								fi
							done
						fi
					;;
					24)
						if [ -d "${INDIR}/${size}x${size}/" ]; then
							mkdir -p ${OUTDIR}/${size}x${size}
							for file in ${INDIR}/${size}x${size}/*.svg; do
								[ ! -f "$file" ] && continue
								outfile="${OUTDIR}/${size}x${size}/$(basename -s .svg "${file}").png"
								if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
									rsize=$(grep -Po -m1 'width="[\d]+"' "${file}" | cut -d'"' -f2)
									if [ "$rsize" = "22" ]; then
										inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --export-area=-1:-1:23:23 --file="${file}" --export-png="$outfile"
									elif [ "$rsize" = "24" ]; then
										inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
									else
										echo "ERROR_________________________________"
										exit 1
									fi
								fi
							done
						fi
					;;
					32|48|64|96|128|256|512)
						if [ -d "${INDIR}/96x96/" ]; then
							mkdir -p ${OUTDIR}/${size}x${size}
							for file in ${INDIR}/96x96/*.svg; do
								filename=$(basename -s .svg "${file}")
								outfile="${OUTDIR}/${size}x${size}/${filename}.png"
								if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
									inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
								fi
							done
						fi
						# Удаляем удаленные
						if [ -d "${OUTDIR}/${size}x${size}" ]; then
							cd "${OUTDIR}/${size}x${size}"
							for file in $(find . -name "*.png" 2>/dev/null | sort); do
								f=${file/.png/.svg}
								if [ ! -f "${INDIR}/96x96/${f}" ]; then
									echo "rm: ${OUTDIR}/${size}x${size}/${file}"
									rm "${OUTDIR}/${size}x${size}/${file}"
								fi
							done
						fi
					;;
				esac

				# Рисуем которые есть в 96, но нет в $size
				if [ "${theme}" = "pool" ]; then
				case "$size" in
					16|22|24)
						if [ -d "${OUTDIR}/${size}x${size}" -a -d "${INDIR}/96x96/" ]; then
							#mkdir -p ${OUTDIR}/${size}x${size}
							for file in ${INDIR}/96x96/*.svg; do
								filename=$(basename -s .svg "${file}")
								outfile="${OUTDIR}/${size}x${size}/${filename}.png"
								if [ ! -f "${CURDIR}/PREBUILD/png/symbolic/light/24x24/${filename}.png" ]; then
									if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
										inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
									fi
								fi
							done
						fi
						# Удаляем удаленные
						if [ -d "${OUTDIR}/${size}x${size}" ]; then
							cd "${OUTDIR}/${size}x${size}"
							for file in $(find . -name "*.png" 2>/dev/null | sort); do
								f=${file/.png/.svg}
								if [ ! -f "${INDIR}/96x96/${f}" -a ! -f "${INDIR}/${size}x${size}/${f}" ]; then
									echo "rm: ${OUTDIR}/${size}x${size}/${file}"
									rm "${OUTDIR}/${size}x${size}/${file}"
								fi
							done
						fi
					;;
				esac
				fi
			done
		done
	;;
	step4)
		rm -rf "${CURDIR}/DESTDIR"
		OUTDIR="${CURDIR}/DESTDIR/Faience-ng"
		mkdir -p "${OUTDIR}"
		for theme in pool folders-default folders-blue folders-green light dark; do
			dir="${CURDIR}/PREBUILD/png/drawed/${theme}"
			if [ -d ${dir} ]; then
				cp -r "${CURDIR}/PREBUILD/png/drawed/${theme}" "${OUTDIR}/"
			fi
		done

		for theme in light dark; do
			dir="${CURDIR}/PREBUILD/png/symbolic/${theme}"
			if [ -d ${dir} ]; then
				cp -r "${CURDIR}/PREBUILD/png/symbolic/${theme}" "${OUTDIR}/"
			fi
		done

		# Здесь будем копировать symbolic
		mkdir -p "${CURDIR}/DESTDIR/Faience-ng/symbolic"
		cd "${CURDIR}/scalable-up-to-16/"
		while read file; do
			if [ ! -f "${file%% *}" ]; then
				echo "Missing: ${file%% *}"
			else
				cp --parents "${file%% *}" "${CURDIR}/DESTDIR/Faience-ng/symbolic/"
				for f in ${file#* }; do
					if [ ! -f "${CURDIR}/DESTDIR/Faience-ng/symbolic/${f}" ]; then
						ln -s "${file%% *}" "${CURDIR}/DESTDIR/Faience-ng/symbolic/${f}"
					fi
				done
			fi
		done < "${CURDIR}/scalable.lst"
		cd "${CURDIR}"


		cp "${CURDIR}/themes/Faience-ng/index.theme" "${CURDIR}/DESTDIR/Faience-ng/"

		make_theme_index "Faience-ng-Default" "folders-default pool light"
		make_theme_index "Faience-ng-Dark" "folders-default pool dark light"
		make_theme_index "Faience-ng-Blue" "folders-blue pool light"
		make_theme_index "Faience-ng-Green" "folders-green pool light"
		make_theme_index "Faience-ng-Dark-Blue" "folders-blue pool dark light"
		make_theme_index "Faience-ng-Dark-Green" "folders-green pool dark light"
		make_theme_index "Faience-ng-Mono" "light pool folders-default"
		make_theme_index "Faience-ng-Mono-Dark" "dark light pool folders-default"
		make_theme_index "Faience-ng-Mono-Blue" "light pool folders-blue"
		make_theme_index "Faience-ng-Mono-Green" "light pool folders-green"
		make_theme_index "Faience-ng-Mono-Dark-Blue" "dark light pool folders-blue"
		make_theme_index "Faience-ng-Mono-Dark-Green" "dark light pool folders-green"


	;;
	to96)
		xorg_background

		mkdir -p ${CURDIR}/scalable-up-to-32

		for i in avatar-default gtk-info indicator-messages-new indicator-messages \
			locked lock mail-forward mail-mark-important mail-message-new mail-reply-all \
			mail-reply-sender network-offline network-transmit-receive new-messages-red \
			package-install package-remove package-upgrade system-lock-screen system-reboot \
			system-restart-panel system-shutdown-panel; do
				rm ${CURDIR}/scalable-up-to-96/${i}-symbolic.svg
		done

		for i in display-brightness changes-prevent changes-allow system-restart network-wired network-wired-disconnected; do
			echo ${i}
			php -c $CURDIR/php.ini ./to96.php "${CURDIR}/scalable-up-to-16/${i}-symbolic.svg" "${CURDIR}/scalable-up-to-32/${i}-symbolic.svg"
		done

		for f in ${CURDIR}/scalable-up-to-96/*.svg; do
			file=$(basename $f .svg)
			if [ ! -f ${CURDIR}/scalable-up-to-32/${file}.svg -a -f ${CURDIR}/scalable-up-to-16/${file}.svg -a ! -f ${CURDIR}/SRC/pool/96x96/${file/-symbolic/}.svg ]; then
				echo $file
				php -c $CURDIR/php.ini ./to96.php "${CURDIR}/scalable-up-to-16/${file}.svg" "${CURDIR}/scalable-up-to-32/${file}.svg"
			else
				echo "$file"
			fi
		done

		exit

		for file in $(cat ${CURDIR}/to96.lst); do
			if [ ! -f ${CURDIR}/scalable-up-to-32/${file}.svg -a -f ${CURDIR}/scalable-up-to-16/${file}.svg -a ! -f ${CURDIR}/SRC/pool/96x96/${file/-symbolic/}.svg ]; then
				echo $file
				php -c $CURDIR/php.ini ./to96.php "${CURDIR}/scalable-up-to-16/${file}.svg" "${CURDIR}/scalable-up-to-32/${file}.svg"
			fi
		done
	;;
	*)
		echo "ERROR: unknown command"
	;;
esac

#find /usr/share/icons/Adwaita/scalable -name "*-symbolic*" | sed -e 's|/usr/share/icons/Adwaita/scalable/||' -e 's|/| |' -e 's|.svg||' | sort > scalable.lst
#find /usr/share/icons/Adwaita/scalable -name "*-symbolic*" | sed -e 's|/usr/share/icons/Adwaita/scalable/||'  | sort > scalable.lst
