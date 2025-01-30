#!/bin/bash

# Configuration
SCRIPT_DIR="$(dirname "$0")"  # Directory where the script is located
FILTER_DIR="$SCRIPT_DIR/json_filters"  # Directory to store JSON filters (relative path)
PYTHON_SCRIPT="$SCRIPT_DIR/filter_csv.py"  # Path to your Python script (relative path)
OUTPUT_PREFIX="filtered_output"  # Prefix for the output CSV file

# Create the filter directory if it doesn't exist
mkdir -p "$FILTER_DIR"

# Function to add or edit a JSON filter
manage_filter() {
    # Get the filter name from the user
    FILTER_NAME=$(zenity --entry --title="Filter Name" --text="Enter a name for the filter:")

    if [ -z "$FILTER_NAME" ]; then
        zenity --error --text="No filter name provided. Exiting."
        exit 1
    fi

    FILTER_FILE="$FILTER_DIR/$FILTER_NAME.json"

    # If the filter file exists, load its content for editing
    if [ -f "$FILTER_FILE" ]; then
        FILTER_CONTENT=$(cat "$FILTER_FILE")
    else
        FILTER_CONTENT='{}'  # Default empty JSON
    fi

    # Open a text editor for the user to edit the JSON
    NEW_FILTER_CONTENT=$(zenity --text-info --title="Edit JSON Filter" --editable --filename="$FILTER_FILE" --width=600 --height=400 --text="Enter filter criteria as JSON. The script will check if the column values INCLUDE the specified substrings.")

    if [ -z "$NEW_FILTER_CONTENT" ]; then
        zenity --error --text="No content provided. Exiting."
        exit 1
    fi

    # Save the updated JSON to the filter file
    echo "$NEW_FILTER_CONTENT" > "$FILTER_FILE"
    zenity --info --text="Filter '$FILTER_NAME' saved successfully!"
}

# Function to run the Python script with the selected filter
run_filter() {
    # List all JSON filters in the directory
    FILTER_LIST=$(ls "$FILTER_DIR"/*.json 2>/dev/null)

    if [ -z "$FILTER_LIST" ]; then
        zenity --error --text="No filters found. Please create a filter first."
        exit 1
    fi

    # Let the user select a filter
    SELECTED_FILTER=$(zenity --list --title="Select Filter" --column="Filters" $FILTER_LIST)

    if [ -z "$SELECTED_FILTER" ]; then
        zenity --error --text="No filter selected. Exiting."
        exit 1
    fi

    # Run the Python script with the selected filter and output prefix
    python3 "$PYTHON_SCRIPT" "$SELECTED_FILTER" "$OUTPUT_PREFIX"

    if [ $? -eq 0 ]; then
        zenity --info --text="Filtering completed! Output saved to ${OUTPUT_PREFIX}_<timestamp>.csv."
    else
        zenity --error --text="An error occurred while running the filter."
    fi
}

# Main menu
while true; do
    CHOICE=$(zenity --list --title="JSON Filter Manager" --column="Options" \
        "Add/Edit Filter" \
        "Run Filter" \
        "Exit")

    case "$CHOICE" in
        "Add/Edit Filter")
            manage_filter
            ;;
        "Run Filter")
            run_filter
            ;;
        "Exit")
            break
            ;;
        *)
            zenity --error --text="Invalid choice. Exiting."
            exit 1
            ;;
    esac
done