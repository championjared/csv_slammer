# CSV SLAMMER

This is a simple portable binary to take some input CSV's, merge the schema on desired fields
and output a consolidated file.

## Configuration

Please update the config.json with your desired configuration. Also ensure the executing folder has 
both `in` and `out` sub-folders. 

## Running the app

You will need to either build the binary by running `v slam.v` from the root of the folder (this assumes
you have installed v and have it added to your path). Alternatively you can grab the latest binary
from `https://github.com/championjared/csv_slammer/releases` and put it in the root folder.

After your config.json is set up, binary in place and the files are in the `in` folder, simply execute the binary
`slam.exe` (or `slam.bat` if you want to check the terminal output)