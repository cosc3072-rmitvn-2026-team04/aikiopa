#!/bin/bash

project_directory="$PWD"
artifact_directory="cc_check_reports"
report_file="report"
timestamp=$EPOCHSECONDS
report_temp_path="${project_directory%/}/${artifact_directory#/}/${report_file}_${timestamp}.temp"
report_json_path="${project_directory%/}/${artifact_directory#/}/${report_file}_${timestamp}.json"

help() {
  # Display help
  echo "Generate project cyclomatic complexity report. Exported reports can be found in ./${artifact_directory#/}/"
  echo
  echo "Syntax: cc_check.sh [-c|h]"
  echo "Options:"
  echo "c     Clean cc_check_reports folder and exit."
  echo "h     Print this Help and exit."
  echo
}

clean() {
  # Clean artifact directory
  echo " =====[ CLEANING CYCLOMATIC COMPLEXITY REPORT DIR ]===== "
  bash -c "git clean -dfx -e '.godot' -e 'build' -e 'artifact' -e 'test_results'"
  echo "[ DONE ]"
}

while getopts ":ch" option; do
  case $option in
    c)
      clean
      exit;;
    h)
      help
      exit;;
   \?)
      # Invalid option
      echo "cc_check.sh: Invalid option '-${OPTARG}'" >&2
      echo "Try 'cc_check.sh -h' for more information."
      exit;;
  esac
done

if [ ! -d "${project_directory%/}/${artifact_directory#/}" ]; then
  mkdir "${project_directory%/}/${artifact_directory#/}"
fi

echo "Running cyclomatic complexity analysis..."
bash -c "gdradon cc scripts tests | tee ${report_temp_path}"
awk 'BEGIN {
    print "{";
    file_count = 0;
    entry_count = 0;
  }

  function print_entry() {
    if (file != "") {
      if (entry_count > 0) print ",";

      printf "    {\n";
      printf "      \"type\": \"%s\",\n", type;
      printf "      \"rank\": \"%s\",\n", rank;
      printf "      \"col_offset\": %s,\n", col_offset;
      printf "      \"lineno\": %s,\n", lineno;
      printf "      \"name\": \"%s\",\n", name;
      printf "      \"complexity\": %s\n", complexity;
      printf "    }";

      entry_count++;
    }
  }

  /^[[:space:]]/ {
    sub(/(- |: |-| -)/, " ", $0);

    if ($1 == "F") type = "function";
    if ($1 == "C") type = "class";

    rank = $4;

    split($2, where, ":");
    col_offset = where[2];
    lineno = where[1];

    name = $3;

    complexity = $5;
    gsub(/[()]/, "", complexity);

    print_entry();
  }

  /^[^[:blank:]]/ {
    if (file != "") printf "\n  ]";
    if (file_count > 0) printf ",\n";

    file = $0;
    printf "  \"%s\": [\n", file;

    file_count++;
    entry_count = 0;
  }

  END {
     if (file != "") printf "  ]\n";
     print "}";
  }' "${report_temp_path}" > "${report_json_path}"
rm "${report_temp_path}"
echo "Report exported to ${report_json_path}"
