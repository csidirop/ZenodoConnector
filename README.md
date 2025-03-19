# ZenodoConnector
ZenodoConnector is a shell script designed to facilitate interactions with [Zenodo's](https://zenodo.org/) REST API. It enables users to automate tasks such as uploading files, creating records, and managing deposits on Zenodo, a free and open repository for research data.

## Features
- Upload files to Zenodo
- Create and manage records
- Automate deposits

## Prerequisites
- Unix-based operating system
- cURL installed
- A Zenodo account
- Zenodo API token (available from your Zenodo account settings)

## Usage

1. Clone this repository: `git clone https://github.com/csidirop/ZenodoConnector.git`
2. Navigate to the repository directory:`cd ZenodoConnector`
3. Make the script executable: `chmod +x zenodo_connector.sh`
4. Run the script with the necessary parameters: `./zenodo_connector.sh [options]`

   Replace `[options]` with the appropriate flags and arguments as per your requirements.

### Options
#### General:
```bash
./zenodo_connector.sh --mode=[init|upload|discard|publish] --record_id=[id] --file=[file] --access_token=[path/to/token|token]
```
#### Example:
```bash
# Create a new record:
./zenodo_connector.sh --mode=init --access_token=[token]
# Upload a file to an existing record:
./zenodo_connector.sh --mode=upload --record_id=1234 --file=path/to/example.txt --access_token=[path/to/tokenfile]
# Discard a record:
./zenodo_connector.sh --mode=discard --record_id=1234 --access_token=[path/to/tokenfile]
# Publish a record:
./zenodo_connector.sh --mode=publish --record_id=1234 --access_token=[path/to/tokenfile]
```

## License
This project is licensed under the GPL-3.0 License. See the [LICENSE](LICENSE) file for more details.
