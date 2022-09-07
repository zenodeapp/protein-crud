#!/usr/bin/awk -f

function print_array() {
    for(x in arr) {
        split(x, b, "\"");

        for(i = 1; i < counter[x]; i++) {
            output_file = "./output/split_by_os_"b[2]"_"(max_per_os == 0 ? 0 : int((i-1)/max_per_os))".txt";
            print arr[x][i] > output_file;
        }
    }
}

BEGIN{
    system("mkdir output 2>&-");
    max_per_os = max ? max : 10000;
} 

NF{
    split($0, a, ",\"");
    fasta_metadata=length(a) > 4 ? "\""a[5] : "\"\"";

    os_index = index(fasta_metadata, "OS=");
    split(substr(fasta_metadata, os_index + 3), t, " ");
    os=t[1];
    os_key = "\""os"\"";

    if(counter[os_key] == 0) counter[os_key] = 1;

    arr[os_key][counter[os_key]] = $0;
    counter[os_key]++;
} 

END{
    print_array();
}