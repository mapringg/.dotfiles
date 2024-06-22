./apt.sh
for file in *.sh; do
	if [ "$file" != "apt.sh" ]; then
		./ "$file"
	fi
done
