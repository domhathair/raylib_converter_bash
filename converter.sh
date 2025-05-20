#!/bin/bash

# snake_case converter for raylib.h / raymath.h
# 
# This is a converter from raylib's traditional PascalCase/camelCase to lowercase snake_case.
#
# NOTE: this converter is NOT part of the raylib library (https://www.raylib.com/) and is provided "as-is".

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_raylib_folder>"
    exit 1
fi

folder_path=$1

TYPE_SUFFIX="_t"
DO_NOT_CONVERT=("bool" "typedef" "enum" "false" "true" "char" "int" "float" "double" "void" "unsigned" "const" "signed" "long" "short" "struct" "union" "static" "extern" "volatile" "register" "auto" "inline" "restrict" "sizeof" "0")

camel_to_snake() {
    local name="$1"
    name=$(echo "$name" | sed -E 's/([A-Z]+)([A-Z][a-z])/\1_\2/g')
    name=$(echo "$name" | sed -E 's/([a-z])([A-Z])/\1_\2/g')
    name=$(echo "$name" | sed -E 's/([a-z])([0-9][A-Z])/\1_\2/g')
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/vector_2/vector2_/g')
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/vector_3/vector3_/g')
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/vector_4/vector4_/g')
    echo "$name"
}

process_header() {
    local file_content="$1"
    local file="$2"
    local header_name="$3"
    local func_prefix="$4"

    echo -en "#ifndef ${header_name}\n#define ${header_name}\n\n"
    echo -en "/* converted by convertor.sh */\n"
    echo -en "/* https://github.com/keyle/raylib-converter, https://github.com/domhathair/raylib-converter-bash */\n\n"
    echo -en "#include \"${file}\"\n\n"
    echo -en "/* Types */\n"

    local content=""

    local typedef_patterns=("typedef\s+.+\s+(\w+)\s*;" "typedef\s+struct\s+(\w+)\s*\{")
    for pattern in "${typedef_patterns[@]}"; do
        types=$(echo "$file_content" | grep -Po "$pattern" | grep -Po '\w+')
        for type_name in $types; do
            if [[ " ${DO_NOT_CONVERT[@]} " =~ " ${type_name} " ]]; then
                continue
            fi
            local snake_type=$(camel_to_snake "$type_name")${TYPE_SUFFIX}
            content+="#define ${snake_type} ${type_name}\n"
        done
    done

    echo -en $content | tac | awk '!seen[$0]++' | tac
    echo -en "\n/* Functions */\n"

    content=""

    local functions_pattern="(RLAPI|RMAPI|extern)\s+((const\s+|unsigned\s+)*[A-Za-z0-9]+\s+(?:\*+|))([A-Z][a-zA-Z0-9]+)\(([\s\S]+?)\).*"
    functions=$(echo "$file_content" | grep -Po "$functions_pattern")
    while IFS= read -r line; do
        local camel_func=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if($i ~ /\(/) {print $i; exit}}' | cut -d '(' -f 1)
        if [[ "$camel_func" == *"*"* ]]; then
                camel_func=$(echo "$camel_func" | sed 's/\*//g')
        fi
        local snake_func=${func_prefix}$(camel_to_snake "$camel_func")
        content+="#define ${snake_func} ${camel_func}\n"
    done <<< "$functions"

    echo -en $content | grep -v '^$'
    echo -en "\n#endif /* ${header_name} */\n"
}

convert() {
    local raylib_h_content=$(cat "${folder_path}/raylib.h")
    local raylib_s_header=$(process_header "$raylib_h_content" "raylib.h" "RAYLIB_S_H" "rl_")
    echo -e "$raylib_s_header" > "${folder_path}/raylib_s.h"

    local raymath_h_content=$(cat "${folder_path}/raymath.h")
    local raymath_s_header=$(process_header "$raymath_h_content" "raymath.h" "RAYMATH_S_H" "rm_")
    echo -e "$raymath_s_header" > "${folder_path}/raymath_s.h"
}

convert
