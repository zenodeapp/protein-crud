#!/usr/bin/awk -f

function print_array() {
    for(x in arr) {
        split(x, b, "\"");

        for(i = 1; i < counter[x]; i++) {
            output_file = "./output/split_by_ox_"b[2]"_"(max_per_ox == 0 ? 0 : int((i-1)/max_per_ox))".txt";
            print arr[x][i] > output_file;
        }
    }
}

BEGIN{
    system("mkdir output 2>&-");
    max_per_ox = max ? max : 10000;
} 

NF{
    split($0, a, ",\"");
    fasta_metadata=length(a) > 4 ? "\""a[5] : "\"\"";

    ox_index = index(fasta_metadata, "OX=");
    split(substr(fasta_metadata, ox_index + 3), t, " ");
    ox=t[1];
    
    ox_key = "\""ox"\"";

    if(counter[ox_key] == 0) counter[ox_key] = 1;

    arr[ox_key][counter[ox_key]] = $0;
    counter[ox_key]++;
} 

END{
    print_array();
}