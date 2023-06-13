# Converts all card SVGs to PNG

for directory in clovers spades diamonds heart knakers
do
	for file in $directory/*.svg
	do
		echo "Converting $file"
		inkscape "$file" --export-type="png" --export-dpi="30"
	done
done

for file in "baksida cutout.svg" baksida.svg cardoutline.svg
do
	echo "Converting $file"
	inkscape "$file" --export-type="png" --export-dpi="30"
done