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

OUTSIZES="8 16 22 24 32 48 256" #256

#@TODO: Удаление удаленных вариантов

case $1 in
	step1)
		# Шаг первый: Преобразовываем symbolic в градиентные actions\status
		# Преобразовываются только новые или измененные
		# Запускаем в фоне
		if command -v Xvfb &>/dev/null; then
			Xvfb :1 -screen 0 640x480x24 -fbdir /var/tmp &
			#xorgpid="$!"
			trap "kill $!" EXIT
			export DISPLAY=:1.0
		else
			echo "Xvfb is missing in your system"
		fi
		for theme in Faience-ng Faience-ng-Light Faience-ng-Dark; do
			OUTDIR="${CURDIR}/PREBUILD/symbolic/${theme}"
			for size in 16 24; do
				for type in actions places status; do
					[ ! -d "${CURDIR}/scalable-up-to-${size}/${type}" ] && continue
					if [ "$type" = "places" ]; then
						files=$(find ${CURDIR}/scalable-up-to-${size}/${type} -name "*.svg" 2>/dev/null | egrep "^start" | sort)
					else
						files=$(find ${CURDIR}/scalable-up-to-${size}/${type} -name "*.svg" 2>/dev/null | sort)
					fi
					for file in $files; do
						outfile="${OUTDIR}/${size}x${size}/${type}/$(basename ${file/-symbolic/})"
						if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
							mkdir -p "${OUTDIR}/${size}x${size}/${type}"
							echo "$outfile"
							php -c $CURDIR/php.ini ./icon.php "$theme" "$file" "${OUTDIR}/${size}x${size}/${type}"
						fi
					done
				done
			done
		done
		# 96x96
		theme=Faience-ng
		size=96
		OUTDIR="${CURDIR}/PREBUILD/symbolic/${theme}"
		for type in actions places status; do
			[ ! -d "${CURDIR}/scalable-up-to-${size}/${type}" ] && continue
			files=$(find ./scalable-up-to-${size}/${type} -name "*.svg" 2>/dev/null | sort)
			for file in $files; do
				outfile="${OUTDIR}/${size}x${size}/${type}/$(basename ${file/-symbolic/})"
				if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
					mkdir -p "${OUTDIR}/${size}x${size}/${type}"
					echo "$outfile"
					php -c $CURDIR/php.ini ./big.php "$file" "${OUTDIR}/${size}x${size}/${type}"
				fi
			done
		done

		# Удаляем удаленные
		for theme in Faience-ng Faience-ng-Light Faience-ng-Dark; do
			#OUTDIR="${CURDIR}/PREBUILD/symbolic/${theme}"
			for size in ${OUTSIZES}; do
				if [ -d "${CURDIR}/PREBUILD/symbolic/${theme}/${size}x${size}/" ]; then
					cd "${CURDIR}/PREBUILD/symbolic/${theme}/${size}x${size}/"
					for file in $(find . -name "*.svg" 2>/dev/null | sort); do
						f=${file/.svg/-symbolic.svg}
						f=${f/-rtl-symbolic/-symbolic-rtl}
						if [ ! -f "${CURDIR}/scalable-up-to-${size}/${f}" ]; then
							echo "rm: ${CURDIR}/PREBUILD/symbolic/${theme}/${size}x${size}/${file}"
							rm "${CURDIR}/PREBUILD/symbolic/${theme}/${size}x${size}/${file}"
						fi
					done
				fi
			done
		done
		#kill $xorgpid
	;;
	step2)
		# Преобразовываем градиентные svg в png
		for theme in Faience-ng Faience-ng-Dark Faience-ng-Light; do
			INDIR="${CURDIR}/PREBUILD/symbolic/${theme}"
			OUTDIR="${CURDIR}/PREBUILD/png/symbolic/${theme}"
			mkdir -p "${OUTDIR}"
			for type in actions places status; do
				for size in ${OUTSIZES}; do
					case "$size" in
						16)
							if [ -d "${INDIR}/${size}x${size}/${type}/" ]; then
								mkdir -p ${OUTDIR}/${size}x${size}/${type}
								for file in ${INDIR}/${size}x${size}/${type}/*.svg; do
									outfile="${OUTDIR}/${size}x${size}/${type}/$(basename -s .svg "${file}").png"
									if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
										inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
									fi
								done
							fi
							# Удаляем удаленные
							if [ -d "${OUTDIR}/${size}x${size}/${type}" ]; then
								cd "${OUTDIR}/${size}x${size}/${type}"
								for file in $(find . -name "*.png" 2>/dev/null | sort); do
									f=${file/.png/.svg}
									if [ ! -f "${INDIR}/${size}x${size}/${type}/${f}" ]; then
										echo "rm: ${OUTDIR}/${size}x${size}/${type}/${file}"
										rm "${OUTDIR}/${size}x${size}/${type}/${file}"
									fi
								done
							fi
						;;
						22)
							if [ -d "${INDIR}/24x24/${type}/" ]; then
								mkdir -p ${OUTDIR}/${size}x${size}/${type}
								for file in ${INDIR}/24x24/${type}/*.svg; do
									outfile="${OUTDIR}/22x22/${type}/$(basename -s .svg "${file}").png"
									if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
										inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
									fi
								done
							fi
							# Удаляем удаленные
							if [ -d "${OUTDIR}/${size}x${size}/${type}" ]; then
								cd "${OUTDIR}/${size}x${size}/${type}"
								for file in $(find . -name "*.png" 2>/dev/null | sort); do
									f=${file/.png/.svg}
									if [ ! -f "${INDIR}/24x24/${type}/${f}" ]; then
										echo "rm: ${OUTDIR}/${size}x${size}/${type}/${file}"
										rm "${OUTDIR}/${size}x${size}/${type}/${file}"
									fi
								done
							fi
						;;
						24)
							if [ -d "${INDIR}/${size}x${size}/${type}/" ]; then
								mkdir -p ${OUTDIR}/${size}x${size}/${type}
								for file in ${INDIR}/${size}x${size}/${type}/*.svg; do
									outfile="${OUTDIR}/${size}x${size}/${type}/$(basename -s .svg "${file}").png"
									if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
										inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --export-area=-1:-1:23:23 --file="${file}" --export-png="$outfile"
									fi
								done
							fi
							# Удаляем удаленные
							if [ -d "${OUTDIR}/${size}x${size}/${type}" ]; then
								cd "${OUTDIR}/${size}x${size}/${type}"
								for file in $(find . -name "*.png" 2>/dev/null | sort); do
									f=${file/.png/.svg}
									if [ ! -f "${INDIR}/${size}x${size}/${type}/${f}" ]; then
										echo "rm: ${OUTDIR}/${size}x${size}/${type}/${file}"
										rm "${OUTDIR}/${size}x${size}/${type}/${file}"
									fi
								done
							fi
						;;
						32|48|64|96|128|256|512)
							if [ -d "${INDIR}/96x96/${type}/" ]; then
								mkdir -p ${OUTDIR}/${size}x${size}/${type}
								for file in ${INDIR}/96x96/${type}/*.svg; do
									outfile="${OUTDIR}/${size}x${size}/${type}/$(basename -s .svg "${file}").png"
									if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
										inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
									fi
								done
							fi
							# Удаляем удаленные
							if [ -d "${OUTDIR}/${size}x${size}/${type}" ]; then
								cd "${OUTDIR}/${size}x${size}/${type}"
								for file in $(find . -name "*.png" 2>/dev/null | sort); do
									f=${file/.png/.svg}
									if [ ! -f "${INDIR}/96x96/${type}/${f}" ]; then
										echo "rm: ${OUTDIR}/${size}x${size}/${type}/${file}"
										rm "${OUTDIR}/${size}x${size}/${type}/${file}"
									fi
								done
							fi
						;;
					esac
				done
			done
		done
	;;
	step3)
		#Рендерим иконки, нарисованные вручную
		for theme in Faience-ng Faience-ng-Dark Faience-ng-Light Faience-ng-Blue Faience-ng-Green; do # Faience-ng-Light-Blue Faience-ng-Light-Green Faience-ng-Dark-Blue Faience-ng-Dark-Green
			INDIR="${CURDIR}/${theme}"
			OUTDIR="${CURDIR}/PREBUILD/png/drawed/$theme"
			mkdir -p "${OUTDIR}"
			for type in actions apps categories devices emblems mimetypes places status; do
				for size in ${OUTSIZES}; do
					case "$size" in
						16)
							if [ -d "${INDIR}/${size}x${size}/${type}/" ]; then
								mkdir -p ${OUTDIR}/${size}x${size}/${type}
								for file in ${INDIR}/${size}x${size}/${type}/*.svg; do
									[ ! -f "$file" ] && continue
									outfile="${OUTDIR}/${size}x${size}/${type}/$(basename -s .svg "${file}").png"
									if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
										inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
									fi
								done
							fi
							# Удаляем удаленные
							if [ -d "${OUTDIR}/${size}x${size}/${type}" ]; then
								cd "${OUTDIR}/${size}x${size}/${type}"
								for file in $(find . -name "*.png" 2>/dev/null | sort); do
									f=${file/.png/.svg}
									if [ ! -f "${INDIR}/${size}x${size}/${type}/${f}" ]; then
										echo "rm: ${OUTDIR}/${size}x${size}/${type}/${file}"
										rm "${OUTDIR}/${size}x${size}/${type}/${file}"
									fi
								done
							fi
						;;
						22)
							if [ -d "${INDIR}/24x24/${type}/" ]; then
								mkdir -p ${OUTDIR}/${size}x${size}/${type}
								for file in ${INDIR}/24x24/${type}/*.svg; do
									[ ! -f "$file" ] && continue
									outfile="${OUTDIR}/22x22/${type}/$(basename -s .svg "${file}").png"
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
							# Удаляем удаленные
							if [ -d "${OUTDIR}/${size}x${size}/${type}" ]; then
								cd "${OUTDIR}/${size}x${size}/${type}"
								for file in $(find . -name "*.png" 2>/dev/null | sort); do
									f=${file/.png/.svg}
									if [ ! -f "${INDIR}/24x24/${type}/${f}" ]; then
										echo "rm: ${OUTDIR}/${size}x${size}/${type}/${file}"
										rm "${OUTDIR}/${size}x${size}/${type}/${file}"
									fi
								done
							fi
						;;
						24)
							if [ -d "${INDIR}/${size}x${size}/${type}/" ]; then
								mkdir -p ${OUTDIR}/${size}x${size}/${type}
								for file in ${INDIR}/${size}x${size}/${type}/*.svg; do
									[ ! -f "$file" ] && continue
									outfile="${OUTDIR}/${size}x${size}/${type}/$(basename -s .svg "${file}").png"
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
							# Удаляем удаленные
							if [ -d "${OUTDIR}/${size}x${size}/${type}" ]; then
								cd "${OUTDIR}/${size}x${size}/${type}"
								for file in $(find . -name "*.png" 2>/dev/null | sort); do
									f=${file/.png/.svg}
									if [ ! -f "${INDIR}/${size}x${size}/${type}/${f}" ]; then
										echo "rm: ${OUTDIR}/${size}x${size}/${type}/${file}"
										rm "${OUTDIR}/${size}x${size}/${type}/${file}"
									fi
								done
							fi
						;;
						32|48|64|96|128|256|512)
							if [ -d "${INDIR}/96x96/${type}/" ]; then
								mkdir -p ${OUTDIR}/${size}x${size}/${type}
								for file in ${INDIR}/96x96/${type}/*.svg; do
									outfile="${OUTDIR}/${size}x${size}/${type}/$(basename -s .svg "${file}").png"
									if [ ! -f "$outfile" ] || [[ "$(stat -c %Y $outfile)" < "$(stat -c %Y $file)" ]]; then
										inkscape -z -d 96 -y 0.0 -w ${size} -h ${size} --file="${file}" --export-png="$outfile"
									fi
								done
							fi
							# Удаляем удаленные
							if [ -d "${OUTDIR}/${size}x${size}/${type}" ]; then
								cd "${OUTDIR}/${size}x${size}/${type}"
								for file in $(find . -name "*.png" 2>/dev/null | sort); do
									f=${file/.png/.svg}
									if [ ! -f "${INDIR}/96x96/${type}/${f}" ]; then
										echo "rm: ${OUTDIR}/${size}x${size}/${type}/${file}"
										rm "${OUTDIR}/${size}x${size}/${type}/${file}"
									fi
								done
							fi
						;;
					esac
				done
			done
		done
	;;
	step4)
		rm -rf "${CURDIR}/DESTDIR"
		# Слияние подготовленных иконок в DESTDIR
		for theme in Faience-ng Faience-ng-Dark Faience-ng-Light Faience-ng-Blue Faience-ng-Green Faience-ng-Light-Blue Faience-ng-Light-Green Faience-ng-Dark-Blue Faience-ng-Dark-Green; do
			OUTDIR="${CURDIR}/DESTDIR/${theme}"
			mkdir -p "${OUTDIR}"
			if [ -d "${CURDIR}/PREBUILD/png/symbolic/${theme}" ]; then
				cp -aT "${CURDIR}/PREBUILD/png/symbolic/${theme}" "${OUTDIR}"
			fi
			if [ -d "${CURDIR}/PREBUILD/png/drawed/${theme}" ]; then
				cp -aT "${CURDIR}/PREBUILD/png/drawed/${theme}" "${OUTDIR}"
			fi

			# Создаем симлинки
			for type in actions apps categories devices emblems mimetypes places status; do #animations
				while read line; do
					for lnk in ${line#* }; do
						dirnm=$(echo ${lnk} | cut -s -d: -f1)
						if [ "$dirnm" ]; then
							trgt="../${type}/"
						else
							trgt=
							dirnm="${type}"
						fi
						ext=png
						for size in ${OUTSIZES}; do
							[ ! -d "${OUTDIR}/${size}x${size}/${type}" ] && continue
							#[ ! -d "${OUTDIR}/${size}x${size}/${dirnm}" ] && mkdir -p "${OUTDIR}/${size}x${size}/${dirnm}"
							cd "${OUTDIR}/${size}x${size}/${type}"
							if [ -e "${line%% *}.${ext}" ]; then
								[ ! -e "${OUTDIR}/${size}x${size}/${dirnm}/${lnk#*:}.${ext}" ] && ln -s "${trgt}${line%% *}.${ext}" "${OUTDIR}/${size}x${size}/${dirnm}/${lnk#*:}.${ext}"
							else
								if [ -e "${CURDIR}/DESTDIR/Faience-ng/${size}x${size}/${dirnm}/${lnk#*:}.${ext}" -a ! -e "${OUTDIR}/${size}x${size}/${dirnm}/${lnk#*:}.${ext}" ]; then
									ln -s "../../../Faience-ng/${size}x${size}/${dirnm}/${lnk#*:}.${ext}" "${OUTDIR}/${size}x${size}/${dirnm}/${lnk#*:}.${ext}"
								else
									echo "WARNING: '${line%% *}.${ext}' not found. Skiping"
								fi
							fi
						done
					done
				done < "${CURDIR}/${type}.lst"
			done
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
					ln -s "../${file%% *}" "${CURDIR}/DESTDIR/Faience-ng/symbolic/${f}"
				done
			fi
		done < "${CURDIR}/scalable.lst"
		cd "${CURDIR}"

		# Делаем симлинки для остальных тем
		for type in actions apps categories devices emblems mimetypes places status; do #animations
			for size in ${OUTSIZES}; do #scalable
				if [ -d "${CURDIR}/DESTDIR/Faience-ng/${size}x${size}/${type}" ]; then
					for file in "${CURDIR}/DESTDIR/Faience-ng/${size}x${size}/${type}"/*.png; do
						b=$(basename $file)
						if [ ! -L "$file" ]; then
							for theme in Faience-ng-Dark Faience-ng-Light Faience-ng-Blue Faience-ng-Green; do # Faience-ng-Dark-Blue Faience-ng-Dark-Green
								#mkdir -p "${CURDIR}/DESTDIR/${theme}/${size}x${size}/${type}/"
								outfile="${CURDIR}/DESTDIR/${theme}/${size}x${size}/${type}/${b}"
								if [ ! -e "${outfile}" ]; then
									ln -s "../../../Faience-ng/${size}x${size}/${type}/${b}" "${outfile}"
								fi
							done
						fi
					done
				fi
			done
		done
		# Делаем симлинки
		for theme in Faience-ng-Light-Blue Faience-ng-Light-Green Faience-ng-Dark-Blue Faience-ng-Dark-Green; do # Faience-ng-Blue Faience-ng-Green Faience-ng-Dark Faience-ng-Light
			inherits=$(egrep "^Inherits=" "${CURDIR}/${theme}/index.theme" | cut -d= -f2)
			for size in ${OUTSIZES}; do
				mkdir -p "${CURDIR}/DESTDIR/${theme}/${size}x${size}/"
				for type in actions apps categories devices emblems mimetypes places status; do
					for inh in ${inherits//,/ }; do
						outfile="${CURDIR}/DESTDIR/${theme}/${size}x${size}/${type}"
						if [ -d "${CURDIR}/DESTDIR/${inh}/${size}x${size}/${type}" -a ! -e "${outfile}" ]; then
							ln -s "../../${inh}/${size}x${size}/${type}" "${outfile}"
						fi
					done
				done
			done
		done
		# Механизм создания симлинков получился запутанным :-( . По другому пока не получается избавиться от багов.
		for theme in Faience-ng Faience-ng-Dark Faience-ng-Light Faience-ng-Blue Faience-ng-Green Faience-ng-Light-Blue Faience-ng-Light-Green Faience-ng-Dark-Blue Faience-ng-Dark-Green; do

			OUTDIR="${CURDIR}/DESTDIR/${theme}"

			cp "${CURDIR}/${theme}/index.theme" "${OUTDIR}/"
			dirs=""
			for size in ${OUTSIZES} symbolic; do
				for type in actions apps categories devices emblems mimetypes places status stock; do
					#mkdir -p "${OUTDIR}/${size}x${size}/${type}"
					[ ! -d "${OUTDIR}/${size}x${size}/${type}" ] && continue
					dirs+="${size}x${size}/${type},"
					echo >> "${OUTDIR}/index.theme"
					echo "[${size}x${size}/${type}]" >> "${OUTDIR}/index.theme"
					echo "Context=$(get_context ${type})" >> "${OUTDIR}/index.theme"
					if [ "${size}" = "symbolic" ]; then
						echo "Size=16" >> "${OUTDIR}/index.theme"
						echo "MinSize=8" >> "${OUTDIR}/index.theme"
						echo "MaxSize=512" >> "${OUTDIR}/index.theme"
						echo "Type=Scalable" >> "${OUTDIR}/index.theme"
					#elif [ "${size}" = 256 ]; then
						#echo "Size=256" >> "${OUTDIR}/index.theme"
						#echo "MinSize=8" >> "${OUTDIR}/index.theme"
						#echo "MaxSize=512" >> "${OUTDIR}/index.theme"
						#echo "Type=Scalable" >> "${OUTDIR}/index.theme"
					else
						echo "Size=${size}" >> "${OUTDIR}/index.theme"
						echo "Type=Fixed" >> "${OUTDIR}/index.theme"
					fi
				done
			done
			sed -i "${OUTDIR}/index.theme" -e s#Directories=#Directories="${dirs}"#

		done
	;;
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

	*)
		echo "ERROR: unknown command"
	;;
esac

#find /usr/share/icons/Adwaita/scalable -name "*-symbolic*" | sed -e 's|/usr/share/icons/Adwaita/scalable/||' -e 's|/| |' -e 's|.svg||' | sort > scalable.lst
#find /usr/share/icons/Adwaita/scalable -name "*-symbolic*" | sed -e 's|/usr/share/icons/Adwaita/scalable/||'  | sort > scalable.lst
