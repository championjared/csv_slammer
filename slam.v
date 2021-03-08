import encoding.csv
import encoding.utf8
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
        if utf8.validate_str(data){
            println('Valid UTF-8 encoding')
        }
        // parse csv logic
        mut parser := csv.new_reader(data.str())
        mut header_row := true
        mut header_col_index := []ColIndex{}
        
        for {
            line := parser.read() or { break }
            
            if header_row {
                header_row = false

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

            } else { // else create data row
                mut data_row := []string{}
                for col_index in header_col_index {
                    data_row << line[col_index.position]
                }
                output_data << data_row
            } 
        }

    } // end file loop

    mut output := csv.new_writer() 

    // header
    output.write(config.mapped_fields.map(it.output)) ?
    for row in output_data {
        output.write(row) ?
    }

    output_str := output.str()
    log('OUTPUT', 'writing output to ./out/$config.output_file')
    mut output_file := os.create('./out/$config.output_file') ?
    output_file.write(output_str.bytes()) ?
    output_file.close()

}

