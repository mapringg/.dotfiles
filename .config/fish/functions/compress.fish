function compress
    set -l dir (string replace -r '/$' '' $argv[1])
    tar -czf "$dir.tar.gz" "$dir"
end
