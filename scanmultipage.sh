#!/bin/bash

# Check for required arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <watch_dir> <output_dir>"
    exit 1
fi

# Directories passed as arguments
watch_dir=$1
output_dir=$2

# Function to reverse the pages of a PDF file
reverse_pdf() {
    input_pdf=$1
    output_pdf=$2
    pdftk "$input_pdf" cat end-1 output "$output_pdf"
}

# Function to interleave pages from odd and even files
interleave_pdfs() {
    odd_file=$1
    reversed_even_file=$2
    output_file=$3
    pdftk A="$odd_file" B="$reversed_even_file" shuffle A B output "$output_file"
}

# Main function to process PDFs
process_pdfs() {
    odd_file=$1
    even_file=$2
    timestamp=$(date +"%Y%m%d-%H%M%S")
    output_file="${output_dir}/combined_${timestamp}.pdf"
    reversed_even_file="/tmp/reversed_even_${timestamp}.pdf"

    echo "Reversing pages of the even pages file: $even_file"
    reverse_pdf "$even_file" "$reversed_even_file"

    echo "Interleaving $odd_file (odd pages) and $reversed_even_file (even pages) into $output_file"
    interleave_pdfs "$odd_file" "$reversed_even_file" "$output_file"

    if [ $? -eq 0 ]; then
        echo "Combined file created: $output_file"
        # Clean up the original files
        rm -f "$odd_file" "$even_file" "$reversed_even_file"
    else
        echo "Error combining files."
    fi
}

# Monitor the specified directory
echo "Watching directory: $watch_dir"
inotifywait -m -e close_write --format "%f" "$watch_dir" | while read -r new_file; do
    # Check if there are at least two PDF files in the directory
    pdf_files=("$watch_dir"/*.pdf)
    if [ ${#pdf_files[@]} -ge 2 ]; then
        # Sort files by timestamp and select the first two
        IFS=$'\n' sorted_files=($(ls -tr "$watch_dir"/*.pdf))
        odd_file="${sorted_files[0]}"
        even_file="${sorted_files[1]}"
        
        # Process the files
        process_pdfs "$odd_file" "$even_file"
    fi
done
