function compare_folders
    # Check if both arguments are provided
    if test (count $argv) -ne 2
        echo "Usage: compare_folders folder1 folder2"
        return 1
    end

    set folder1 $argv[1]
    set folder2 $argv[2]

    # Check if both folders exist
    if not test -d $folder1
        echo "Error: $folder1 is not a directory"
        return 1
    end
    if not test -d $folder2
        echo "Error: $folder2 is not a directory"
        return 1
    end

    # Get lists of files (basename only)
    set files1 (ls -1 $folder1 | sort)
    set files2 (ls -1 $folder2 | sort)

    echo "Files unique to $folder1:"
    for file in $files1
        if not contains $file $files2
            echo "  $file"
        end
    end

    echo "Files unique to $folder2:"
    for file in $files2
        if not contains $file $files1
            echo "  $file"
        end
    end

    echo "Files present in both folders:"
    for file in $files1
        if contains $file $files2
            echo "  $file"
        end
    end
end
