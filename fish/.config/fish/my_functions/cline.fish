function cline
    if test -d ./.cursor
        mv ./.cursor ./tmp
        echo "Renamed .cursor to tmp"
    else if test -d ./tmp
        mv ./tmp ./.cursor
        echo "Renamed tmp to .cursor"
    else
        echo "Neither .cursor nor tmp directory found."
    end
end
