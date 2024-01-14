

# Function to remove a directory if it exists
remove_directory() {
    if [ -d "$1" ]; then
        echo "Removing $1"
        rm -r "$1"
    fi
}

# Check if no arguments are provided, remove everything
if [ "$#" -eq 0 ]; then
    echo "Removing all directories: data, resources, output, logs"
    remove_directory "data"
    remove_directory "resources"
    remove_directory "output"
    remove_directory "logs"
else
    # Loop through the provided arguments and remove corresponding directories
    for arg in "$@"; do
        case "$arg" in
            "data"|"resources"|"output"|"logs")
                remove_directory "$arg"
                ;;
            *)
                echo "Invalid argument: $arg. Valid arguments are: data, resources, output, logs"
                ;;
        esac
    done
fi
