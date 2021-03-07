import encoding.csv
import os
import json

struct Config {
    mapped_fields []Field
    output_file string
    input_folder string
}

struct Field {
    input []string
    output string
}

struct ColIndex {
    field string
    position int
}

fn log(component string, message string) {
    log_prefix := '[DEBUG]: $component: '
    println('$log_prefix$message')
}

fn index_of(str_list []string, values []string) ?int {
    mut i := 0
    for item in str_list {
        if item in values {
            return i
        }
        i = i+1
    }
    return error('value in $values not found')
}

fn main() {

    // read runtime config
    config_filename := './config.json'
    config_data := os.read_file(config_filename) or {
        panic('config file \'./config.json\' not found!')
        return
    }
    config := json.decode(Config, config_data) or {
        eprintln('Failed to read ./config.json')
        return
    }
    log('Config','Output: $config.output_file')
    log('Config','Mapped Fields: $config.mapped_fields')

    // get input csv's
    input_csv := os.ls(config.input_folder) ?
    mut output_data := [][]string{}
    for filename in input_csv {
        filepath := '$config.input_folder/$filename'
        log('CSV','Reading $filepath')
        data := os.read_file(filepath) ?
        // parse csv logic
        mut parser := csv.new_reader(data.str())
        mut header_row := true
        mut header_col_index := []ColIndex{}
        
        for {
            line := parser.read() or { break }
            println(line)
            

            if header_row {

                header_row = false
                //row_index := index_of(line,["pid","some","SKU"]) ?

                for column in config.mapped_fields {
                    index_pos := index_of(line, column.input) or {
                        panic('Column name for $filepath not found in input: $column.input for output: $column.output')
                        return
                    }

                    header_col_index << ColIndex {
                        field: column.output
                        position: index_pos
                        }
                }      
                //log('HEADER: $filename:', header_col_index.str())

            } else { // else create data row
                //log('DATA_ROW: $filename:', line.str())
                mut data_row := []string{}
                for col_index in header_col_index {
                    test_line := line[col_index.position]
                    //println('file: $filename data line: $test_line')
                    data_row << line[col_index.position]
                }
                output_data << data_row
            } 
                // add index to row  
            //println('output data: $output_data')
        }

        
        //log('CSV',data)
    } // end file loop
    
    // test out
    mut output := os.create('./out/$config.output_file') ?
    output.write('tests'.bytes()) ?
    output.close()

}

