#!/usr/bin/env bash

# Print header message
print_header() {
    echo -e 'File Janitor, 2024\nPowered by Bash\n'
}

# report command logic
print_report() {
    n_tmp=$(find "$1" -maxdepth 1 -name "*.tmp" -type f | wc -l)
    n_tmp=${n_tmp:-0}
    
    size_tmp=$(find "$1" -maxdepth 1 -name "*.tmp" -type f -exec du -bc {} + | grep total | cut -f1)
    size_tmp=${size_tmp:-0}

    n_log=$(find "$1" -maxdepth 1 -name "*.log" -type f | wc -l)
    n_log=${n_log:-0}
    size_log=$(find "$1" -maxdepth 1 -name "*.log" -type f -exec du -bc {} + | grep total | cut -f1)
    size_log=${size_log:-0}

    n_py=$(find "$1" -maxdepth 1 -name "*.py" -type f | wc -l)
    n_py=${n_py:-0}
    size_py=$(find "$1" -maxdepth 1 -name "*.py" -type f -exec du -bc {} + | grep total | cut -f1)
    size_py=${size_py:-0}

    echo "$n_tmp tmp file(s), with total size of $size_tmp bytes"
    echo "$n_log log file(s), with total size of $size_log bytes"
    echo "$n_py py file(s), with total size of $size_py bytes"
}

# clean command logic
clean() {
    echo -n 'Deleting old log files...'

    n_log=$(find "$1" -maxdepth 1 -name "*.log" -type f -mtime +3 | wc -l)
    n_log=${n_log:-0}
    find "$1" -maxdepth 1 -name "*.log" -type f -mtime +3 -exec rm {} +
    echo " done! $n_log files have been deleted"

    echo -n 'Deleting temporary files...'
    n_tmp=$(find "$1" -maxdepth 1 -name "*.tmp" -type f | wc -l)
    n_tmp=${n_tmp:-0}
    find "$1" -maxdepth 1 -name "*.tmp" -type f -exec rm {} +
    echo " done! $n_tmp files have been deleted"

    echo -n 'Moving python files...'
    n_py=$(find "$1" -maxdepth 1 -name "*.py" -type f | wc -l)
    n_py=${n_py:-0}
    if [ ! -d "$1/python_scripts" -a $n_py -gt 0 ]; then
        mkdir "$1/python_scripts"
    fi
    find "$1" -maxdepth 1 -name "*.py" -type f -exec mv {} "$1/python_scripts" \;
    echo " done! $n_py files have been moved"
}

# Main script logic
main() {
    print_header

    # Handle no parameters or invalid parameters
    if [ "$1" != "help" ] && [ "$1" != "list" ] && [ "$1" != "report" ] && [ "$1" != "clean" ]; then
        echo "Type file-janitor.sh help to see available options"
        exit 1
    fi

    # Handle help parameter
    if [ "$1" = "help" ]; then
        cat file-janitor-help.txt
        exit 0
    fi

    # Handle list parameter
    if [ "$1" = "list" ]; then
        # No location specified - list current directory
        if [ -z "$2" ]; then
            echo -e "Listing files in the current directory\n"
            ls -A1v
            exit 0
        fi

        # Location specified - validate and list
        if [ ! -e "$2" ]; then
            echo -e "$2 is not found"
            exit 1
        fi

        if [ ! -d "$2" ]; then
            echo -e "$2 is not a directory"
            exit 1
        fi

        echo -e "Listing files in $2\n"
        ls -A1v "$2"
        exit 0
    fi

    # Handle report parameter
    if [ "$1" = "report" ]; then
        # No location specified - list current directory
        if [ -z "$2" ]; then
            echo -e "The current directory contains:\n"
            print_report "./"
            exit 0
        fi
        # Location specified - validate and list
        if [ ! -e "$2" ]; then
            echo -e "$2 is not found"
            exit 1
        fi

        if [ ! -d "$2" ]; then
            echo -e "$2 is not a directory"
            exit 1
        fi

        echo -e "$2 contains:"
        print_report "$2"
        exit 0
    fi

    # Handle clean parameter
    if [ "$1" = "clean" ]; then
        # No location specified - list current directory
        if [ -z "$2" ]; then
            echo -e "Cleaning the current directory...\n"
            clean "./"
            echo -e "\nClean up of the current directory is complete!"
            exit 0
        fi
        # Location specified - validate and list
        if [ ! -e "$2" ]; then
            echo -e "$2 is not found"
            exit 1
        fi

        if [ ! -d "$2" ]; then
            echo -e "$2 is not a directory"
            exit 1
        fi

        echo -e "Cleaning $2..."
        clean "$2"
        echo -e "\nClean up of $2 is complete!"
        exit 0
    fi
}

# Execute main function with all arguments
main "$@"