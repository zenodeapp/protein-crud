#!/usr/bin/awk -f

# quick sort from https://unix.stackexchange.com/questions/609866/regular-awk-easily-sort-array-indexes-to-output-them-in-the-chosen-order
function quicksort(data, left, right, i, last) {
  if (left >= right) return;

  quicksort_swap(data, left, int((left + right) / 2));
  last = left;

  for (i = left + 1; i <= right; i++) {
    if (data[i] <= data[left]) quicksort_swap(data, ++last, i);
  }

  quicksort_swap(data, left, last)
  quicksort(data, left, last - 1)
  quicksort(data, last + 1, right)
}

  function quicksort_swap(data, i, j, temp) {
    temp = data[i];
    data[i] = data[j];
    data[j] = temp;
  }

function print_array() {
  for(x in arr) {
    split(x, b, "\"");

    for(i = 1; i < counter[x]; i++) {
      output_file = "./output/ox_"b[2]""(_nfts_per_file != 0 ? "_"(int((i-1)/_nfts_per_file)) : "")".txt";
      print arr[x][i] > output_file;
    }
  }
}

function print_clusters() {
  protein_count = 0;
  current_file_number = 0;

  for (i = 2; i <= key_counter; i++) {
    file_number = _cluster_size == 0 ? 0 : (int((i - 2)/_cluster_size));

    if(current_file_number != file_number) {
      protein_count = 0;
      current_file_number = file_number;
    }

    min_ox_index = file_number * _cluster_size + 2;
    max_ox_index = (min_ox_index + _cluster_size - 1) > key_counter ? key_counter : (min_ox_index + _cluster_size - 1);

    ox_key = "\""ox_keys[i]"\"";
    
    for(j = 1; j < counter[ox_key]; j++) {
      output_file = "./output/ox_cluster_"(file_number == 0 ? 0 : ox_keys[min_ox_index])"-"ox_keys[max_ox_index](_nfts_per_file != 0 ? "_"(int(protein_count/_nfts_per_file)) : "")".txt";
      print arr[ox_key][j] > output_file;
      protein_count++;
    }
  }
}

BEGIN {
  system("mkdir output 2>&-");
  _nfts_per_file = nfts_per_file ? nfts_per_file : 0;
  _cluster_size = cluster_size ? cluster_size : 0;
  key_counter = 1;
}

NF {
  split($0, a, ",\"");
  fasta_metadata=length(a) > 4 ? "\""a[5] : "\"\"";

  ox_index = index(fasta_metadata, "OX=");
  split(substr(fasta_metadata, ox_index + 3), t, " ");
  ox=t[1];

  ox_key = "\""ox"\"";

  if(counter[ox_key] == 0) {
    ox_keys[key_counter] = ox;
    counter[ox_key] = 1;
    key_counter++;
  }

  arr[ox_key][counter[ox_key]] = $0;
  counter[ox_key]++;
} 

END {
  if(_cluster_size > 0) {
    quicksort(ox_keys, 1, key_counter);
    print_clusters();
  } else {
    print_array();
  }
}