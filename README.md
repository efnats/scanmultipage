# ScanOCR Script

A script to watch a directory and automatically combine pairs of PDF files with interleaved pages, ideal for reconstructing double-sided documents scanned on a simplex (single-sided) ADF scanner. Utilizes [PDFtk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)

## Prerequisites

- Linux (e.g., Ubuntu)
- PDFtk
- inotify-tools

Install prerequisites on Ubuntu:

```bash
sudo apt-get -y install pdftk inotify-tools
```
## Operation

The `scanmultipage` script is designed to monitor a specified directory for pairs of PDF files, then automatically combine them into a single, correctly ordered, double-sided document. This is particularly useful for users with a simplex (single-sided) scanner that can only scan one side at a time. By scanning the odd and even pages separately, and then using this script, users can create properly ordered double-sided PDFs.

### How It Works

1. **Watch Folder Setup**:
   - The script monitors a designated "watch folder" for incoming PDF files.
   - Each time two new PDF files are detected, the script assumes that:
     - The **first file** contains the **odd-numbered pages**.
     - The **second file** contains the **even-numbered pages** in reverse order.

2. **Combining Files**:
   - The script processes each pair of PDF files by:
     1. **Reversing the pages** in the even-numbered PDF file so they are in the correct order.
     2. **Interleaving** pages from the odd and reversed even PDFs to create a combined, properly ordered, double-sided document.
   - The final PDF is saved in a specified output directory with a timestamped filename for easy identification.

### Requirements

- **PDF Processing Tools**: The script relies on `pdftk` for reversing and interleaving pages.
- **inotify-tools**: The script uses `inotifywait` to monitor the watch folder for new files.

### Usage

To run `scanmultipage.sh`, provide the paths for the watch folder and output folder as command-line arguments. This setup allows flexibility, enabling multiple instances of the script to run with different folder configurations.

Example:
```bash
./scanmultipage.sh /path/to/watch_folder /path/to/output_folder

## Setup

1. Clone the repository and copy files:

```bash
git clone https://github.com/efnats/scanmultipage
cd scanmultipage
sudo cp ./scanmultipage.sh /usr/local/bin
sudo chmod +x /usr/local/bin/scanmutipage.sh
sudo cp ./scanmultipage.service /etc/systemd/system/
```

2. Adjust the service file by adjusting file paths according to your needs

3. Setup the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable scanmultipage.service
sudo systemctl start scanmultipage.service
```
