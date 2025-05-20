## snake_case converter for raylib.h / raymath.h

This is a converter from raylib's traditional _PascalCase/camelCase_ to lowercase _snake_case_.

**_NOTE_**: this converter is **NOT** part of the raylib library (https://www.raylib.com/) and is provided **"as-is"**.

### Process:

- Creates macros for all "_FunctionName_" to "**_r\*\_function_name_**";
- Creates macros for all "_TypeName_" to "**_type_name_t_**";
- Saves the content into _"raylib_s.h"_ and _"raymath_s.h"_.

This approach is non-destructive, so you can copy-paste a raylib examples, they will work then eventually rewrite it to snake_case and it will work just the same.  
There is also no cost added at runtime.

### Usage: 

* **git clone https://github.com/domhathair/raylib-converter-bash.git && cd raylib-converter-bash**
* **chmod +x converter.sh**
* **./converter.sh _<path_to_raylib_folder>_**
* If all goes well, you should have an additional files _"raylib_s.h"_ and _"raymath_s.h"_;
* **#include _"raylib_s.h"_** instead of _"raylib.h"_ but keep it as it's not a replacement.
