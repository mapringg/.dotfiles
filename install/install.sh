./ubuntu.sh
for file in *.sh; do
	if [ "$file" != "ubuntu.sh" ]; then
		./ "$file"
	fi
done
